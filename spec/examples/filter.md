Filter
======

Introduction
------------

The main objective of this file is to present a simple 
example of an input program for the high level language
and document each step of translation done by the compiler.

We will use the syntax currently used by the prototype which
does allow recursive data types. The change to only allow 
recursion as a **dead** type argument for the **memory** 
can be easily implemented once we have the general translation
schema properly defined.

Module Filter
-------------

In this example, we consider an input module which has some 
simple functions over lists. We choose this rather large example 
because it shows different situations of the defunctionalization.

The input file is as follows:  

```
data List[a] = Nil | Cons[a,List[a]]
data Bool = False | True 

function and(x,y) {
  match x, y {
  | False, _ => return False; 
  | True, z => return z;
  };
}

class a : Eq {
  function eq (x : a, y : a) -> Bool ;
}

instance Word : Eq {
  function eq (x, y) {
    match primEqWord(x,y) {
    | 0 => return False ; 
    | _ => return True ; 
    };
  }
}


function filter (f, xs) {
  match xs {
| Nil => return Nil ;
  | Cons[y,ys] => 
    match f(y) {
    | False => return filter(f,ys); 
    | True => return Cons[y,filter(f,ys)];
    };
};
}

function list1 () {
  return Cons[1, Cons[2, Cons[3, Nil]]]; 
}
 
function foo0(y) {
  return filter((lam (x){ return eq(x,y); }), list1());
}
 
function foo1() {
  return filter((lam (x){ return eq(x,1); }), list1());
}
 
function foo2(p,q) {
  return filter(lam (x) { return and(p(x), q(x)) ; }
                , list1());
}
```

Parsing
--------

The current version of the high-level language, represents 
programs by a data types parameterized by its identifier type. 
This allow us a simple solution to represent names with / without
its types. Initially, every identifier is represented by type 
`Name`, which only holds the string for the identifier. 

Type inference
--------------

The result of type inference is to annotate every identifier 
with its type. Type inference starts by doing a dependency
analysis to build groups of mutually dependent definitions
that needs to be topologically sorted to typing. The same
strategy is used by Haskell compilers.

The typing algorithm produces an AST 
which is parameterized by `Id`, which is formed by a `Name`
and its inferred type, a value of type `Ty`.

As an example of the type inference output, consider the 
function `filter`: 

```
function filter (f, xs) {
  match xs {
| Nil => return Nil ;
  | Cons[y,ys] => 
    match f(y) {
    | False => return filter(f,ys); 
    | True => return Cons[y,filter(f,ys)];
    };
  };
}

```
The `filter` produced by type inference will look like:
```
function filter (f :: a20 -> Bool : a20 -> Bool, xs :: List[a20] : List[a20]) -> List[a20] {
   match (xs :: List[a20]) {
   | Nil :: List[a20] =>
      return Nil :: List[a20]
   | Cons :: a20 -> List[a20] -> List[a20][y :: a20, ys :: List[a20]] =>
      match (f :: a20 -> Bool(y :: a20)) {
      | False :: Bool =>
         return filter :: (a20 -> Bool) -> List[a20] -> List[a20](f :: a20 -> Bool, ys :: List[a20])
      | True :: Bool =>
         return Cons :: a20 -> List[a20] -> List[a20][y :: a20, filter :: (a20 -> Bool) -> List[a20] -> List[a20](f :: a20 -> Bool, ys :: List[a20])]
      }
   }
}
```
where now each identifier holds it's inferred type. 

Pattern matching compilation
----------------------------

The objective of this phase is to compile the pattern match construction into cases, i.e. 
matching over one expression at time.

Consider the following function: 

```
function and(x,y) {
  match x, y {
  | False, _ => return False; 
  | True, z => return z;
  };
}
```
After the pattern matching compilation, the resulting AST for `and` will be like 
(note that this phase is executed **after** type inference)

```
function and (x : Bool, y : Bool) -> Bool {
   match (x :: Bool) {
   | False :: Bool =>
      let var_3 :: Bool = y :: Bool ;
      return False :: Bool
   | True :: Bool =>
      let var_5 :: Bool = y :: Bool ;
      return var_5 :: Bool
   }
}
```
As another example, consider this simple code piece: 

```
data Nat = Zero | Succ[Nat]

function foo (x, y) {
  match x, y {
  | x1, Zero => return 1 ; 
  | Zero, Succ[y2] => return 2; 
  | Succ[x3], Succ[y3] => return 3;
  };
```
The pattern match compiler needs to output:

```
function foo (x : Nat, y : Nat) -> Word {
   let var_12 :: Nat = x :: Nat ;
   match (y :: Nat) {
   | Zero :: Nat =>
      return 1 ; 
   | x2 => 
      return fun_Global0_foo_1(x);
   }
}
function fun_Global0_foo_1 (x :: Nat) {
   match (x :: Nat) {
   | Succ :: Nat -> Nat[var_2 :: Nat] =>
      let var_3 :: Nat :: Nat = var_2 :: Nat ;
      match (y :: Nat) {
      | Succ :: Nat -> Nat[var_5 :: Nat] =>
         let var_6 :: Nat :: Nat = var_5 :: Nat ;
         return 3
      }
   | Zero :: Nat =>
      match (y :: Nat) {
      | Succ :: Nat -> Nat[var_8 :: Nat] =>
         let var_9 :: Nat = var_8 :: Nat ;
         return 2
      }
   }
}
```

Defunctionalization
--------------------

Another step of the code desugaring process is to 
defunctionalize high-order functions. Let's consider
again function `filter`: 

```
function filter (f, xs) {
  match xs {
| Nil => return Nil ;
  | Cons[y,ys] => 
    match f(y) {
    | False => return filter(f,ys); 
    | True => return Cons[y,filter(f,ys)];
    };
  };
}
```

and some functions which use filter with different 
anonymous functions.

```
function list1 () {
  return Cons[1, Cons[2, Cons[3, Nil]]]; 
}
 
function foo0(y) {
  return filter((lam (x){ return eq(x,y); }), list1());
}
 
function foo1() {
  return filter((lam (x){ return eq(x,1); }), list1());
}
 
function foo2(p,q) {
  return filter(lam (x) { return and(p(x), q(x)) ; }
                , list1());
}
```

The defunctionalization algorithm starts by defining a 
data type that has one constructor for each different 
lambda abstraction in code. Since the previous code 
has 3 different abstractions, the algorithm will produce 
a data type with 3 different constructors. 

```
data Lam_filter = Lam_filter00[Word] | Lam_filter01  
                | Lam_filter02[Lam_filter, Lam_filter]
```

The first constructor holds a word parameter since the 
function 
```
lam (x) {return primEqWord(x,y)} 
```

uses variable `y` which is **free** within the anonymous 
functions code. 

Abstraction 

```
lam (x) {return primEqWord (x,1)}
```

produces the constructor `Lam_filter01` without any arguments,
since it does not refer to values outside the lambda scope.
Finally, constructor `Lam_filter02` is recursive due to the 
occurrence of two functions with the same type of the 
abstraction within

```
lam (x) { return and(p(x), q(x)) ; }
```
code 

After creating the data type, we need to create a 
function which dispatch the corresponding abstraction code
for each constructor. 

```
function apply_filter (f : Lam_filter, xs : List a) -> List a {
  match xs {
  | Nil => return Nil ;
  | Cons[y, ys] => 
    match apply_filter(f, y) {
    | False => return filter(f,ys); 
    | True => return Cons[y,filter(f,ys)];
    };
  };
}
```

The calls for `filter` are changed to replace the lambdas by 
its corresponding constructor. 

```
function foo0 (y : Word) -> List[Word] {
   return apply_filter (Lam_filter00, list1())
}
function foo1 () -> List[Word] {
   return apply_filte(Lam_filter01, list1());
}
function foo2 (p : Word -> Bool, q : Word -> Bool) -> List[Word] {
   return apply_filte(Lam_filter02[p, q], list1())
}
```
