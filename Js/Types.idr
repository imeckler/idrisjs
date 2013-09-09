module Js.Types

import Language.Reflection

%access abstract


data JsAny : Type

data Js : Type -> Type

-- data JsTy = Js Type


-- toFTy (Js t) = FAny t

implicit typeToFTy : Type -> FTy
typeToFTy = FAny

data Access = Read | Write

data PropType : Type where
  {--
  ReadOnly  : FTy -> PropType
  WriteOnly : FTy -> PropType
  ReadWrite : FTy -> PropType
  --}
  Attribute : Bool -> Bool -> FTy -> PropType
  Method    : List FTy -> FTy -> PropType

-- Making this a tuple made some things weirdly not work
data Property = Prop String PropType

using (xs : List a)
  data Elem : a -> List a -> Type where
    Here  : Elem x (x :: xs)
    There : Elem x xs -> Elem x (y :: xs)

class Obj a where
  properties : List Property

private
prop' : Bool -> Bool -> String -> FTy -> Property
prop' read write name t = Prop name (Attribute read write t)

readOnly : String -> FTy -> Property
readOnly = prop' True False

writeOnly : String -> FTy -> Property
writeOnly = prop' False True

prop : String -> FTy -> Property
prop = prop' True True

method : String -> List FTy -> FTy -> Property
method name [] ret = Prop name (Method [FUnit] ret)
method name ts ret = Prop name (Method ts ret)

data JQuery : Type
instance Obj JQuery where
  properties =
    [ method "foo" [FInt, Int, Bool] FUnit
    , prop "length" (FAny Int)
    ]
    -- [ method "foo" [FInt, FInt, FString] -> Js Bool ]
    --}

findElem : Nat -> List (TTName, Binder TT) -> TT -> Tactic
findElem Z ctxt goal     = Refine "Here" `Seq` Solve
findElem (S n) ctxt goal = 
  GoalType "Elem"
    (Try (Refine "Here" `Seq` Solve)
         (Refine "There" `Seq` (Solve `Seq` findElem n ctxt goal)))

findEffElem : Nat -> List (TTName, Binder TT) -> TT -> Tactic -- Nat is maximum search depth
findEffElem Z ctxt goal = Refine "Here" `Seq` Solve
findEffElem (S n) ctxt goal = GoalType "Elem" 
          (Try (Refine "Here" `Seq` Solve)
               (Refine "There" `Seq` (Solve `Seq` findEffElem n ctxt goal)))

get : (Obj a) => {t : FTy} -> (name : String) -> 
      {default tactics {applyTactic findEffElem 100; solve; } 
         prf : Elem (Prop name (Attribute True b t)) properties } ->
      (obj : a) -> IO (interpFTy t)
get {a} {t} name {prf} obj = mkForeign (FFun ("." ++ name) [FAny a] t) obj

{--
x : IO Int
x = get "len" x
--}
{--
implicit jsTy : JsTy -> Type
jsTy (Js t) = t
--}

jsEq : a -> b -> Bool
jsEq {a} {b} x y = unsafePerformIO (
  map intToBool (mkForeign (FFun "jsEquality" [FAny a, FAny b] FInt) x y))

