open Cohttp_lwt_unix
open Lwt.Syntax
open Soup

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
  [ "https://"
  ; domain
  ; "/"
  ; path
    |> String.split_on_char '/'
    |> List.tl
    |> List.tl
    |> String.concat "/"
  ]
  |> String.concat ""
;;

let[@ocamlformat "disable"] convert website =
  [ "<!DOCTYPE html>"
  ; "<html>"
  ;   "<head>"
  ;     "<title>"; website.name; " - "; website.title; "</title>"
  ;     "<link rel=\"stylesheet\" href=\"/static/main.css\">"
  ;   "</head>"
  ;   "<body>"
  ;     "<p id=\"tags\">"; String.concat " / " website.tags; "</p>"
  ;     "<h1>"; website.title; "</h1>"
  ;     "<p id=\"author\">By "; website.author; "</p>"
  ;     "<hr>"
  ;     website.content
  ;   "</body>"
  ; "</html>"
  ]
  |> String.concat ""

let parse req domains =
  let url = new_url (List.nth domains 0) (Dream.target req) in
  let* _, body = Client.get @@ Uri.of_string url in
  let* body = Cohttp_lwt.Body.to_string @@ body in
  Lwt.return @@ Soup.parse body
;;

let convert_a node name =
  let name = "/" ^ name in
  node
  $$ "a"
  |> to_list
  |> List.iter (fun y ->
    let href = R.attribute "href" y in
    let new_href =
      if String.starts_with ~prefix:"/" href
      then name ^ href
      else if String.starts_with ~prefix:"//" href
      then
        name
        ^ (String.split_on_char '/' href
           |> List.tl
           |> List.tl
           |> List.tl
           |> String.concat "/")
      else if String.starts_with ~prefix:"https://" href
              || String.starts_with ~prefix:"http://" href
      then (
        let cut =
          if String.starts_with ~prefix:"https://" href then 8 else 7
        in
        let path = String.sub href cut (String.length href - cut) in
        let domain = String.split_on_char '/' path |> List.hd in
        let domain_length = String.length domain in
        let path =
          String.sub path domain_length (String.length path - domain_length)
        in
        let path =
          if String.length path > 1
          then String.sub path 1 (String.length path - 1)
          else path
        in
        let name =
          if false
          then Option.none (* Names replaced here (/preprocceser.sh) *)
          else Option.none
        in
        if Option.is_some name
        then String.concat "" [ "/"; Option.get name; "/"; path ]
        else domain)
      else href
    in
    set_attribute "href" new_href y)
;;

let update_img ?src img =
  let src =
    match src with
    | None ->
      let src = attribute "src" img in
      (match src with None -> "" | Some x -> x)
    | Some x -> x
  in
  let new_img =
    create_element ~attributes:[ "src", "/proxy/" ^ src ] "img"
  in
  let alt = attribute "alt" img in
  if Option.is_some alt then set_attribute "alt" (Option.get alt) new_img;
  new_img
;;
