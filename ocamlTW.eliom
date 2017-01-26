[%%shared
    open Eliom_lib
    open Eliom_content
    open Html.D
]


(* App module *)

module OCamlTW_app =
  Eliom_registration.App (
    struct
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

let navbar () =
  nav ~a:[a_class ["navbar"; "navbar-default"]] 
  [
    div ~a:[a_class ["navbar-header"]]
    [
      a ~service:main_service ~a:[a_class ["navbar-brand"]] 
      [
        ul ~a:[a_class ["list-inline"]]
        [
          li [pcdata "OCAML"];
          li [img ~alt:("Ocaml Logo")
              ~src:(make_uri ~service:(Eliom_service.static_dir ()) ["fig";"ocaml.png"])
              ~a:[a_width 25]
              ()
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

(* Import .css file in head *)

let skeleton title_name body_content = 
  Lwt.return 
    (html
      (head (title (pcdata title_name)) 
        [css_link ~uri:(make_uri (Eliom_service.static_dir ())
                          ["css";"bootstrap.min.css"]) ();
         css_link ~uri:(make_uri (Eliom_service.static_dir ())
                          ["css";"ocamlTW.css"]) ();])
      (body (navbar()::body_content)))

let test () =
    div ~a:[a_class ["col-md-6"]]
    [div ~a:[a_class ["panel";"panel-default"]]
     [div ~a:[a_class ["panel-heading"]] [pcdata "This is title"];
      div ~a:[a_class ["panel-body"]] [pcdata "This is content"];
     ]
    ]


(* Register services *)

let () =

  OCamlTW_app.register
    ~service:main_service
    (fun () () ->
      ignore [%client (Dom_html.window##alert (Js.string 
        (Printf.sprintf "Hello")): unit)];
      skeleton 
        "OCamlTW"
        [
         h1 ~a:[a_class ["test"]] [pcdata "Welcome to OcamlTW!"];
         h2 ~a:[a_class ["border"]] [pcdata "我們將在這裡介紹Ocaml!!!!!"];
         h3 [pcdata "歡迎多多來參觀"];
         ul [li [a ~service:ocamltuto_service [pcdata "OCamltuto"] ()];
             li [a ~service:related_service [pcdata "related"] ()]]]);

  OCamlTW_app.register
    ~service:ocamltuto_service
    (fun () () ->
      skeleton "OCaml Tuto"
        [p [a ~service:article_service [pcdata "article"] 
            ("Ocaml-Tuto","art")]]);
        
  OCamlTW_app.register
    ~service:related_service
    (fun () () ->
      skeleton "related"
        [p [a ~service:article_service [pcdata "article"] 
            ("related-articles","art")]]);

  OCamlTW_app.register
    ~service:article_service
    (fun (ar_class,ar_title) () ->
      ignore [%client (Dom_html.window##alert (Js.string 
        (Printf.sprintf "Meow Meow")): unit)];
      skeleton
        ar_title
        [h1 [pcdata "we will put an article here"];
         p [pcdata ("article name: "^ar_title)];
         p [a ~service:main_service [pcdata "home"] ()]])

(*let%client _ = Eliom_lib.alert "Hello!"*)
