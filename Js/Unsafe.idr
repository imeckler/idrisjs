module Js.Unsafe

import Prelude


setGlobal : String -> a -> IO ()
setGlobal {a} s x = mkForeign (FFun "setGlobal" [FString, FAny a] FUnit) s x

eval : String -> IO a
eval {a} s = mkForeign (FFun "eval" [FString] (FAny a)) s

{-
eval : String -> IO a
eval {a} s = mkForeignPrim (FFun "eval" [FString] ?ret) s -- (mkForeignPrim (FFun "eval" [FString] (FAny a))) s


evalUnsafer : String -> a
evalUnsafer s = unsafePerformIO (eval s)
-}
