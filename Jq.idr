module Main
import Common

data Selector : Type where
  All : Selector
  Tag : String -> Selector
  Class : String -> Selector
  Id : String -> Selector
  Descendant : Selector -> Selector -> Selector
  Child : Selector -> Selector -> Selector
  Sibling : Selector -> Selector -> Selector

main : IO ()
main = putChar ("hi".[0])
