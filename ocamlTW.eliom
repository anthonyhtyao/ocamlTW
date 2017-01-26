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


(* Import .css file in head *)

let skeleton title_name body_content = 
  Lwt.return 
    (html
      (head (title (pcdata title_name)) 
        [css_link ~uri:(make_uri (Eliom_service.static_dir ())
                          ["css";"bootstrap.min.css"]) ();
         css_link ~uri:(make_uri (Eliom_service.static_dir ())
                          ["css";"ocamlTW.css"]) ();])
      (body body_content))

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
        [test ();
         h1 ~a:[a_class ["test"]] [pcdata "Welcome to OCamlTW!"];
         h2 ~a:[a_class ["border"]] [pcdata "我們將在這裡介紹OCaml!!!!!"];
         h3 [pcdata "歡迎多多來參觀"];
         p [a ~service:article_service [pcdata "An article"] ("t","article")]]);

  OCamlTW_app.register
    ~service:ocamltuto_service
    (fun () () ->
      skeleton "OCaml Tuto"
        [p [a ~service:article_service [pcdata "article"] ("class","art")]]);
        

  OCamlTW_app.register
    ~service:article_service
    (fun (ar_class,ar_title) () ->
      ignore [%client (Dom_html.window##alert (Js.string 
        (Printf.sprintf "Meow Meow")): unit)];
      skeleton
        ar_title
        [h1 [pcdata "we will put an article here"];
         p [pcdata ("article name: "^ar_title)]])

(*let%client _ = Eliom_lib.alert "Hello!"*)
