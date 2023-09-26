open Soup

let domain = [ "www.theregister.com"; "theregister.com" ]
let get_title input = input $ "h1" |> R.leaf_text
let get_publish input = input $ ".dateline" |> to_string
let get_author input = input $ ".byline" |> R.leaf_text

let get_content input =
  input
  $$ "#body > *"
  |> to_list
  |> List.map (fun x ->
    if Option.is_none (x $? "noscript")
    then (
      Parse.convert_a x "theregister";
      if name x = "p"
      then to_string x
      else if name x = "ul"
      then (
        delete_attribute "class" x;
        to_string x)
      else if name x = "h3"
      then to_string x
      else "")
    else "")
  |> String.concat ""
;;

let parse req =
  let%lwt parsed = Parse.parse req domain in
  let website : Parse.website =
    { domain
    ; tags = []
    ; title = get_title parsed
    ; publish = get_publish parsed
    ; author = get_author parsed
    ; content = get_content parsed
    ; name = "The Register"
    }
  in
  Lwt.return @@ Parse.convert website
;;
