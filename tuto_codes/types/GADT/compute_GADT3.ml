
type _ compute =
  | Val: 'a -> ('b -> 'a) compute
  | Compute: ('b -> 'a) * ('c -> 'b) compute -> (('c -> 'b)  -> 'a) compute

let rec compute : type a b. (b -> a) compute -> a = function
  | Val v -> v
  | Compute (func, comp) -> func @@ compute comp

(*let combine : *)

(*let rec reduce_step: type a b c. ((a -> b) -> c) compute -> _ = function
  | Val v -> Val v
  | Compute (func, Val v) -> Val (func v)
  | Compute (func, comp) -> Compute (func, reduce_step comp)*)

(*let undo : type a b c. ((a -> b) -> c) compute -> (a -> b) compute = function
  | Val a -> Val a
  | Compute (func, comp) -> comp*)

let computation_ex = 
  Compute (print_endline, 
    Compute (string_of_int, Compute (List.hd, Val [2;3;5;7])))

