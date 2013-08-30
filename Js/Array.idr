module Main

Array : Type -> Type
Array _ = Ptr

indexHonest : Array a -> Int -> IO a
-- Figuer out why this isn't working
-- indexHonest {a} arr i = mkForeign (FFun "[]" [FPtr, FInt] (FAny a))
-- indexHonest {a} arr i = believe_me (mkForeign (FFun ".[]" [FPtr, FInt] (FAny a)))
indexHonest {a} arr i =
    mkForeign (FFun "indexObj" [FPtr, FInt] (FAny a)) arr i

-- (!) : Array a -> Int -> a
-- (!) arr i = unsafePerformIO (mkForeign :

newArray : () -> IO (Array a)
newArray {a} () = believe_me (mkForeign (FFun "newArray" [FUnit] (FAny (Array a))))

main : IO ()
main = do
  arr <- newArray {a = Int} ()
  printAny arr
  nope <- indexHonest arr 0
  print nope

