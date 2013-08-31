module Js.Bool

import Unsafe
import Types

true : Js Bool
true = evalUnsafer "true"

false : Js Bool
false = evalUnsafer "false"

