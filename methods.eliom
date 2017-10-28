open Eliom_content.Html.D

let slg_of_id ar_id =
  let%lwt ar = Database.find_light_article_id ar_id in
  Lwt.return (Sql.get ar#slg)

let title_of_id ar_id =
  let%lwt ar = Database.find_light_article_id ar_id in
  Lwt.return (Sql.get ar#title)

let section_of_chap chap_id ar_id =
  let%lwt cat = Database.detail_of_category chap_id in
  let _ = match (Sql.getn cat#article) with
    | Some n -> assert (n = ar_id)
    | None -> assert false in
  let%lwt ar_ids = Database.articles_of_chapter chap_id ar_id in
  let ars = List.map 
    (fun ar_id -> Database.find_article_id (Sql.get ar_id#id)) ar_ids in
  Lwt_list.map_s
    (fun ar -> 
      let%lwt ar = ar in Lwt.return (
      li [a ~service:OCamlTW.article_service
            [pcdata (Sql.get ar#title)]
            ("ocaml-tuto", (Sql.get ar#slg))])) ars 
