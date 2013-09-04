module Js.MaybeNull

import Js.Types
import Js.Bool
import Js.Unsafe

abstract
MaybeNull : Type -> Type
MaybeNull a = a

public
empty : MaybeNull a
empty = evalUnsafer "null"

private
isNull : a -> Bool
isNull {a} x = toBool (unsafePerformIO (mkForeign (FFun "isNull" [FAny a] (FAny (JsBool))) x))

public
map : (a -> b) -> MaybeNull a -> MaybeNull b
map f = f

public
(<$>) : MaybeNull (a -> b) -> MaybeNull a -> MaybeNull b
f <$> x = if isNull f || isNull x then empty else f x

public
(>>=) : MaybeNull a -> (a -> MaybeNull b) -> MaybeNull b
x >>= f = if isNull x then empty else f x

public
toMaybe : MaybeNull a -> Maybe a
toMaybe {a} x = if isNull x then Nothing else Just x

