module Js.Bool

import Js.Unsafe
import Js.Types

true : Js Bool
true = evalUnsafer "true"

false : Js Bool
false = evalUnsafer "false"

