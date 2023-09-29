open Core

let loader _root path _request =
  match Assets.read path with
  | None -> Dream.empty `Not_Found
  | Some asset -> Dream.respond asset
;;

let () =
  Dream.run
    ~port:(Option.value (Sys.getenv "PORT") ~default:"8080" |> int_of_string)
    ~interface:"0.0.0.0"
    ~error_handler:(Dream.error_template Res_error.error_template)
  @@ Dream.logger
  @@ Dream.router
       [ Dream.get "/proxy/**" @@ Proxy.return
       ; Dream.get "/static/**" @@ Dream.static ~loader ""
       ; Dream.get "/submit" @@ Submit.find
       ; Dream.get "/" (fun _ ->
           Dream.html
           @@ Option.value ~default:""
           (* For some reason doing Option.get here fails *)
           @@ Assets.read "index.html")
         (* Service parser replaced here (/preprocceser.sh) *)
       ]
;;
