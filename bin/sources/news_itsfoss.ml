open Soup

let domain = [ "news.itsfoss.com" ]
let get_tags input = input $$ ".c-topper__content > .c-tag > *" |> to_list |> List.map R.leaf_text
let get_title input = input $ ".c-topper__headline" |> R.leaf_text
let get_publish input = input $ "time" |> R.attribute "datetime"
let get_author input = input $ ".c-topper__byline > a" |> R.leaf_text

let get_content input =
  input
  $$ ".c-content  > *"
  |> to_list
  |> List.map (fun x ->
    Parse.convert_a x "news_itsfoss";
    if List.mem (name x) [ "p"; "blockquote"; "h2" ] && not ((id x) = (Option.some "more-from-its-foss"))
    then Parse.to_string_classless x
    else if name x = "figure"
    then Parse.update_img (x $ "img") |> to_string
    else "")
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
    ; name = "Its Foss News"
    }
  in
  Lwt.return @@ Parse.convert website
;;
