open Soup

let domain = [ "www.wired.com"; "wired.com" ]
let get_tags input = [ input $ ".rubric__link > span" |> to_string ]
let get_title input = input $ "h1" |> R.leaf_text
let get_publish input = input $ "time" |> R.attribute "datetime"
let get_author input = input $ ".byline__name-link" |> R.leaf_text

let get_content input =
  input
  $$ ".body__inner-container > *"
  |> to_list
  |> List.map (fun x ->
    Parse.convert_a x "wired";
    if name x = "p" then Parse.to_string_classless x else "")
  |> String.concat ""
;;

let parse req =
  let%lwt parsed = Parse.parse req domain in
  let website : Parse.website =
    { domain
    ; tags = get_tags parsed
    ; title = get_title parsed
    ; publish = get_publish parsed
    ; author = get_author parsed
    ; content = get_content parsed
    ; name = "Wired"
    }
  in
  Lwt.return @@ Parse.convert website
;;
