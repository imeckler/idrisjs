module Frp

import Effects

%access public

data StreamType = Pushable | Normal

abstract
data Stream :
  StreamType -> (m : Type -> Type) -> List EFFECT -> List EFFECT -> Type -> Type

data MStream : (m : Type -> Type) -> Type -> Type

run : Monad m => MStream m a -> m (MStream id a)
run stream = 

map : (a -> EffM m es es' b)

abstract
data Behavior : Type -> Type

Bus : (Type -> Type) -> List EFFECT -> List EFFECT -> Type -> Type
Bus = Stream Pushable

abstract
createBus : IO (Bus m es es' a)
createBus {m} {es} {es'} {a} =
  mkForeign (FFun "(function(){return (new Bacon.bus())})" [FUnit] (FAny (Bus m es es' a))) ()

abstract
pushBus : a -> Bus m es es' a -> IO ()
pushBus {m} {es} {es'} {a} x bus = mkForeign (FFun ".push" [FAny (Bus m es es' a), FAny a] FUnit) bus x

data Pushing : Effect where
  New  : Pushing () () (Bus m es es' a)
  Push : a -> Bus m es es' a ->  Pushing () () ()

instance Handler Pushing IO where
  handle () (New {a}) k    = createBus >>= k ()
  handle () (Push x bus) k = pushBus x bus >>= k ()

PUSHING : EFFECT
PUSHING = MkEff () Pushing

new : Eff IO [PUSHING] (Bus m es es' a)
new = New

push : a -> Bus m es es' a -> Eff IO [PUSHING] ()
push x bus = Push x bus

-- Subscriptions

abstract
data Subscription : Type

private
SubState : Type
SubState = (Int, SortedMap Int String)

onValue : Stream p m es es' a -> (a -> b) -> IO Subscription
onValue {a} {b} stream f =
  let funTy = FFunction (FAny a) (FAny (IO b)) in
    mkForeign (FFun ".onValue" [FPtr, funTy] (FAny Subscription)) (believe_me stream) (return . f)


data OnEvent : Effect where
  -- TODO: Possibly add support for tracking subscriptions so that
  -- you can only close one once?
  DoOnEvent : Stream p m es es' a -> (a -> b) -> OnEvent () () Subscription
  End       : Subscription -> OnEvent () () ()


instance Handler OnEvent IO where
  handle () (End sub) k =
    mkForeign (FFun ".call" [FAny Subscription, FUnit] FUnit) sub () >>= k ()

  handle () (DoOnEvent {a} {b} stream f) k = onValue stream f >>= k ()

-- map : (a -> b) -> (Stream p m es es')
