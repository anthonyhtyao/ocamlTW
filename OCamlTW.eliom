[%%shared
    open Eliom_lib
    open Eliom_content
    open Html.D
    open CalendarLib.Printer.Calendar
    open Database
]


module OCamlTW_app =
  Eliom_registration.App (struct
    let application_name = "OCamlTW"
    let global_data_path = None
  end)

(* Services *)
let main_service =
  Eliom_service.create
    ~path:(Eliom_service.Path [])
    ~meth:(Eliom_service.Get Eliom_parameter.unit)
    ()

let ocamltuto_service =
  Eliom_service.create
    ~path:(Eliom_service.Path ["ocaml-tuto";""])
    ~meth:(Eliom_service.Get Eliom_parameter.unit)
    ()

let related_service =
  Eliom_service.create
    ~path:(Eliom_service.Path ["related-articles"])
    ~meth:(Eliom_service.Get Eliom_parameter.unit)
    ()

let article_service = 
  Eliom_service.create
    ~path:(Eliom_service.Path [])
    ~meth:(Eliom_service.Get 
           Eliom_parameter.(suffix (string "ar_theme" ** string "ar_slg")))
    ()

(* Navbar *)

let navbar () =
  nav ~a:[a_class ["navbar"; "navbar-default"]] 
  [
    div ~a:[a_class ["col-md-10";"col-md-offset-1"]]
    [
      div ~a:[a_class ["navbar-header"]]
      [
        a ~service:main_service ~a:[a_class ["navbar-brand"]] 
        [
          ul ~a:[a_class ["list-inline"]]
          [
            li [pcdata "OCAML"];
            li [img ~alt:("Ocaml Logo")
                ~src:(make_uri ~service:(Eliom_service.static_dir ()) 
                      ["fig";"OCaml.png"])
                ~a:[a_width 25] ()
                ]
          ]
        ] ();
      ];
      div ~a:[a_class ["collapse";"navbar-collapse"]]
      [
        ul ~a:[a_class ["nav";"navbar-nav";"navbar-right"]]
        [
          li [a ~service:ocamltuto_service [pcdata "OCamltuto"] ()];
          li [a ~service:related_service [pcdata "related"] ()]
        ]
      ]
    ]
  ]

let breadcrumbs services =
  let rec aux lst = function
    | [] -> lst
    | [`Service_s (_, title)] | [`Service_ar (_, title, _, _)] -> 
        lst @ [li ~a:[a_class ["active"]] [pcdata title]]
    | `Service_s (service, title)::q ->
        aux (lst @ [li [a ~service:service [pcdata title] ()]]) q
    | `Service_ar (service, title, theme, slg)::q ->
        aux (lst @ [li [a ~service:service [pcdata title] (theme, slg)]]) q

  in
  ol ~a:[a_class ["breadcrumb"]] (aux [] services)

let footer () =
(* Scroll to top when click "To Top"*)
  let top = 
    p ~a:[a_id "back-top";a_class ["hidden"]]
    [
      span [];
      pcdata "To Top"
    ]
  in
  let _ = [%client
    (Lwt.async (fun () ->
      Lwt_js_events.scrolls (Dom_html.window)
         (fun _ _ -> 
            let top_elt = Html.To_dom.of_element ~%top in
            let y = (Js.Unsafe.js_expr "window")##.scrollY in
            let aux y = 
              match y>100 with 
                | true  -> top_elt##.classList##remove(Js.string "hidden")
                | false -> top_elt##.classList##add(Js.string "hidden")
            in aux y; Lwt.return())):unit)
  ] in
  let _ = [%client
    (Lwt.async (fun () ->
       Lwt_js_events.clicks (Html.To_dom.of_element ~%top)
         (fun _ _ -> Dom_html.window##scroll 0 0; Lwt.return())):unit)
  ] in
  [
    top;
    div ~a:[a_class ["col-md-12"]]
    [
      hr ();
      p ~a:[a_class ["text-center"]] [pcdata "2017"]
    ]
  ]

(* Import .css file in head *)

let skeleton title_name body_content = 
  Lwt.return 
    (html
      (head (title (pcdata title_name)) 
        [css_link ~uri:(make_uri (Eliom_service.static_dir ())
                          ["css";"bootstrap.min.css"]) ();
         css_link ~uri:(make_uri (Eliom_service.static_dir ())
                          ["css";"OCamlTW.css"]) ();
         css_link ~uri:(make_uri (Eliom_service.static_dir ())
                          ["css";"agate.css"]) ();
         js_script ~uri:(make_uri (Eliom_service.static_dir ())
                          ["js";"highlight.pack.js"]) ();])
      (body (navbar()::
              [div ~a:[a_class ["col-md-8";"col-md-offset-2";"content"]] 
               body_content] @ footer ())))


let code () = 
    pre [code [pcdata "let x = 10 in"]]


[%%client

let color_syntax() = 
  Js.Unsafe.eval_string "hljs.initHighlightingOnLoad();"

let showContent content = 
  let cont_node = Dom_html.getElementById "content" in
  cont_node##.innerHTML := (Js.string content)

let syntax_configure() = 
  Js.Unsafe.eval_string 
    "hljs.configure({tabReplace: '  ', 
                     language: ['OCaml','Python','C++','Java', 'Haskell']});"

let highlight_article_syntax() =
  let code_blocks = 
    Dom_html.document##querySelectorAll (Js.string "pre code") in
  let l = code_blocks##.length in
  for i = 0 to l-1 do 
    let code = match Js.Opt.to_option (code_blocks##item i) with
      | Some c -> c
      | _ -> assert false
    in
    match Js.to_string code##.className with
      | "nohighlight" -> ()
      | "toplevel" ->
          let code_text = Lexer_html.toplevel @@
            Lexing.from_string @@ Js.to_string code##.innerHTML in
          let code_arr =  
            Js.str_array @@ (Js.string code_text)##split (Js.string "\n") in
          let code_arr = Js.to_array code_arr in
          for i = 0 to Array.length code_arr - 1 do
            let code_line = Js.to_string code_arr.(i) in
            if String.length code_line > 0 && code_line.[0] = '@' then 
              let new_code_obj = 
                 Js.Unsafe.fun_call
                  (Js.Unsafe.js_expr "hljs.highlight") 
                  [|(Js.Unsafe.inject (Js.string "OCaml"));
                     Js.Unsafe.inject code_arr.(i)|] in
              let new_code = new_code_obj##.value in
              let new_code = Lexer_html.normal_html @@
                Lexing.from_string (Js.to_string new_code) in
              code_arr.(i) <- 
                Js.string @@ String.sub new_code 1 (String.length new_code -1)
            else 
              let new_code = 
                (Js.string "<span class='result'>")##concat_2
                code_arr.(i) (Js.string "</span>") in
              code_arr.(i) <- new_code
          done;
          let code_arr = Js.array code_arr in
          let code_content = code_arr##join (Js.string "\n") in
          code##.innerHTML := code_content
      | _ -> (Js.Unsafe.js_expr "hljs.highlightBlock") code
  done

let genTableOfContents() =
  let hTwoLst = Dom.list_of_nodeList 
    (Dom_html.document##getElementsByTagName (Js.string "h2")) in
  let rec tableOfContents s = function
    | [] -> s
    | t::q -> let title = Js.to_string (t##.innerHTML) in
              let hid = Js.to_string (t##.id) in
    tableOfContents (s^"<p><a href='#"^hid^"'>"^title^"</a></p>") q
  in
  let table = Dom_html.getElementById "table_of_contents" in
  table##.innerHTML := (Js.string (tableOfContents "" hTwoLst))

]

let section_of_chap chap_id ar_id =
  let%lwt cat = detail_of_category chap_id in
  let _ = match (Sql.getn cat#article) with
    | Some n -> assert (n = ar_id)
    | None -> assert false in
  let%lwt ar_ids = articles_of_chapter chap_id ar_id in
  let ars = List.map 
    (fun ar_id -> find_article_id (Sql.get ar_id#id)) ar_ids in
  Lwt_list.map_s
    (fun ar -> 
      let%lwt ar = ar in Lwt.return (
      li [a ~service:article_service
            [pcdata (Sql.get ar#title)]
            ("ocaml-tuto", (Sql.get ar#slg))])) ars 

let slg_of_id ar_id =
  let%lwt ar = find_light_article_id ar_id in
  Lwt.return (Sql.get ar#slg)

let title_of_id ar_id =
  let%lwt ar = find_light_article_id ar_id in
  Lwt.return (Sql.get ar#title)

(* Register services *)

let () =

  OCamlTW_app.register
    ~service:main_service
    (fun () () ->
      (*ignore [%client (Dom_html.window##alert (Js.string 
        (Printf.sprintf "Hello")): unit)];*)
      ignore [%client (color_syntax():unit)];
      ignore [%client (highlight_article_syntax():unit)];
      close_dbs();
      skeleton 
        "OCamlTW"
        [
         h1 ~a:[a_class ["test"]] [pcdata "Welcome to OcamlTW!"];
         h2 ~a:[a_class ["border"]] [pcdata "我們將在這裡介紹Ocaml!!!!!"];
         h3 [pcdata "歡迎多多來參觀"];
         code ();
         ul [li [a ~service:ocamltuto_service [pcdata "OCamltuto"] ()];
             li [a ~service:related_service [pcdata "related"] ()]]]);

  OCamlTW_app.register
    ~service:ocamltuto_service
    (fun () () ->
      let%lwt chps = chapters_of_theme 1L in
      let bdc =
        breadcrumbs 
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
          let%lwt sec = section_of_chap (Sql.get chap#id) chap_ar_id in
          Lwt.return 
            (li [section [h2 [ 
              a ~service:article_service
                [pcdata chap_chapter]
                ("ocaml-tuto", chap_ar_slg)]; ul sec]])) chps
      in
      let%lwt body = body in
      close_dbs();
      skeleton "OCaml Tuto" [bdc; h1 [pcdata "OCaml Tuto"]; ol body]);

  OCamlTW_app.register
    ~service:related_service
    (fun () () ->
      let%lwt related_ids = articles_of_theme 2L in
      let related_ids = List.map 
        (fun sqlid -> Sql.get sqlid#id) related_ids in
      let related_ars = List.map find_light_article_id related_ids in
      ignore [%client (color_syntax():unit)] ;
      let bdc = 
        breadcrumbs
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
      skeleton "related" [bdc; ul body]);

  OCamlTW_app.register
    ~service:article_service
    (fun (ar_theme,ar_slg) () ->
      let%lwt theme = detail_of_theme_title ar_theme in
      let%lwt ar = find_article_slg ar_slg in
      let%lwt cat = detail_of_category (Sql.get ar#category) in
      assert ((Sql.get theme#id) = (Sql.get cat#theme));
      let content = Sql.get ar#content in
      let service_of_theme = function
        | "related-articles" -> related_service
        | "ocaml-tuto" -> ocamltuto_service
        | _ -> main_service
      in
      let rel = service_of_theme ar_theme in
      ignore [%client (showContent ~%content:unit)] ;
      ignore [%client (syntax_configure():unit)] ;
      ignore [%client (highlight_article_syntax():unit)] ;
      let is_chapter_page = (Sql.getn cat#article) = (Some (Sql.get ar#id)) in 
      let bdc = match is_chapter_page, Sql.getn cat#article with
        | false, Some chap_ar_id ->
            let%lwt chap_ar = find_light_article_id chap_ar_id in
            Lwt.return 
              (breadcrumbs
              [ `Service_s(main_service, "Home"); 
                `Service_s(rel, Sql.get theme#label);
                `Service_ar(article_service, Sql.get chap_ar#title, 
                            ar_theme, Sql.get chap_ar#slg);
                `Service_ar(article_service, Sql.get ar#title, "", "")])
        | _ -> 
            Lwt.return
              (breadcrumbs
              [ `Service_s(main_service, "Home"); 
                `Service_s(rel, Sql.get theme#label);
                `Service_ar(article_service, Sql.get ar#title, "", "")])
      in
      let body = if is_chapter_page then
        let%lwt sec = section_of_chap (Sql.get ar#category) (Sql.get ar#id) in
        Lwt.return 
          (Eliom_content.Html.D.article [
            h1 [pcdata (Sql.get ar#title)];
            div ~a:[a_id "content"] []; ul sec;])
      else
        let%lwt previous = match (Sql.getn ar#previous) with
          | Some pid -> let%lwt pre_ar = find_light_article_id pid in
                        let title = Sql.get pre_ar#title in
                        let slg = Sql.get pre_ar#slg in
                        Lwt.return ([a ~service:article_service
                          [pcdata ("上一篇 : "^title)](ar_theme, slg)])
          | _ -> Lwt.return []
        in
        let%lwt next = match (Sql.getn ar#next) with
          | Some pid -> let%lwt next_ar = find_light_article_id pid in
                        let title = Sql.get next_ar#title in
                        let slg = Sql.get next_ar#slg in
                        Lwt.return ([a ~service:article_service
                          [pcdata ("下一篇 : "^title)](ar_theme, slg)])
          | _ -> Lwt.return []
        in
        Lwt.return
          (Eliom_content.Html.D.article [
            h1 [pcdata (Sql.get ar#title)];
            p [pcdata ("Created at "^(to_string (Sql.get ar#created)))];
            p [pcdata 
                ("Last modified at "^(to_string(Sql.get ar#lastmodified)))];
            div ~a:[a_id "table_of_contents"] [];
            div ~a:[a_id "content"; a_class ["article"]][];
            nav [
              ul ~a:[a_class ["pager"]]
              [
                li ~a:[a_class ["previous"]] previous;
                li ~a:[a_class ["next"]] next
              ]
            ]])
      in
      let%lwt bdc = bdc in
      let%lwt body = body in
      ignore [%client (genTableOfContents():unit)] ;
      close_dbs();
      skeleton (Sql.get ar#title) [bdc;body])

(*let%client _ = Eliom_lib.alert "Hello!"*)
