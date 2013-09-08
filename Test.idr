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

f : Js (Int -> Int -> String)
f = wrap (\x, y => show (x + y))

actions : Stream (IO ())
actions = map print ticks3

just4lol : Stream Int
just4lol = map (const 4) actions

ioAction : IO ()
ioAction = putStrLn "hi"

-- unsafeFunCall : String -> Array Ptr ->

newIOArray : IO (Array (IO (IO ())))
newIOArray = newArray {a = IO ()}

{--
testIOWrap : IO () -> IO ()
testIOWrap x = mkForeign (FFun "console.log" [FA
                         --}

main : IO ()
main = do
  arr <- newIOArray
  push (the (IO (IO ())) (return (printAny "maybegood"))) arr
  printAny ioAction
  setGlobal "ioAction" (the (List (IO ())) [ioAction])
  setGlobal "ticks3" ticks3
  setGlobal "actions" actions
  setGlobal "just4lol" just4lol
  setGlobal "wrappedF" f
