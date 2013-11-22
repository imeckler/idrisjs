module Js.Bool

import Js.Unsafe
import Js.Types

%access public

abstract
JsBool : Type
JsBool = Ptr

public
true : JsBool
true = evalUnsafer "true"

false : JsBool
false = evalUnsafer "false"

toBool : JsBool -> Bool
toBool x = if jsEq x true then True else False

fromBool : Bool -> JsBool
fromBool True  = true
fromBool False = false

