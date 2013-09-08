(function(window){
  var idrisUnit = null;

  var lastKey = null;
  $('body').on

  var ElbaInput = {
  }

  var Elba = {

    Input : ElbaInput,

    newIORef :
      function(x){
        return [x];
        // return { contents : x };
      },

    readIORef :
      function(ref){
        return ref[0];
        // return ref.contents;
      },

    writeIORef :
      function(ref, x){
        ref[0] = x;
        // ref.contents = x;
      },

    iter:
      function(f, arr){
        var len = arr.length;
        for (var i = 0; i < len; ++i){
          f(arr[i]);
        }
      }
  };

  window.Elba = Elba;
})(window);
