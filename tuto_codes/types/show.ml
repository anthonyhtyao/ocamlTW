
type 'a show = 'a -> string
type 'a t = { value: 'a ; show: 'a show }

let a = { value = 3 ; show = string_of_int }
let b = { value = "tornado" ; show = fun s -> s }

type t = Int of int | String of string

let show = function
  | Int n -> string_of_int n
  | String s -> s

type _ t =
  | Int: int -> int t
  | String: string -> string t

let show_func : type a. a t -> a -> string = function
  | Int _ -> string_of_int
  | String _ -> fun s -> s

let show : type a. a t -> string = function
  | Int x as a -> (show_func a) x
  | String x as a -> (show_func a) x
