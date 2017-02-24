
(* fibonacci.ml *)

let rec fib = function
  | 0 -> 0
  | 1 -> 1
  | n -> fib (n-1) + fib (n-2)

let fib_improved = 
  let rec fib_general a b = function
    | 0 -> a
    | n -> fib_general b (a+b) (n-1)
  in fib_general 0 1
