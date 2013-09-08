// Just a minimal example to illustrate the apparent problem.
// The real motivating example is writing bindings for Bacon.js
// which has many some functions that take functions of
// 2+ arguments (eg., zipWith)
apply2 = function(f, x, y){
    return f(x, y);
}

apply1 = function(f, x){
    return f(x);
}
