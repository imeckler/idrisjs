module Js.Obj

import Array

infixr 1 ~>

data TwoOrMore a = Two a a | (::) a (TwoOrMore a)

data PropType : Type where
  ReadOnly  : FTy -> PropType
  WriteOnly : FTy -> PropType
  ReadWrite : FTy -> PropType
  Method    : TwoOrMore FTy -> PropType

toFFIArgs : TwoOrMore a -> (List a, a)
toFFIArgs (Two a b)   = ([a], b)
toFFIArgs ((::) x xs) =
  let (args, ret) = toFFIArgs xs in (x :: args, ret)

Property : Type
Property = (String, PropType)

data Object : List Property -> Type

using (xs : List a)
  data Elem : a -> List a -> Type where
    Here  : Elem x (x :: xs)
    There : Elem x xs -> Elem x (y :: xs)


class Has a (x : a) (xs : List a) where
  isElem : Elem x xs

instance Has a x (x :: xs) where
  isElem = Here

instance Has a x xs => Has a x (y :: xs) where
  isElem = There isElem

class ToFTy (t : Type) where
  toFTy : t -> FTy

instance ToFTy FTy where
  toFTy t = t

instance ToFTy Type where
  toFTy t = FAny t

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

instance MethType FTy (TwoOrMore FTy) where
  (~>) t ts = t :: ts

method : String -> |(funTy : TwoOrMore FTy) -> Property
method name funTy = (name, Method funTy)

readOnly : (ToFTy t) => String -> t -> Property
readOnly name t = (name, ReadOnly (toFTy t))

writeOnly : (ToFTy t) => String -> t -> Property
writeOnly name t = (name, WriteOnly (toFTy t))

prop : String -> FTy -> Property
prop name t = (name, ReadWrite t)

rec : Type -> Type
rec _ = Ptr

jQuery : Type
jQuery =
  Object [ readOnly "id" FString
         , writeOnly "foo" FInt
         , method "children" (FUnit ~> rec jQuery)
         ]

s : jQuery

-- (^.) : (IsElem (name, ty) ps) => Object ps -> fromPropType ty

-- Add either type classes or list to props so that 
-- this can be WriteOnly or ReadWrite
-- set : Has Property (name, WriteOnly t) ps => (name : String) -> Object ps -> interpFTy t -> IO ()

set : (name : String) -> Object props -> Elem (name, WriteOnly t) props -> interpFTy t -> IO ()
set {t} name obj elem x = mkForeign (FFun ("." ++ name ++ "=") [FPtr, t] FUnit) (believe_me obj) x

get : (name : String) -> Object props -> Elem (name, ReadOnly t) props -> IO (interpFTy t)
get {t} name obj elem = mkForeign (FFun ("." ++ name) [FPtr] t) (believe_me obj)

syntax [o] "#" [p] = get p o isElem
syntax [o] "#" [p] "<-" [x] = set p o isElem x

