(* Define the App and services *)

module OCamlTW_app =
  Eliom_registration.App (struct
    let application_name = "OCamlTW"
    let global_data_path = None
  end)

let () = Eliom_config.set_default_links_xhr false

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
