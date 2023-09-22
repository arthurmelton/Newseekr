open Cohttp_lwt_unix
open Lwt.Syntax

type website =
  { domain : string list
  ; tags : string list
  ; title : string
  ; publish : string
  ; author : string
  ; content : string
  ; name : string
  }

let new_url domain path =
  "https://"
  ^ domain
  ^ "/"
  ^ (path |> String.split_on_char '/' |> List.tl |> List.tl |> String.concat "/")
;;

let[@ocamlformat "disable"] convert website =
  "<!DOCTYPE html>"
^ "<html>"
^   "<head>"
^     "<title>" ^ website.name ^ " - " ^ website.title ^ "</title>"
^     "<link rel=\"stylesheet\" href=\"/static/main.css\">"
^   "</head>"
^     "<body>"
^        "<p id=\"tags\">" ^ String.concat " " website.tags ^ "</p>"
^        "<h1>" ^ website.title ^ "</h1>"
^        "<p id=\"author\">By " ^ website.author ^ "</p>"
^        "<hr>"
^        website.content
^     "</body>"
^  "</html>"

let parse req domains =
  let url = new_url (List.nth domains 0) (Dream.target req) in
  let* _, body = Client.get @@ Uri.of_string url in
  let* body = Cohttp_lwt.Body.to_string @@ body in
  Lwt.return @@ Soup.parse body
;;
