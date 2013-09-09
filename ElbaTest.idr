module Main

import Js.Unsafe
import Elba.Signal
import Elba.Mouse
import Elba.Keyboard

printAny : a -> IO ()
printAny {a} x = mkForeign (FFun "console.log" [FAny a] FUnit) x

ups : Signal Int
ups = scan (+) 0 (map snd arrows)

main : IO ()
main = do
  pos <- mousePos
  sink print pos
  sink print ups

{--
main : IO ()
main = unsafeToIO $ do
  arr <- newArray {a = IORef String}
  r1 <- newIORef "hello"
  r2 <- newIORef "this"
  r3 <- newIORef "works"
  printAny r3
  readIORef r3
  printAny arr
  push r1 arr
  printAny arr
  push r2 arr
  printAny arr
  push r3 arr
  setGlobal "arr" arr
  mapIO_ printRef arr

main : IO ()
main = unsafeToIO $ do
  let sgen = effectful random
  bod <- Elba.Input.body
  printAny bod
  setGlobal "sgen" sgen
  setGlobal "idrisUnit" ()
  smp <- start (the (SignalGen () (Signal Float)) sgen)
  res <- the (JsIO (List Float)) (sequence (replicate 5 (smp ())))
  printAny res

  --}
