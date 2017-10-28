[%%shared
  open Eliom_lib
  open Eliom_content
  open Html.D
  open Database
  open OCamlTW
]

(* Register services *)

let () =

  OCamlTW_app.register
    ~service:ocamltuto_service
    (fun () () ->
      let%lwt chps = chapters_of_theme 1L in
      let bdc =
        Ui.breadcrumbs 
        [ `Service_s (main_service, "Home") ;
          `Service_s (ocamltuto_service, "OCaml 教學")] in
      let body = Lwt_list.map_s
        (fun chap -> 
          let chap_ar_id = match Sql.getn chap#article with
            | Some n -> n
            | None -> assert false in
          let chap_chapter = match Sql.getn chap#label with
            | Some n -> n
            | None -> assert false in
          let%lwt chap_ar = find_light_article_id chap_ar_id in
          let chap_ar_slg = Sql.get chap_ar#slg in
          let%lwt sec =
            Methods.section_of_chap (Sql.get chap#id) chap_ar_id in
          Lwt.return 
            (li [section [h2 [ 
              a ~service:article_service
                [pcdata chap_chapter]
                ("ocaml-tuto", chap_ar_slg)]; ul sec]])) chps
      in
      let%lwt body = body in
      close_dbs();
      Ui.skeleton "OCaml Tuto" [bdc; h1 [pcdata "OCaml Tuto"]; ol body]);

  OCamlTW_app.register
    ~service:related_service
    (fun () () ->
      let%lwt related_ids = articles_of_theme 2L in
      let related_ids = List.map 
        (fun sqlid -> Sql.get sqlid#id) related_ids in
      let related_ars = List.map find_light_article_id related_ids in
      let bdc = 
        Ui.breadcrumbs
        [ `Service_s(main_service, "Home");
          `Service_s(related_service, "相關文章")] in
      let body = Lwt_list.map_s
        (fun ar -> 
          let%lwt ar = ar in 
          let abs = match Sql.getn ar#abstract with
            | Some tex -> tex
            | _ -> assert false in
          Lwt.return (
            li [a ~service:article_service 
                  [pcdata (Sql.get ar#title)] 
                  ("related-articles", (Sql.get ar#slg));
                p [pcdata abs];
                a ~service:article_service
                  [pcdata "read more"]
                  ("related-articles", (Sql.get ar#slg));
                hr();]))
      related_ars in
      let%lwt body = body in
      close_dbs();
      Ui.skeleton "related" [bdc; ul body]);
