module Elba.Signal

import Js.Bool

%access public

data Signal a = MkSignal Ptr

-- consider removing the unsafePerformIOs and making Signal a ~ IO Ptr

signalMap : (a -> b) -> Signal a -> Signal b
signalMap {a} {b} f (MkSignal s) = unsafePerformIO (
  map MkSignal (mkForeign (FFun "Elba.Signal.map" [FAny (a -> b), FPtr] FPtr) f s))

instance Functor Signal where
  map = signalMap

private
unwrap : Signal a -> Ptr
unwrap (MkSignal s) = s

ap : Signal (a -> b) -> Signal a -> Signal b
ap (MkSignal sf) (MkSignal sx) = unsafePerformIO (
  map MkSignal (mkForeign (FFun "Elba.Signal.ap" [FPtr, FPtr] FPtr) sf sx))

private
constant : a -> Signal a
constant {a} x = unsafePerformIO (
  map MkSignal (mkForeign (FFun "Elba.Signal.constant" [FAny a] FPtr) x))

instance Applicative Signal where
  (<$>) = ap
  pure = constant

-- Make this more efficent (i.e., with less wrapping and unwrapping en el futuro
join : Signal (Signal a) -> Signal a
join sig = unsafePerformIO (
  map MkSignal (mkForeign (FFun "Elba.Signal.join" [FPtr] FPtr) (unwrap (map unwrap sig))))

-- Consider implementing this directly
instance Monad Signal where
  (>>=) x f = join (map f x)

filter : (a -> Bool) -> a -> Signal a -> Signal a
filter {a} f init (MkSignal s) = unsafePerformIO (
  map MkSignal (
    mkForeign (
      FFun "Elba.Signal.filter" [FAny (a -> JsBool), FAny a, FPtr] FPtr) (fromBool . f) init s))

whenIO : Ptr -> Ptr -> IO Ptr
whenIO boolSig s = do
  jsBoolSig <- mkForeign (FFun "Elba.Signal.map" [FAny (Bool -> JsBool), FPtr] FPtr) fromBool boolSig
  mkForeign (FFun "Elba.Signal.dropWhen" [FPtr, FPtr] FPtr) jsBoolSig s

when : Signal Bool -> Signal a -> Signal a
when (MkSignal boolSig) (MkSignal s) = unsafePerformIO (map MkSignal (whenIO boolSig s))

abstract
Subscription : Type
Subscription = Ptr

stop : Subscription -> IO ()
stop sub = mkForeign (FFun ".unsubscribe" [FPtr, FUnit] FUnit) sub ()

sink : (a -> IO b) -> Signal a -> IO ()
sink {a} {b} f (MkSignal s) =
  mkForeign (FFun "Elba.Signal.sink" [FAny (a -> IO b), FPtr] FUnit) f s

