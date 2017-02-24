
{
  open Lexing
}

rule normal_html = parse
  | "&"                 {"&" ^ (normal_html lexbuf)}
  | "&gt;"              {">" ^ (normal_html lexbuf)}
  | "&lt;"              {"<" ^ (normal_html lexbuf)}
  | "&amp;"             {"&" ^ (normal_html lexbuf)}
  | "\t"                {"  " ^ (normal_html lexbuf)}
  | [^'&' '\t']* as s   {s ^ (normal_html lexbuf)}
  | eof                 {""}

and toplevel = parse
  | "#"                 {"@#" ^ (need_highlight lexbuf)}
  | [^'#']* as s        {s ^ (toplevel lexbuf)}
  | eof                 {""}

and need_highlight = parse
  | ";"                 {";" ^ (need_highlight lexbuf)}
  | ";;"                {";;" ^ (toplevel lexbuf)}
  | "\n"                {"\n@" ^ (need_highlight lexbuf)}
  | [^'\n' ';']* as s   {s ^ (need_highlight lexbuf)}
  | eof                 {""}
