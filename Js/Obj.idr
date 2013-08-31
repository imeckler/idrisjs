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

mkForeign : PropType -> Type
mkForeign 

reifyProperty : ((name, propTy) : Property) -> Foreign (mkForeign propTy)

data Object : List Property -> Type

using (xs : List a)
  data Elem : a -> List a -> Type where
    Here  : Elem x (x :: xs)
    There : Elem x xs -> Elem x (y :: xs)

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

method : String -> TwoOrMore FTy -> Property
method name funTy = (name, Method funTy)

readOnly : (ToFTy t) => String -> t -> Property
readOnly name t = (name, ReadOnly (toFTy t))

writeOnly : (ToFTy t) => String -> t -> Property
writeOnly name t = (name, WriteOnly (toFTy t))

prop : String -> FTy -> Property
prop name t = (name, ReadWrite t)

jQuery : Type
jQuery =
  Object [ method "children" (FUnit ~> Array jQuery)
         , readOnly "id" FString
         ]

(^.) : (IsElem (name, ty) ps) => Object ps -> fromPropType ty

class HasProp (p : Property) (t : Type) where
  meth :

{--
(+>) : Object props -> (p : Property) -> Object (p :: props)

jQuery = obj
       +> method "length" (FUnit ~> FInt)
       +> readOnlyProp "id" FString
       +> readWriteProp "data" 

       --}


