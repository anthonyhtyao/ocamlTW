
(* past, first value, history compute *)

type (_, _, _) compute =
  | Id: ('a, 'b, 'a -> 'b) compute
  | Compute: ('a -> 'b) * ('c, 'd, 'e -> 'a) compute -> 
      ('c, 'd, ('e -> 'a)  -> 'b) compute

type ('a,'b,'c) computation = { value: 'b; compute: ('a,'b,'c) compute }

let rec compute : type a b c d. (a, b, c -> d) computation -> d = 
  fun { value; compute = comp } -> match comp with
  | Id -> value
  | Compute (func, comp) -> func @@ compute { value; compute = comp }

let rec combine : type a b c d e f.
  (a, b, c -> d) compute -> (c, d, e -> f) compute -> 
    (a, b, e -> f) compute =
  fun c1 c2 -> match c2 with
  | Id -> c1
  | Compute (func, comp) -> Compute (func, combine c1 comp)

(*
let rec reduce_step : type a. (b * a) compute -> (b * b) compute = function
  | Val v -> Val v
  | Compute (func, Val v) -> Val (func v)
  | Compute (func, comp) -> Compute (func, reduce_step comp)*)

let undo = 
  function
  | Id -> None
  | Compute (func, comp) -> Some comp

let compute1 = Compute (List.hd, Compute (Array.to_list, Id))
let compute2 = Compute (print_endline, Compute (string_of_int, Id))

let computation_ex = { value = [|2; 3; 5; 7|] ; compute = compute1 ; }

(*
type _ lis =
  | Nil: 'a lis
  | Cons: 'a * 'b lis -> ('a * 'b) lis

let tl : type a b. (a * b) lis -> b lis = function
  | Nil -> Nil
  | Cons (x, xs) -> xs
*)
