
type shape =
  | Square of { side : float }
  | Rectangle of { length : float ; width : float }
  | Circle of { radius : float }

let area = function
  | Square sq -> sq.side *. sq.side
  | Rectangle rect -> rect.length *. rect.width
  | Circle c -> let pi = 4. *. atan 1. in pi *. c.radius *. c.radius
