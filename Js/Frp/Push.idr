module Js.Frp.Push

import Js.Frp.Common
import Effects

Bus : Type -> Type
Bus = Stream Push

abstract
createBus : IO (Bus a)
createBus {a} =
  mkForeign (FFun "(function(){return (new Bacon.bus())})" [FUnit] (FAny (Bus a))) ()

abstract
pushBus : a -> Bus a -> IO ()
pushBus {a} x bus = mkForeign (FFun ".push" [FAny (Bus a), FAny a] FUnit) bus x

data Pushing : Effect where
  New  : Pushing () () (Bus a)
  Push : a -> Bus a ->  Pushing () () ()

instance Handler Pushing IO where
  handle () New k          = createBus >>= k ()
  handle () (Push x bus) k = pushBus x bus >>= k ()

PUSHING : EFFECT
PUSHING = MkEff () Pushing

new : Eff IO [PUSHING] (Bus a)
new = New

push : a -> Bus a -> Eff IO [PUSHING] ()
push x bus = Push x bus

