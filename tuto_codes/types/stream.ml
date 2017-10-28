
(* type definition *)

type 'a stream = Nil | Cons of 'a * (unit -> 'a stream)

let rec ones = Cons (1, fun () -> ones)

(* simple examples *)

let rec from n = Cons (n, fun () -> from (n+1))
let natural = from 0

let rec fibgen a b = Cons (a, fun () -> fibgen b (a+b))
let fib = fibgen 1 1

(* utility functions *)

let hd = function
  | Nil -> failwith "hd"
  | Cons (x, xs) -> x

let tl = function
  | Nil -> failwith "tl"
  | Cons (x, xs) -> xs ()

let rec nth s n =
  if n < 0 then invalid_arg "nth: negative index";
  try
    if n = 0 then hd s
    else nth (tl s) (n-1)
  with
    Failure _ -> failwith "nth: index out of bound"

let rec take n s =
  if n <= 0 then [] else 
  match s with
  | Nil -> []
  | Cons (x, xs) -> x::(take (n-1) @@ xs ())

let rec map f = function
  | Nil -> Nil
  | Cons (x, xs) -> Cons (f x, fun () -> map f @@ xs ())

let rec filter p = function
  | Nil -> Nil
  | Cons (x, xs) -> 
      if p x then Cons (x, fun () -> filter p @@ xs ())
      else filter p @@ xs ()

(* advanced examples *)

let rec nat = Cons (0, fun () -> map (fun x -> x+1) nat)

let sift p = filter (fun n -> 
  Format.printf "%d mod %d@." n p; n mod p <> 0)

let rec sieve = function
  | Nil -> Nil
  | Cons (p, g) -> Cons (p, fun () -> sieve (sift p @@ g ()))

let primes = sieve (from 2)

(* create a stream list *)

let rec of_list = function
  | [] -> Nil
  | x::xs -> Cons (x, fun () -> of_list xs)

let rec repeat x = Cons (x, fun () -> repeat x)

let cycle l =
  let rec cycle_aux l r = match l,r with
    | [], [] -> invalid_arg "cycle: empty list"
    | x::xs, y -> Cons (x, fun () -> cycle_aux xs (x::y))
    | [], y -> cycle_aux (List.rev y) [] 
  in
  cycle_aux l []

let rec iterate f x = Cons (x, fun () -> iterate f @@ f x)
