[%%shared
    open Eliom_lib
    open Eliom_content
    open Html.D
]

module OcamlTW_app =
  Eliom_registration.App (
    struct
      let application_name = "ocamlTW"
      let global_data_path = None
    end)

let main_service =
  Eliom_service.create
    ~path:(Eliom_service.Path [])
    ~meth:(Eliom_service.Get Eliom_parameter.unit)
    ()

let article_service = 
  Eliom_service.create
    ~path:(Eliom_service.Path [])
    ~meth:(Eliom_service.Get Eliom_parameter.(suffix (string "ar_title")))
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

let () =

  OcamlTW_app.register
    ~service:main_service
    (fun () () ->
      ignore [%client (Dom_html.window##alert (Js.string 
        (Printf.sprintf "Hello")): unit)];
      skeleton 
        "ocamlTW"
        [
         test ();
         h1 ~a:[a_class ["test"]] [pcdata "Welcome to OcamlTW!"];
         h2 ~a:[a_class ["border"]] [pcdata "我們將在這裡介紹Ocaml!!!!!"];
         h3 [pcdata "歡迎多多來參觀"];
         p [a ~service:article_service [pcdata "An article"] "article"]]);

  OcamlTW_app.register
    ~service:article_service
    (fun ar_title () ->
      ignore [%client (Dom_html.window##alert (Js.string 
        (Printf.sprintf "Meow Meow")): unit)];
      skeleton
        ar_title
        [h1 [pcdata "we will put an article here"];
         p [pcdata ("article name: "^ar_title)]])

(*let%client _ = Eliom_lib.alert "Hello!"*)
