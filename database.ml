
open Lwt


(* madaque with Lwt *)

module Lwt_thread = struct
  include Lwt
  include Lwt_chan
end
module Lwt_PGOCaml = PGOCaml_generic.Make(Lwt_thread)
module Lwt_Query = Query.Make_with_Db(Lwt_thread)(Lwt_PGOCaml)


(* connected to database *)

let get_db : unit -> unit Lwt_PGOCaml.t Lwt.t =
  let db_handler = ref None in
  fun () ->
    match !db_handler with
      | Some h -> Lwt.return h
      | None -> Lwt_PGOCaml.connect ~database:"OCamlTW" ~user:"postgres" ()


(* Tables (we don't create them here) *)

let category = <:table< category (
  id integer NOT NULL,
  theme text NOT NULL,
  chapter text NOT NULL)>>

let article = <:table< article (
  id integer NOT NULL,
  category integer NOT NULL,
  title text NOT NULL,
  abstract text NOT NULL,
  content text NOT NULL,
  slg text NOT NULL)>>

let table = <:table< users (
  login text NOT NULL,
  password text NOT NULL
)>>


(* Interact with the database *)

let find_article_slg slg = 
  get_db () >>= (fun dbh ->
    Lwt_Query.view_one dbh
    <:view< { title = art_.title ;  content = art_.content } |
              art_ in $article$ ; 
              art_.slg = $string:slg$ ; >>)


let find_article_id id = 
  get_db () >>= (fun dbh ->
    Lwt_Query.view_one dbh
    <:view< { title = art_.title ;
              abstract = art_.abstract;
              content = art_.content ; 
              slg = art_.slg } |
              art_ in $article$ ; 
              art_.id = $int32:id$ ; >>)

let articles_of_theme theme =
  get_db () >>= (fun dbh ->
    Lwt_Query.view dbh
    <:view< { id = art_.id } |
              art_ in $article$ ;
              cat_ in $category$ ;
              cat_.theme = $string:theme$ ;
              cat_.id = art_.category ; >>)

let find name = 
  get_db () >>= (fun dbh ->
   Lwt_Query.view dbh
   <:view< {password = user_.password} |
            user_ in $table$;
            user_.login = $string:name$; >>)

let insert name pwd =
  get_db () >>= (fun dbh ->
  Lwt_Query.query dbh
  <:insert< $table$ :=
    { login = $string:name$; password = $string:pwd$; }>>)

(* let _ = insert "hooo" "kkkskk" *)

let check_pwd name pwd =
   (get_db() >>= (fun dbh ->
   Lwt_Query.view dbh
   <:view< {password = user_.password} | 
            user_ in $table$; 
            user_.login = $string:name$; 
            user_.password = $string:pwd$ >>))
  >|= (function [] -> false | _ -> true)

let find_pwd name =
  get_db() >>= (fun dbh ->
  ((Lwt_Query.view_one dbh 
  <:view< {pwd = user_.password} | 
           user_ in $table$; 
           user_.login = $string:name$ >>)))
