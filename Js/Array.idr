module Js.Array
import Js.MaybeDef

Array : Type -> Type
Array _ = Ptr


indexHonest : Array a -> Int -> IO (MaybeDef a)
indexHonest {a} arr i =
    mkForeign (FFun "indexObj" [FPtr, FInt] (FAny (MaybeDef a))) arr i

infixl 1 !

(!) : Array a -> Int -> IO (MaybeDef a)
(!) = indexHonest

newArray : IO (Array a)
newArray {a} = mkForeign (FFun "newArray" [FUnit] (FAny (Array a))) ()

push : a -> Array a -> IO ()
push {a} x arr = mkForeign (FFun ".push" [FAny (Array a), FAny a] FUnit) arr x

map : (a -> b) -> Array a -> IO (Array b)
map {a} {b} f arr = mkForeign (FFun ".map" [FPtr, (FFunction (FAny a) (FAny b))] FPtr) arr f

