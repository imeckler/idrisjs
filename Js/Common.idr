module Common

syntax [s] ".[" [i] "]" = prim__strIndex s i

failAtCompileTime : a -> a
failAtCompileTime x = x
    where t : so (const True x)
          t = oh

printAny : a -> IO ()
printAny {a} x = mkForeign (FFun "console.log" [FAny a] FUnit) x

