
type s = Epsilon | ST of s * t
and t = Paren of s

let rec dyck_word = function
  | Epsilon -> ""
  | ST (s,t) -> dyck_word s ^ dyck_word_t t

and dyck_word_t (Paren s) = "(" ^ dyck_word s ^ ")"
