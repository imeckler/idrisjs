module Js.Obj

import Js.Array
import Js.Types
import Language.Reflection

data Ty = F FTy | J JsTy | T Type

infixr 1 ~>

data TwoOrMore a = Two a a | (::) a (TwoOrMore a)

data PropType : Type where
  ReadOnly  : Ty -> PropType
  WriteOnly : Ty -> PropType
  ReadWrite : Ty -> PropType
  Method    : TwoOrMore Ty -> PropType

toFFIArgs : TwoOrMore a -> (List a, a)
toFFIArgs (Two a b)   = ([a], b)
toFFIArgs (x :: xs) =
  let (args, ret) = toFFIArgs xs in (x :: args, ret)

Property : Type
Property = (String, PropType)

data Object : List Property -> Type

using (xs : List a)
  data Elem : a -> List a -> Type where
    Here  : Elem x (x :: xs)
    There : Elem x xs -> Elem x (y :: xs)

class ToTy (t : Type) where
  toTy : t -> Ty

instance ToTy FTy where
  toTy = F

instance ToTy Type where
  toTy = T
  
instance ToTy JsTy where
  toTy = J

class MethType (t : Type) (s : Type) where
  (~>) : t -> s -> TwoOrMore FTy

instance MethType Type Type where
  (~>) t1 t2 = Two (FAny t1) (FAny t2)

instance MethType Type (TwoOrMore FTy) where
  (~>) t ts = (FAny t) :: ts

instance MethType FTy Type where
  (~>) ft t = Two ft (FAny t)

instance MethType Type FTy where
  (~>) t ft = Two (FAny t) ft

instance MethType FTy FTy where
  (~>) ft1 ft2 = Two ft1 ft2

instance MethType FTy (TwoOrMore FTy) where
  (~>) t ts = t :: ts

method : String -> (funTy : TwoOrMore Ty) -> Property
method name funTy = (name, Method funTy)

readOnly : (ToTy t) => String -> t -> Property
readOnly name t = (name, ReadOnly (toFTy t))

writeOnly : (ToTy t) => String -> t -> Property
writeOnly name t = (name, WriteOnly (toFTy t))

prop : String -> FTy -> Property
prop name t = (name, ReadWrite t)


class Obj a where
  properties : List Property

data JQuery : Type
instance Obj JQuery where
  properties = [ readOnly "id" FString
               , writeOnly "foo" FInt
               , method "children" (FUnit ~> JQuery) -- jQuery)
               ]

s : JQuery

-- Add either type classes or list to props so that 
-- this can be WriteOnly or ReadWrite
-- set : Has Property (name, WriteOnly t) ps => (name : String) -> Object ps -> interpFTy t -> IO ()

findElem : Nat -> List (TTName, Binder TT) -> TT -> Tactic
findElem Z ctxt goal     = Refine "Here" `Seq` Solve
findElem (S n) ctxt goal = 
  GoalType "Elem"
    (Try (Refine "Here" `Seq` Solve)
         (Refine "There" `Seq` (Solve `Seq` findElem n ctxt goal)))

empty : Obj a => IO a
empty {a} = mkForeign (FFun ("(function(){return {})") [FUnit] (FAny a)) ()

get : (Obj a) => {t : Ty} -> (name : String) -> 
      {default tactics {applyTactic findElem 100; solve; } 
         prf : Elem (name, ReadOnly ty) properties } ->
      a -> Int

{--
get : (Obj a, Has Property (name, ReadOnly t) properties) => a -> IO (interpFTy t)
get {t} {name} obj = mkForeign (FFun ("." ++ name) [FPtr] t) (believe_me obj)

set : (Obj a, Has Property (name, WriteOnly t) properties) => a -> interpFTy t -> IO ()
set {t} {name} obj x = mkForeign (FFun ("." ++ name ++ "=") [FPtr, t] FUnit) (believe_me obj) x

methType : TwoOrMore FTy -> Type
methType ts = uncurry ForeignTy (toFFIArgs ts)
--}
morph : List Type -> Type -> Type
morph args ret = foldr (\t, ft => t -> ft) ret args

funCall : (ts : List Type) -> (acc : (List (t : Type ** t))) -> (morph ts (List (t : Type ** t)))
funCall [] acc = reverse acc
funCall (t::ts) acc = \x : t => funCall ts ((t ** x) :: acc)

syntax [o] "#" [p] = get {name = p} o
syntax [o] "#" [p] ":=" [x] = set {name = p} o x

