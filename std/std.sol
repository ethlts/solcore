// booleans

data bool = true | false;

// TODO: this should short circuit. probably needs some compiler magic to do so.
function and(x: bool, y: bool) -> bool {
    match x, y {
    | true, y => return y;
    | false, _ => return false;
    };
}

// TODO: this should short circuit. probably needs some compiler magic to do so.
function or(x: bool, y: bool) -> bool {
    match x, y {
    | true, _ => return true;
    | false, y => return y;
    };
}

// Pairs

data Pair(a, b) = Pair(a, b);

function fst(p: Pair(a, b)) -> a {
    match p {
    | Pair(a, _) => return a;
    };
}

function snd(p: Pair(a, b)) -> b {
    match p {
    | Pair(_, b) => return b;
    };
}

//

data Proxy(t) = Proxy;

// References

data Calldata(t) = Calladata(word);
data Memory(t) = Memory(word);
data Storage(t) = Storage(word);
data Returndata(t) = ReturnData(word);
data Stack(t) = Stack(word);

// Type Classification

// types that can be completely represented by a single stack slot
class t:ValueTy {
    function abs(x:word) -> t;
    function rep(x:t) -> word;
}

instance Memory(t) : ValueTy {
    function abs(x: word) -> Memory(t) {
        return Memory(x);
    }

    function rep(x: Memory(t)) -> word {
        match x {
        | Memory(w) => return w;
       };
    }
}

class ref:Ref(deref) {
    function load(loc: ref) -> deref;
    function store(loc: ref, value: deref) -> Unit;
}


instance Memory(t) : Ref(t) {
    function load(loc: Memory(t)) -> t {
        let rw = ValueTy.rep(loc);
        let res = 0;
        assembly {
            res := mload(rw)
        };
        return ValueTy.abs(res);

    }

    function store(loc: Memory(t), value: t) -> Unit {
        let rw = ValueTy.rep(loc);
        let vw = ValueTy.rep(value);
        assembly {
          mstore(rw, vw)
        };
    }
}



// Memory Layout

function get_free_memory() -> word {
    let res : word;
    assembly {
        res := mload(0x40)
    };
    return res;
}

function set_free_memory(loc : word) {
    assembly {
        mstore(0x40, loc)
    };
}


// Bytes

data Bytes = Bytes;
// TODO: bytes should be indexable (but not ref since it can't live on stack...)

// ABI Encoding

class t:EncodeInto {
    function encodeInto(val : t, hd : word, tl : word) -> Pair(word,word);
}

class t:Encode {
    // TODO: is the following ever needed??
    // is the abi representation of `t` dynamically sized?
    // function isDynamicallySized(x:Proxy(t)) -> bool;

    // does `t` (or any of it's children) contain a dynamic type?
    function shouldEncodeDynamic(x:Proxy(t)) -> bool;
    // how big is the head portion of the ABI representation of `t`?
    function headSize(x:Proxy(t)) -> word;
}

forall t:Encode, t:EncodeInto . function encode(val:t) -> Memory(Bytes) {
    let p : Proxy(t);
    let hdSz = Encode.headSize(p);
    let ptr : word = get_free_memory();
    let head : word;
    let tail : word;
    assembly {
        head := add(ptr, 32);
        tail := add(head, hdSz);
    };
    let tl = snd(EncodeInto.encodeInto(val,head,tail));
    set_free_memory(tl);
    assembly {
        mstore(ptr, sub(tl, head))
    };
    let mem : Memory(Bytes) = Memory(ptr);
    return mem;
}

instance (l:Encode, r:Encode) => Pair(l,r):Encode {
    function shouldEncodeDynamic(x : Proxy(Pair(l,r))) -> bool {
        let l: Proxy(l) = Proxy;
        let r: Proxy(r) = Proxy;
        return and(Encode.shouldEncodeDynamic(l), Encode.shouldEncodeDynamic(l));
    }

    function headSize(x : Proxy(Pair(l,r))) -> word {
        match Encode.shouldEncodeDynamic(x) {
        | true =>
            let res;
            assembly { res := 32; };
            return res;
        | false =>
            let l: Proxy(l) = Proxy;
            let r: Proxy(r) = Proxy;
            let lsize = Encode.headSize(l);
            let rsize = Encode.headSize(r);
            let res : word;
            assembly { res := add(lsize,rsize) };
            return res;
        };
    }
}

instance (l:EncodeInto, r:EncodeInto) => Pair(l,r):EncodeInto {
    function encodeInto(val, hd, tl) -> Pair(word,word) {
        let first = fst(val);
        let second = snd(val);
        let range = EncodeInto.encodeInto(first, hd, tl);
        return EncodeInto.encodeInto(second, fst(range), snd(range));
    }
}

// Uint256
data Uint256 = Uint256(word);

instance Uint256 : ValueTy {
    function abs(x:word) -> Uint256 {
        return Uint256(x);
    }

    function rep(x: Uint256) -> word {
        match x {
        | Uint256(val) => return val;
        };
    }
}

instance Uint256:Encode {
    function shouldEncodeDynamic(x) -> bool {
        return false;
    }

    function headSize(x) -> word {
        return 32;
    }
}

instance Uint256:EncodeInto {
    function encodeInto(v: Uint256, hd: word, tl: word) -> Pair(word, word) {
        let vw = ValueTy.rep(v);
        let hd_ : word;
        assembly {
            hd_ := add(hd, 32)
            mstore(hd, vw)
        };
        return Pair(hd_, tl);
    }
}


// Contract Entrypoint

// TODO: need to have a way to write predicate in class function or class itself, or have a function type.
// class self:GenerateDispatch {
//     function  dispatch_if_selector_match(x: self) -> (Unit -> Unit);
// }
//
// data Dispatch(name,args,retvals) = DispatchFunction name (args->retvals)
//
// instance args:ABI => retvals:ABI => name:Selector => dispatchFuncion[name,args,retvals]:GenerateDispatch {
//     function dispatch_if_selector_match(self:dispatchFuncion[name,args,retvals]) -> (() -> ()) {
//         return lambda () {
//             let DispatchFunction(name,f) := self; // or whatever destructuring syntax we want
//             if matches_selector(name) // checks selector in calldata
//             {
//                 let (result_start, result_end) = abi.encode(f(abi.decode(TYPE(retvals)))); // conceptually at least
//                 assembly {
//                     return(result_start, result_end); // as in EVM return, terminating the external call.
//                 }
//             }
//         };
//     }
// }
//
// instance a:GenerateDispatch => b:GenerateDispatch => Pair[a,b]:GenerateDispatch {
//     function dispatch_if_selector_match(self:Pair[a,b]) -> (() -> ()) {
//         return lambda () . {
//             dispatch_if_selector_match(self.first);
//             dispatch_if_selector_match(self.second);
//         };
//     }
// }
//
// /// Translation of the above contract
// struct StorageContext {
//     x:uint;
//     y:bool;
// }
//
// function C_f(ctxt:StorageContext) public {
//     ctxt.x = 42;
// }
//
//
// function entry_C() {
//     GenerateDispatch.dispatch_if_selector_match(DispatchFunction("f()", C_f)); // could also be (nested) pairs of dispatch functions, if the contract had more functions
//     revert("unknown selector");
// }
//
// // init code for contract creation
// function init_C() {
//     // constructor code
//     let code_start := allocate_unbounded() // fetch some free memory
//     let code_length := __builtin_fetch_code(entry_C, code_start) // sounds weirder than it is - this will just add the code for entry_C to a Yul subobject and use some Yul builtins for fetching the code to be deployed
//     assembly {
//         return(code_start, code_length)
//     }
// }
//
//
