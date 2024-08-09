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


