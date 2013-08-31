module Js.Common

syntax [s] ".[" [i] "]" = prim__strIndex s i

error : String -> a
error {a} s = unsafePerformIO (mkForeign (FFun "throwError" [FString] (FAny a)) s)

printAny : a -> IO ()
printAny {a} x = mkForeign (FFun "console.log" [FAny a] FUnit) x

