open Core

let () =
  Dream.run
    ~port:(Option.value (Sys.getenv "PORT") ~default:"8080" |> int_of_string)
    ~interface:"0.0.0.0"
  @@ Dream.logger
  @@ Dream.router
       [ Dream.get "/proxy/**" @@ Proxy.return
       ; Dream.get "/static/**" @@ Dream.static "static"
       ; Dream.get "/submit" @@ Submit.find
       ; Dream.get "/" (fun _ ->
           Dream.html @@ In_channel.read_all "static/index.html")
         (* Service parser replaced here (/preprocceser.sh) *)
       ]
;;
