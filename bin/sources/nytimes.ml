open Soup

let domain = [ "www.nytimes.com"; "nytimes.com" ]
let get_title input = input $ "h1" |> R.leaf_text
let get_publish input = input $ "time" |> R.attribute "datetime"
let get_author input = input $ ".last-byline" |> R.leaf_text

let get_content input =
  input
  $$ "section[name=\"articleBody\"] > div > div > *"
  |> to_list
  |> List.map (fun x ->
    Parse.convert_a x "msn";
    if name x = "p"
    then to_string x
    else (
      let img = x $? "img" in
      if Option.is_some img
      then (
        let img = Option.get img in
        (to_string @@ Parse.update_img img) ^ to_string (x $ "figcaption"))
      else ""))
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
    ; name = "New York Times"
    }
  in
  Lwt.return @@ Parse.convert website
;;
