module Main

import Common

data Selector : Type where
  All   : Selector
  Tag   : String -> Selector
  Class : String -> Selector
  Id    : String -> Selector

  Descendant : Selector -> Selector -> Selector
  Child : Selector -> Selector -> Selector
  Sibling : Selector -> Selector -> Selector

x : Maybe String
x = [|"Yep"|]

(>>) : Monad m => m a -> m b -> m b
(>>) ma mb = ma >>= const mb

total
boolToMaybe : Bool -> Maybe ()
boolToMaybe True  = Just ()
boolToMaybe False = Nothing

parseToken' : List Char -> Maybe Selector
parseToken' ['*']        = [| All |]
parseToken' ('.'::c::cs) = Just . Class $ pack (c::cs)
parseToken' ('#'::cs)    = Just $ Id (pack cs)
parseToken' (c::cs)      = boolToMaybe (all isAlphaNum (c::cs)) >> Just (Tag (pack (c::cs)))

parseToken : String -> Maybe Selector
parseToken = parseToken' . unpack

parseTokens : List String -> Maybe Selector
parseTokens [x]          = parseToken x
parseTokens (x::"~"::xs) = [| Sibling (parseToken x) (parseTokens xs) |]
parseTokens (x::">"::xs) = [| Child (parseToken x) (parseTokens xs) |]
parseTokens (x::xs)      = [| Descendant (parseToken x) (parseTokens xs) |]

parseSelector : String -> Maybe Selector
parseSelector = parseTokens . words

test : Int -> String
test 0 = "hi"
test _ = error "nah"

main : IO ()
main = putStrLn "yo" >> putStrLn (test 1)
