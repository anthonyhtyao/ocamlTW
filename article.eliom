[%%shared
    open Eliom_lib
    open Eliom_content
    open Html.D
    open CalendarLib.Printer.Calendar
    open Database
    open OCamlTW
]

[%%client

let color_syntax() = 
  Js.Unsafe.eval_string "hljs.initHighlightingOnLoad();"

let show_content content = 
  let cont_node = Dom_html.getElementById "content" in
  cont_node##.innerHTML := (Js.string content)

let syntax_configure() = 
  Js.Unsafe.eval_string 
    "hljs.configure({tabReplace: '  ', 
                     language: 
                       ['OCaml','Python','C++','Java', 'Haskell', 'Ada']});"

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
              (*let ch_space = 
                code_arr.(i)##replace
                (new%js Js.regExp_withFlags (Js.string " ") (Js.string "g")) 
                (Js.string "&ensp;") in*)
              let new_code = 
                (Js.string "<span class='result'>")##concat_2
                code_arr.(i) (Js.string "</span>") in
              code_arr.(i) <- new_code
          done;
          let code_arr = Js.array code_arr in
          let code_content = code_arr##join (Js.string "\n") in
          code##.innerHTML := code_content
      | _ -> 
          (*let newinner = 
            code##.innerHTML##replace 
            (new%js Js.regExp_withFlags (Js.string " ") (Js.string "g")) 
            (Js.string "&ensp;") in
          code##.innerHTML := newinner;*)
          (Js.Unsafe.js_expr "hljs.highlightBlock") code
  done

let gen_table_of_contents() =
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

let () =

  OCamlTW_app.register
    ~service:main_service
    (fun () () ->
      ignore [%client (color_syntax():unit)];
      ignore [%client (highlight_article_syntax():unit)];
      close_dbs();
      Ui.skeleton 
        "OCamlTW"
        [
         h1 ~a:[a_class ["test"]] [pcdata "Welcome to OcamlTW!"];
         h2 ~a:[a_class ["border"]] [pcdata "我們將在這裡介紹Ocaml!!!!!"];
         h3 [pcdata "歡迎多多來參觀"];
         pre [code [pcdata "let x = 10 in"]];
         ul [li [a ~service:ocamltuto_service [pcdata "OCamltuto"] ()];
             li [a ~service:related_service [pcdata "related"] ()]]]);

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
      ignore [%client (show_content ~%content:unit)] ;
      ignore [%client (syntax_configure():unit)] ;
      ignore [%client (highlight_article_syntax():unit)] ;
      let is_chapter_page = (Sql.getn cat#article) = (Some (Sql.get ar#id)) in 
      let bdc = match is_chapter_page, Sql.getn cat#article with
        | false, Some chap_ar_id ->
            let%lwt chap_ar = find_light_article_id chap_ar_id in
            Lwt.return 
              (Ui.breadcrumbs
              [ `Service_s(main_service, "Home"); 
                `Service_s(rel, Sql.get theme#label);
                `Service_ar(article_service, Sql.get chap_ar#title, 
                            ar_theme, Sql.get chap_ar#slg);
                `Service_ar(article_service, Sql.get ar#title, "", "")])
        | _ -> 
            Lwt.return
              (Ui.breadcrumbs
              [ `Service_s(main_service, "Home"); 
                `Service_s(rel, Sql.get theme#label);
                `Service_ar(article_service, Sql.get ar#title, "", "")])
      in
      let body = if is_chapter_page then
        let%lwt sec =
          Methods.section_of_chap (Sql.get ar#category) (Sql.get ar#id) in
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
      ignore [%client (gen_table_of_contents():unit)] ;
      close_dbs();
      Ui.skeleton (Sql.get ar#title) [bdc;body])
