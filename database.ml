
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
      | None -> Lwt_PGOCaml.connect ~database:"ocamltw" ~user:"postgres" ()


(* Tables (we don't create them here) *)

let category = <:table< category (
  id bigint NOT NULL,
  theme text NOT NULL,
  chapter text NOT NULL,
  article bigint)>>

(* TODO : change created and lastmodified's type to timestamptz*)
let article = <:table< article (
  id bigint NOT NULL,
  created text NOT NULL,
  lastmodified text NOT NULL,
  category bigint NOT NULL,
  title text NOT NULL,
  abstract text NOT NULL,
  content text NOT NULL,
  slg text NOT NULL)>>

let table = <:table< users (
  login text NOT NULL,
  password text NOT NULL
)>>


(* Interact with the database *)

let chapters_of_theme theme =
  get_db () >>= (fun dbh ->
    Lwt_Query.view dbh
    <:view< { id = cat_.id ; 
              chapter = cat_.chapter ;
              article = cat_.article } |
              cat_ in $category$ ;
              cat_.theme = $string:theme$; >>)

let find_article_slg slg = 
  get_db () >>= (fun dbh ->
    Lwt_Query.view_one dbh
    <:view< { id = art_.id ;
              created = art_.created;
              lastmodified = art_.lastmodified; 
              title = art_.title ;  
              content = art_.content ;
              category = art_.category } |
              art_ in $article$ ;
              art_.slg = $string:slg$ ; >>)


let find_article_id id = 
  get_db () >>= (fun dbh ->
    Lwt_Query.view_one dbh
    <:view< { title = art_.title ;
              created = art_.created;
              lastmodified = art_.lastmodified;
              abstract = art_.abstract;
              content = art_.content ; 
              slg = art_.slg } |
              art_ in $article$ ; 
              art_.id = $int64:id$ ; >>)

let articles_of_theme theme =
  get_db () >>= (fun dbh ->
    Lwt_Query.view dbh
    <:view< { id = art_.id } |
              art_ in $article$ ;
              cat_ in $category$ ;
              cat_.theme = $string:theme$ ;
              cat_.id = art_.category ;>>)

let articles_of_chapter chapter_id ar_id =
  get_db () >>= (fun dbh ->
    Lwt_Query.view dbh
    <:view< { id = art_.id } |
              art_ in $article$ ;
              art_.category = $int64:chapter_id$ ; 
              art_.id <> $int64:ar_id$ ;>>)

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
