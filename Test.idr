module Main

import Js.Types
import Js.Bool
import Js.Common
import Js.Array
import Js.MaybeDef
import Js.Unsafe
import Js.Frp.Stream
-- import Js.Obj

ticks1 : Stream Int
ticks1 = interval 100 1

ticks2 : Stream Int
ticks2 = map (const 2) ticks1

ticks3 : Stream Int
ticks3 = zipWith (+) ticks1 ticks2

main : IO ()
main = do
  setGlobal "ticks3" ticks3
