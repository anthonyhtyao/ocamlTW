
type _ compute =
  | Nil: unit compute
  | Val: 'a -> (unit * 'a) compute
  | Compute: ('b -> 'a) * ('c * 'b) compute -> (('c * 'b)  * 'a) compute

let rec compute : type a b. (b * a) compute -> a = function
  | Val v -> v
  | Compute (func, comp) -> func @@ compute comp

(*
let rec reduce_step : type a. (b * a) compute -> (b * b) compute = function
  | Val v -> Val v
  | Compute (func, Val v) -> Val (func v)
  | Compute (func, comp) -> Compute (func, reduce_step comp)*)

let undo : type a b. (b * a) compute -> b compute = function
  | Val _ -> Nil
  | Compute (func, comp) -> comp

let computation_ex = 
  Compute (print_endline, 
    Compute (string_of_int, Compute (List.hd, Val [2;3;5;7])))
