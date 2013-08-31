module Js.Types

-- abstract
data Js a

public
jsEq : Js a -> Js b -> Bool
jsEq {a} {b} x y = unsafePerformIO (
  map intToBool (mkForeign (FFun "jsEquality" [FAny (Js a), FAny (Js b)] FInt) x y))

