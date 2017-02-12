
{
  open Lexing
}

let character = [^'&']

rule token = parse
  | "&"                 {"&" ^ (token lexbuf)}
  | "&gt;"              {">" ^ (token lexbuf)}
  | "&lt;"              {"<" ^ (token lexbuf)}
  | "&amp;"             {"&" ^ (token lexbuf)}
  | character* as s     {s ^ (token lexbuf)}
  | eof                 {""}
