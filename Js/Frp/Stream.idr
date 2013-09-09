module Js.Frp.Stream

import Js.Bool
import Js.Common
import Js.Types

data StreamType = Push | Pure
data Stream : Type -> Type


fFunTy : Type -> Type -> List Type -> FTy
fFunTy a b [] = FFunction (FAny a) (FAny b)
fFunTy a b (t::ts) = FFunction (FAny a) (fFunTy b t ts)

map : (a -> b) -> (Stream a -> Stream b)
map {a} {b} f stream = unsafePerformIO (
  mkForeign (FFun ".map" [FAny (Stream a), FFunction (FAny a) (FAny b)] (FAny (Stream b))) stream f)

filter : (a -> Bool) -> Stream a -> Stream a
filter {a} f stream = unsafePerformIO (
  mkForeign (FFun ".filter" [FAny (Stream a), fFunTy a JsBool []] (FAny (Stream a))) stream (fromBool . f))

bind : Stream a -> (a -> Stream b) -> Stream b
bind {a} {b} stream f = unsafePerformIO (
  mkForeign (FFun ".flatMap" [FAny (Stream a), fFunTy a (Stream b) []] (FAny (Stream b))) stream f)

zipWith : (a -> b -> c) -> Stream a -> Stream b -> Stream c
zipWith {a} {b} {c} f s1 s2 = unsafePerformIO (
  mkForeign (FFun ".zip" [FAny (Stream a), FAny (Stream b), (FAny (Js (a -> b -> c)))] (FAny (Stream c))) s1 s2 (wrap f))

once : a -> Stream a
once {a} x = unsafePerformIO (mkForeign (FFun "Bacon.once" [FAny a] (FAny (Stream a))) x)

interval : Int -> a -> Stream a
interval {a} n x = unsafePerformIO (mkForeign (FFun "Bacon.interval" [FInt, FAny a] (FAny (Stream a))) n x)

