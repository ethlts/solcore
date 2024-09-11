/*
   Assumptions

   - Bool is built in (and we get boolean ops for free :))
   - We don't have built in literals for Yul Words
*/

// Basics

data Proxy(t) = Proxy

// Type Classification

// types that can be completely represented by a single stack slot
class t:ValueTy {
    function abs(x:Word) -> t;
    function rep(x:t) -> Word;
}

// Memory Layout

function get_free_memory() -> Word {
    let res : Word;
    assembly {
        res := mload(0x40)
    };
    return res;
}

function set_free_memory(loc : Word) {
    assembly {
        mstore(0x40, loc)
    };
}

//


// References

type Calldata(t) = Word;
type Memory[t] = Word;
type Storage[t] = Word;
type Returndata[t] = Word;
type Stack[t] = Word;

class ref:Loadable [deref] {
    load : ref -> deref;
};

class ref:Storable [deref] {
    store : ref -> deref -> Unit;
};

class ref:Ref [deref] {
    load : ref -> deref;
    store : Pair[ref, deref] -> Unit;
};

// patterson condition?
instance (ref:Storable[deref], ref:Loadable[deref]) => ref:Ref[deref] {
    load ref = { Loadable.load(ref); };
    store ref deref = { Storable.store(Pair ref deref); };
};

instance (t:ValueTy) => Memory[t]:Loadable[t] {
    load ref = {
        let rw = ref.rep;
        let res = 0;
        assembly {
          res := mload(rw)
        }
        return ValueTy.abs(res);
    }
}

instance t:ValueTy => Memory(t):Storable[t] {
    function store(ref, t) -> () {
        let rw = ref.rep;
        let vw = ValueTy.rep val;
        assembly {
          mstore(rw, vw)
        }
    }
}

// TODO: Indexable Containers

// Bytes

type Bytes = Void;
// TODO: bytes should be indexable (but not ref since it can't live on stack...)

// ABI Encoding

class t:EncodeInto {
    function encodeInto(val : t, hd : Word, tl : Word) -> Pair(Word,Word);
}

class t:Encode {
    // TODO: is the following ever needed??
    // is the abi representation of `t` dynamically sized?
    // function isDynamicallySized(x:Proxy(t)) -> Bool;

    // does `t` (or any of it's children) contain a dynamic type?
    function shouldEncodeDynamic(x:Proxy(t)) -> Bool;
    // how big is the head portion of the ABI representation of `t`?
    function headSize(x:Proxy(t)) -> Word;
}

forall t:{Encode,EncodeInto} . function encode(val:t) -> Memory(Bytes) {
    let hdSz = headSize(Proxy.abs(Unit) : Proxy(t));
    let ptr = get_free_memory();
    let head;
    let tail;
    assembly {
        head := add(ptr, 32);
        tail := add(head, hdSz);
    }
    let (hd, tl) = encodeInto(val,head,tail);
    set_free_memory(tl);
    assembly {
        mstore(ptr, sub(tl, head))
    }
    return Memory.abs(ptr)
}

instance l:Encode => r:Encode => Pair(l,r):Encode {
    function isDynamicallySized(x : Proxy(Pair(l,r))) -> Bool {
        return Encode.isDynamicallySized(Proxy.abs() : Proxy(l)) || Encode.isDynamicallySized(Proxy.abs() : Proxy(r))
    }

    function shouldEncodeDynamic(x : Proxy(Pair(l,r))) -> Bool {
        return Encode.shouldEncodeDynamic(Proxy.abs() : Proxy(l)) || Encode.shouldEncodeDynamic(Proxy.abs() : Proxy(r))
    }

    function headSize(x : Proxy(Pair(l,r))) -> Word {
        if Encode.shouldEncodeDynamic(x) {
            let res;
            assembly { res := 32; }
            return res;
        } else {
            let lsize = Encode.headSize(Proxy.abs() : Proxy(l));
            let rsize = Encode.headSize(Proxy.abs() : Proxy(r));
            let res;
            assembly { res := add(lsize,rsize) }
            return res;
        }
    }
}

instance l:EncodeInto => r:EncodeInto => Pair(l,r):EncodeInto {
    function encodeInto(val, hd, tl) -> Pair(Word,Word) {
        let fst = val.first;
        let snd = val.second;
        let (hd', tl') = EncodeInto.encodeInto(fst, hd, tl);
        return EncodeInto.encodeInto(snd, hd', tl');
    }
}

// Uint256

type Uint256 = Word;

instance Uint256:Encode {
    function shouldEncodeDynamic(_) -> Bool { return False; }
    function headSize(_) -> Word {
        let res;
        assembly { res := 32 }
        return res;
    }
}

instance Uint256:EncodeInto {
    function encodeInto(v,hd,tl) -> Pair(Word, Word) {
        let vw = v.rep();
        let hd';
        assembly {
            hd' := add(hd, 32)
            mstore(hd, vw)
        }
        return (hd', tl);
    }
}


// Contract Entrypoint

class self:GenerateDispatch {
    function dispatch_if_selector_match(self) -> (() -> ());
}

data Dispatch(name,args,retvals) = DispatchFunction name (args->retvals)

instance args:ABI => retvals:ABI => name:Selector => dispatchFuncion[name,args,retvals]:GenerateDispatch {
    function dispatch_if_selector_match(self:dispatchFuncion[name,args,retvals]) -> (() -> ()) {
        return lambda () {
            let DispatchFunction(name,f) := self; // or whatever destructuring syntax we want
            if matches_selector(name) // checks selector in calldata
            {
                let (result_start, result_end) = abi.encode(f(abi.decode(TYPE(retvals)))); // conceptually at least
                assembly {
                    return(result_start, result_end); // as in EVM return, terminating the external call.
                }
            }
        };
    }
}

instance a:GenerateDispatch => b:GenerateDispatch => Pair[a,b]:GenerateDispatch {
    function dispatch_if_selector_match(self:Pair[a,b]) -> (() -> ()) {
        return lambda () . {
            dispatch_if_selector_match(self.first);
            dispatch_if_selector_match(self.second);
        };
    }
}

/// Translation of the above contract

struct StorageContext {
    x:uint;
    y:bool;
}

function C_f(ctxt:StorageContext) public {
    ctxt.x = 42;
}


function entry_C() {
    GenerateDispatch.dispatch_if_selector_match(DispatchFunction("f()", C_f)); // could also be (nested) pairs of dispatch functions, if the contract had more functions
    revert("unknown selector");
}

// init code for contract creation
function init_C() {
    // constructor code
    let code_start := allocate_unbounded() // fetch some free memory
    let code_length := __builtin_fetch_code(entry_C, code_start) // sounds weirder than it is - this will just add the code for entry_C to a Yul subobject and use some Yul builtins for fetching the code to be deployed
    assembly {
        return(code_start, code_length)
    }
}

