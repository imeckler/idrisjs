module Js.MaybeDef

import Js.Types
import Js.Bool
import Js.Unsafe

abstract
MaybeDef : Type -> Type
MaybeDef a = a

public
empty : MaybeDef a
empty = evalUnsafer "undefined"

private
isUndefined : MaybeDef a -> Bool
isUndefined {a} x = toBool (unsafePerformIO (mkForeign (FFun "isUndefined" [FAny a] (FAny (JsBool))) x))

public
map : (a -> b) -> MaybeDef a -> MaybeDef b
map f = f

public
pure : a -> MaybeDef a
pure x = x

public
(<$>) : MaybeDef (a -> b) -> MaybeDef a -> MaybeDef b
f <$> x = if isUndefined f || isUndefined x then empty else f x

public
(>>=) : MaybeDef a -> (a -> MaybeDef b) -> MaybeDef b
x >>= f = if isUndefined x then empty else f x

public
toMaybe : MaybeDef a -> Maybe a
toMaybe {a} x = if isUndefined x then Nothing else Just x

