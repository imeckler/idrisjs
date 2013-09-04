module Js.Types

%access abstract

data JsAny : Type

data JsTy = Js Type

implicit jsTy : JsTy -> Type
jsTy (Js t) = t

jsEq : a -> b -> Bool
jsEq {a} {b} x y = unsafePerformIO (
  map intToBool (mkForeign (FFun "jsEquality" [FAny a, FAny b] FInt) x y))

