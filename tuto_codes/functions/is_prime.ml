
(* is_prime.ml *)

let is_prime = 
  let rec is_prime_partial n d sup =
    if d > sup then true
    else match n mod d = 0 with
      | true -> false
      | _ -> is_prime_partial n (d+1) sup
  in function
    | 1 -> false
    | n -> is_prime_partial n 2 (int_of_float @@ sqrt @@ float_of_int n)
