
let sum_tailrec =
  let rec sum_partial s = function
    | 0 -> s
    | n -> sum_partial (s+n) (n-1)
  in sum_partial 0
