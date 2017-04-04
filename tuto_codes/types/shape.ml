
type shape =
  | Square of float
  | Rectangle of float * float
  | Circle of float

let area = function
  | Square a -> a *. a
  | Rectangle (a,b) -> a *. b
  | Circle r -> let pi = 4. *. atan 1. in pi *. r *. r
