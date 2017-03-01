
let rec quick_sort = function
  | [] -> []
  | x::xs -> 
      let left = List.filter (fun y -> y <= x) xs in
      let right = List.filter (fun y -> y > x) xs in
      quick_sort left @ x::quick_sort right
