module Js.Unsafe

setGlobal : String -> a -> IO ()
setGlobal {a} s x = mkForeign (FFun "setGlobal" [FString, FAny a] FUnit) s x

eval : String -> IO a
eval {a} s = (mkForeign (FFun "eval" [FString] (FAny a))) s

evalUnsafer : String -> a
evalUnsafer s = unsafePerformIO (eval s)
