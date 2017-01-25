
(* Services *)

let main_service = Eliom_service.create
  ~path:(Eliom_service.Path [""])
  ~meth:(Eliom_service.Get Eliom_parameter.unit)
  ()

let user_service = Eliom_service.create
  ~path:(Eliom_service.Path ["users"])
  ~meth:(Eliom_service.Get (Eliom_parameter.(suffix (string "name"))))
  ()

let connection_service = Eliom_service.create_attached_post
  ~fallback:main_service
  ~post_params:Eliom_parameter.(string "name" ** string "password")
  ()


(* User names and passwords: *)

let users = ref [("cybermeow", "meow"); ("kyo", "kk")]

let user_links = Eliom_content.Html.D.(
  let link_of_user = fun (name, _) ->
    li [a ~service:user_service [pcdata name] name]
  in
  fun () -> ul (List.map link_of_user !users)
)


(* Services Registration *)

let check_pwd name pwd =
  try List.assoc name !users = pwd with _ -> false

let connection_box () = Eliom_content.Html.D.(
  Form.post_form 
    ~service:connection_service
    (fun (name1, name2) ->
      [fieldset
          [label [pcdata "login: "];
           Form.input
            ~input_type:`Text ~name:name1
            Form.string;
           br();
           label [pcdata "password: "];
           Form.input 
             ~input_type: `Password ~name:name2
             Form.string;
           br();
           Form.input
             ~input_type:`Submit ~value:"Connect"
             Form.string
      ]]) ()
)

let () = Eliom_content.Html.D.(

  Eliom_registration.Html.register
    ~service:main_service
    (fun () () ->
      Lwt.return
       (html
          (head (title (pcdata "")) [])
          (body [h1 [pcdata "Hello"]; connection_box(); user_links ()])));

  Eliom_registration.Html.register
    ~service:user_service
    (fun name () ->
      Lwt.return
        (html 
          (head (title (pcdata name)) [])
          (body [h1 [pcdata name];
                 p [a ~service:main_service [pcdata "Home"] ()]])));
  
  Eliom_registration.Html.register
    ~service:connection_service
    (fun () (name, password) ->
      let message = 
        if check_pwd name password
        then "Hello" ^ name 
        else "Wrong name or password"
      in
      Lwt.return
        (html (head (title (pcdata "")) [])
            (body [h1 [pcdata message]; user_links ()])))
)

let%client _ = Eliom_lib.alert "Hello!"
