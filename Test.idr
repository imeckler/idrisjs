module Main

import Js.Types
import Js.Bool
import Js.Common
import Js.Array
import Js.MaybeDef
import Js.Unsafe
import Js.Frp.Stream
-- import Js.Obj

curryForeign : a -> a
curryForeign = evalUnsafer "curry"


f : String -> String -> String -> IO String
f x y z = (mkForeign (FFun "f" [FString, FString, FString] FString)) x y z

g : String -> String -> String -> String
g x y z = x ++ y ++ z

returnIO : a -> IO a
returnIO = return
{--
wrap : (a -> b) -> IO (a -> b)
wrap {a} {b} f =
  mkForeign (FFun "(function(f){console.log(f);return f;})" [FFunction (FAny a) (FAny b)] (FFunction (FAny a) (FAny b))) f
  --}
zippy : (a -> b -> c) -> Stream a -> Stream b -> Stream c
zippy {a} {b} {c} f s1 s2 = unsafePerformIO (
  mkForeign (FFun ".zip" [FAny (Stream a), FAny (Stream b), (FFunction (FAny a) (FFunction (FAny b) (FAny c))) ] (FAny (Stream c)) ) s1 s2 f)

ticks1 : Stream Int
ticks1 = interval 100 1

ticks2 : Stream Int
ticks2 = map (const 2) ticks1

ignoring : a -> b -> b
ignoring x y = y

ticks3 : Stream Int
ticks3 = zipWith (+) ticks1 ticks2

morphF : Type -> Type -> List Type -> FTy
morphF a b []        = FFunction (FAny a) (FAny b)
morphF a b (x :: xs) = FFunction (FAny a) (morphF b x xs)

mutltiArgWrap : (a : Type) -> (b : Type) -> (ts : List Type) -> (f : interpFTy (morphF a b ts)) -> IO (interpFTy (morphF a b ts))
mutltiArgWrap a b ts f = let ty = morphF a b ts in mkForeign (FFun "(function(f){console.log(f);return f;})" [ty] ty) f

identCode : String
identCode = "(function(f){console.log(f);return f;})" 

fourArgWrap : (a -> b -> c -> d -> e) -> IO (a -> b -> c -> d -> e)
fourArgWrap {a} {b} {c} {d} {e} f = let ty = FFunction (FAny a) (FFunction (FAny b) (FFunction (FAny c) (FFunction (FAny d) (FAny e)))) in
  mkForeign (FFun "(function(f){console.log(f);return f;})" [ty] ty) f

cool : Int -> Int -> Int -> Int -> Int
cool x y z k = x + y + z + k

intWrap : (Int -> Int) -> IO Ptr
intWrap f =
  mkForeign (FFun "funIdent" [FFunction (FAny Int) (FAny Int)] FPtr) f

h : Js (Int -> Int -> Int -> Int -> Int)
h = wrap cool

nice : Js (Int -> Int -> String)
nice = wrap (\x, y => show (x + y))

apply2 : Js (a -> b -> c) -> a -> b -> IO c
apply2 {a} {b} {c} f x y =
  mkForeign (FFun "apply2" [FAny (Js (a -> b -> c)), FAny a, FAny b] (FAny c)) f x y

main : IO ()
main = do
  apply2 nice 10 5 >>= printAny
  setGlobal "funIdent" (the Ptr (evalUnsafer identCode))
  f <- mutltiArgWrap Int Int [Int, Int, Int] cool
  g <- fourArgWrap cool
  i <- intWrap (+ 1)
  -- i <- mkForeign (FFun identCode [FFunction (FAny Int) (FAny Int)] (FFunction (FAny Int) (FAny Int))) (+ 1) 
  setGlobal "wrappedF" f
  setGlobal "wrappedG" g
  setGlobal "wrappedH" h
  setGlobal "wrappedI" i
  arr <- newArray { a = Int }
  push 100 arr
  x <- arr ! 0
  Js.Array.map (const "hi") arr >>= printAny

 

{--
main : IO ()
main = do
  the (IO ()) (eval "obj={}")
  the (IO ()) (eval "f=function(x,y,z){return x.concat(y,z)}")
  setGlobal "idrisf" (f "lol" "hi")
  setGlobal "idrisg" g
  wrappedG <- wrap g
  setGlobal "wrappedg" wrappedG
  setGlobal "wrapg" (wrap g)
  s <- f "loinil" "hi" "world"
  putStrLn s
  setGlobal "s" s
  arr <- newArray { a = Int }
  push 100 arr
  x <- arr ! 0

  Js.Array.map (\x => x + 1) arr >>= printAny

  printAny x
  setGlobal "yo" "helloworld"
  printAny "helloworld"
  printAny (Js.MaybeDef.toMaybe x)
  --}
