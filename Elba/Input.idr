module Elba.Input

import Elba.IO
import Elba.Param


data Element = MkElem Ptr

body : JsIO Element
body = Thunk (\() => map MkElem (eval "document.body"))

