open%shared Eliom_content
open Html.D
open OCamlTW

(* Navbar *)

let navbar () =
  nav ~a:[a_class ["navbar"; "navbar-default"]] 
  [
    div ~a:[a_class ["col-md-8";"col-md-offset-2"]]
    [
      div ~a:[a_class ["navbar-header"]]
      [
        a ~service:main_service ~a:[a_class ["navbar-brand"]] 
        [
          ul ~a:[a_class ["list-inline"]]
          [
            li ~a:[a_class ["logo-text"]] [pcdata "OCAML TW"];
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
          li [a ~service:related_service [pcdata "related"] ()];
          li []
        ]
      ]
    ]
  ]

(* Breadcrumbs *)

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

(* Footer, scroll to top when click "To Top" *)

let footer () =
  let top =
    p ~a:[a_id "back-top"; a_class ["hidden"]]
      [span []; pcdata "To Top"]
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
                          ["css";"rainbow.css"]) ();
         js_script ~uri:(make_uri (Eliom_service.static_dir ())
                          ["js";"highlight.pack.js"]) ();])
      (body (navbar()::
              [div ~a:[a_class ["col-md-8";"col-md-offset-2";"content"]] 
               body_content] @ footer ())))
