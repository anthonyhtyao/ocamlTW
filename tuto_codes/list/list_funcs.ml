
let rec append l1 l2 = match l1 with
  | [] -> l2
  | x::xs -> x::append xs l2

let rev l =
  let rec rev_aux l1 l2 = match l1 with
    | [] -> l2
    | x::xs -> rev_aux xs @@ x::l2
  in rev_aux l []

let rec concat = function
  | [] -> []
  | x::xs -> append x @@ concat xs

let rec map f = function
  | [] -> []
  | x::xs -> f x::map f xs

let rec iter inst = function
  | [] -> ()
  | x::xs -> inst x; iter inst xs

let rec filter predic = function
  | [] -> []
  | x::xs -> if predic x then x::filter predic xs else filter predic xs

let rec for_all predic = function
  | [] -> true
  | x::xs -> if predic x then for_all predic xs else false

let rec fold_left f a l = match l with
  | [] -> a
  | x::xs -> fold_left f (f a x) xs

let rec fold_right f l b = match l with
  | [] -> b
  | x::xs -> f x (fold_right f xs b)
