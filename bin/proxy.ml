open Cohttp_lwt_unix
open Cohttp
open Lwt.Syntax

let return req =
  let url =
    Dream.target req
    |> String.split_on_char '/'
    |> List.tl
    |> List.tl
    |> String.concat "/"
  in
  let* resp, body = Client.get @@ Uri.of_string url in
  let* body = Cohttp_lwt.Body.to_string body in
  Dream.respond
    ~headers:
      [ ( "Content-Type"
        , resp
          |> Response.headers
          |> fun y -> Header.get y "Content-Type" |> Option.get )
      ]
    body
;;
