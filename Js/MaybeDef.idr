module Js.MaybeDef

import Js.Types
import qualified Js.Bool


abstract
MaybeDef : a -> Type
MaybeDef a = a

public
toMaybe : MaybeDef a -> Maybe a
toMaybe x =
  let isUndefined = unsafePerformIO (
    mkForeign (FFun "isUndefined" [FPtr] (FAny (Js Bool))) x)
  in
  if jsEq Js.Bool.true x then None else Some x
