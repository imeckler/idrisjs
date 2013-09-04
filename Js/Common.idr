module Js.Common

import Js.Types

syntax [s] ".[" [i] "]" = prim__strIndex s i
wrap : (a -> b) -> Js (a -> b)
wrap {a} {b} f = unsafePerformIO (
  mkForeign (FFun "wrapIdrisUncurried" [FAny (a -> b)] (FAny (Js (a -> b)))) f)

error : String -> a
error {a} s = unsafePerformIO (mkForeign (FFun "throwError" [FString] (FAny a)) s)

printAny : a -> IO ()
printAny {a} x = mkForeign (FFun "console.log" [FAny a] FUnit) x

