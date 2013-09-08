Elm.Native.Utils = function(elm) {

  elm.Native = elm.Native || {};
  if (elm.Native.Utils) return elm.Native.Utils;


  var count = 0;
  function guid(_) { return count++ }

  // TODO: Implement idris equality
  function eq(x, y){return x === y}

  function Tuple2(x,y) { return { ctor:"_Tuple2", _0:x, _1:y } }

  return elm.Native.Utils = {
    guid : guid,
    eq   : eq,
    Tuple2: Tuple2
  }
};
