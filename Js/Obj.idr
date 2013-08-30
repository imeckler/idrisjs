module Obj

data PropType where
  ReadOnly : Type -> PropType
  Method   : [Type] -> Type -> PropType
  ReadWrite : Type -> PropType

Property : Type
Property = (String, PropType)

using (xs : List a)
  data Elem : a -> List a -> Type where
    Here  : Elem x (x :: xs)
    There : Elem x xs -> Elem x (y :: xs)

class HasProp (o : ObjectType props) (p : Property) where
  hasProp : Elem p props

instance HasProp (WithProp props

data ObjectType : [Property] -> Type where
  Empty    : ObjectType []
  WithProp : (p : Property) -> ObjectType props -> ObjectType (p :: props)

(+>) : Object props -> (p : Property) -> Object (p :: props)

jQuery = obj
       +> method "length" (FUnit ~> FInt)
       +> readOnlyProp "id" FString
       +> readWriteProp "data" 

