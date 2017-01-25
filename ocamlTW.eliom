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

let skeleton title_name body_content = 
  Lwt.return 
    (html
      (head (title (pcdata title_name)) [])
      (body body_content))

let () =

  OcamlTW_app.register
    ~service:main_service
    (fun () () ->
      ignore [%client (Dom_html.window##alert (Js.string 
        (Printf.sprintf "Hello")): unit)];
      skeleton 
        "ocamlTW"
        [h1 [pcdata "Welcome to OcamlTW!"];
         h2 [pcdata "我們將在這裡介紹Ocaml!!!!!"];
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
