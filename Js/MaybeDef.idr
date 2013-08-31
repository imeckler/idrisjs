module Js.MaybeDef

import Js.Types
import Js.Bool

abstract
MaybeDef : Type -> Type
MaybeDef a = a

public
toMaybe : MaybeDef a -> Maybe a
toMaybe {a} x =
  let isUndefined = unsafePerformIO (
    mkForeign (FFun "isUndefined" [FAny a] (FAny (Js Bool))) x)
  in
  if jsEq Bool.true isUndefined then Nothing else Just x
