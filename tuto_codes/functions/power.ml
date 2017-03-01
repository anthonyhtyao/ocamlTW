
(* power.ml *)

let rec power x = function | 0 -> 1 | n ->
  let sqr = power x @@ n lsr 1 in 
  sqr * sqr * if n land 1 = 1 then x else 1
