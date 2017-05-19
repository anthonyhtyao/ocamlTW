
type _ compute =
  | Val: 'a -> 'a compute
  | Compute: ('b -> 'a) * 'b compute -> 'a compute

let rec compute : type a. a compute -> a = function
  | Val v -> v
  | Compute (func, comp) -> func @@ compute comp

let rec reduce_step : type a. a compute -> a compute = function
  | Val v -> Val v
  | Compute (func, Val v) -> Val (func v)
  | Compute (func, comp) -> Compute (func, reduce_step comp)

let computation_ex = 
  Compute (print_endline, 
    Compute (string_of_int, Compute (List.hd, Val [2;3;5;7])))
