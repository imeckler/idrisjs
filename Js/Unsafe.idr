module Js.Unsafe

eval : String -> IO a
eval {a} s = (mkForeign (FFun "eval" [FString] (FAny a))) s

evalUnsafer : String -> a
evalUnsafer s = unsafePerformIO (eval s)
