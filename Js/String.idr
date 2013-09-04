module Js.String
import Js.Obj



instance Obj String where
  properties =
    [ method "toString" (FUnit ~> FString)
    , method "valueOf" (FUnit ~> FString)
    , method "charAt" (F

