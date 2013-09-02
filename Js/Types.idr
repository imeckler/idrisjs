module Js.Types

-- abstract
data Js : Type -> Type

jsEq : a -> b -> Bool
jsEq {a} {b} x y = unsafePerformIO (
  map intToBool (mkForeign (FFun "jsEquality" [FAny a, FAny b] FInt) x y))

