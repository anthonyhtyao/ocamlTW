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

let () =
  OcamlTW_app.register
    ~service:main_service
    (fun () () ->
      Lwt.return
        (Eliom_tools.F.html
           ~title:"ocamlTW"
           ~css:[["css";"ocamlTW.css"]]
           Html.F.(body [
             h1 [pcdata "Welcome to OcamlTW!"];
             h2 [pcdata "我們將在這裡介紹Ocaml!!!!!"];
             h3 [pcdata "歡迎多多來參觀"];
           ])))
