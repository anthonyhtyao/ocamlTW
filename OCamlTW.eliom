[%%shared
    open Eliom_lib
    open Eliom_content
    open Html.D
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
    ~path:(Eliom_service.Path ["OCaml-tuto"])
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
           Eliom_parameter.(suffix (string "ar_class" ** string "ar_title")))
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

let footer () =
  [
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
                          ["css";"default.css"]) ();
         js_script ~uri:(make_uri (Eliom_service.static_dir ())
                          ["js";"highlight.pack.js"]) ();])
      (body (navbar()::
              [div ~a:[a_class ["col-md-8";"col-md-offset-2";"content"]] 
               body_content] @ footer ())))

let test () =
    div ~a:[a_class ["col-md-6"]]
    [div ~a:[a_class ["panel";"panel-default"]]
     [div ~a:[a_class ["panel-heading"]] [pcdata "This is title"];
      div ~a:[a_class ["panel-body"]] [pcdata "This is content"];
     ]
    ]


let code () = 
    pre
    [
      code
      [pcdata "let x = 10 in"]
    ]

let%client color_syntax = 
  Js.Unsafe.eval_string "hljs.initHighlightingOnLoad();"

(* Register services *)

let () =

  OCamlTW_app.register
    ~service:main_service
    (fun () () ->
      ignore [%client (Dom_html.window##alert (Js.string 
        (Printf.sprintf "Hello")): unit)];
      let _ = [%client (color_syntax():unit)] in
      let%lwt b = check_pwd "hello" "use" in
      let%lwt b2 = check_pwd "heddllo" "use" in
      skeleton 
        "OCamlTW"
        [
         h1 ~a:[a_class ["test"]] [pcdata "Welcome to OcamlTW!"];
         h2 ~a:[a_class ["border"]] [pcdata "我們將在這裡介紹Ocaml!!!!!"];
         h3 [pcdata "歡迎多多來參觀"];
         code ();
         p [pcdata ((if b then "hi" else "qq")^(if b2 then "1" else "2"))];
         ul [li [a ~service:ocamltuto_service [pcdata "OCamltuto"] ()];
             li [a ~service:related_service [pcdata "related"] ()]]]);

  OCamlTW_app.register
    ~service:ocamltuto_service
    (fun () () ->
      skeleton "OCaml Tuto"
        [p [a ~service:article_service [pcdata "Why OCaml?"] 
            ("OCaml-Tuto","why-ocaml")]]);
        
  OCamlTW_app.register
    ~service:related_service
    (fun () () ->
      let%lwt related_ids = articles_of_theme "Related" in
      let related_ids = List.map 
        (fun sqlid -> Sql.get sqlid#id) related_ids in
      let related_ars = List.map find_article_id related_ids in
      let body = Lwt_list.map_s
        (fun ar -> let%lwt ar = ar in Lwt.return (
                   li [a ~service:article_service 
                         [pcdata (Sql.get ar#title)] 
                         ("related-articles", (Sql.get ar#slg));
                       p [pcdata (Sql.get ar#abstract)];
                       a ~service:article_service 
                         [pcdata "read more"]
                         ("related-articles", (Sql.get ar#slg));]))
        related_ars in
      let%lwt body = body in
      skeleton "related" [ul body]);

  OCamlTW_app.register
    ~service:article_service
    (fun (ar_theme,ar_slg) () ->
      (*ignore [%client (Dom_html.window##alert (Js.string 
        (Printf.sprintf "Meow Meow")): unit)];*)
      let%lwt ar = find_article_slg ar_slg in
      skeleton
        (Sql.get ar#title)
        [h1 [pcdata (Sql.get ar#title)];
         p [pcdata (Sql.get ar#content) ];
         p [a ~service:main_service [pcdata "home"] ()]])

(*let%client _ = Eliom_lib.alert "Hello!"*)
