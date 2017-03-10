
(* vector.ml *)

(* 定義平面上向量的型別 *)
type vector = { x:float ; y:float }

(* 原點 *)
let origin = { x = 0. ; y = 0. }

(* 內積和行列式 *)
let dot_product a b = a.x *. b.x +. a.y *. b.y
let determinant a b = a.x *. b.y -. a.y *. b.x

(* 在 x 軸以及 y 軸上投影的函數 *)
let proj_x, proj_y = (fun {x} -> x), fun {y} -> y

(* 大致給出一個點在平面上的位置 *)
let position = function
  | { x = 0. ; y = 0. } -> "origin"
  | { x = 0. } -> "horizontal axis"
  | { y = 0. } -> "vertical axis"
  | { x ; y } when x > 0. && y > 0. -> "first quadrant"
  | { x } when x > 0. -> "forth quadrant"
  | { y } when y > 0. -> "second quadrant"
  | _ -> "third quadrant"
