module Js.Obj

import Js.Array

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

instance MethType FTy FTy where
  (~>) ft1 ft2 = Two ft1 ft2

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

empty : Obj a => IO a
empty {a} = mkForeign (FFun ("(function(){return {})") [FUnit] (FAny a)) ()

get : (Obj a, Has Property (name, ReadOnly t) properties) => a -> IO (interpFTy t)
get {t} {name} obj = mkForeign (FFun ("." ++ name) [FPtr] t) (believe_me obj)

set : (Obj a, Has Property (name, WriteOnly t) properties) => a -> interpFTy t -> IO ()
set {t} {name} obj x = mkForeign (FFun ("." ++ name ++ "=") [FPtr, t] FUnit) (believe_me obj) x

-- syntax [o] "#" [p] = get' {name = p} o
syntax [o] "#" [p] = get {name = p} o
syntax [o] "#" [p] ":=" [x] = set {name = p} o x

