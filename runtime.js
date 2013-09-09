function newArray(){
    return []
}

function setGlobal(s, x){
    window[s] = x;
}

function getGlobal(s){
  return window[s];
}

function isUndefined(x){
    return (x === undefined)
}

function isNull(x){
    return (x === null)
}

function jsEquality(x,y){
    return (x === y) ? 1 : 0
}

function indexObj(x, i){
    return x[i]
}

function throwError(s){
    throw s;
}

function wrapIdris(fid){
    return function(arg){
        var res = __IDRRT__tailcall(function(){
            return __IDR__APPLY0(fid, arg);
        });
        console.log(res);
        return (res instanceof __IDRRT__Con ? wrapIdris(res) : res);
    }
}

function wrapIdrisUncurried(fid){
    return function(){
        var res = fid;
        var i = 0;
        var arg;
        var len = arguments.length;
        while (res instanceof __IDRRT__Con && i < len){
            arg = arguments[i];
            res = __IDRRT__tailcall(function(){
                return __IDR__APPLY0(res, arg);
            });
            ++i;
        }
        return res;
    }
}
