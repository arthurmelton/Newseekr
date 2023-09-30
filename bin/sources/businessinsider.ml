open Soup

let domain = [ "www.businessinsider.com"; "businessinsider" ]
let get_title input = input $ "h1.post-headline" |> R.leaf_text

let get_publish input =
  input $ ".byline-timestamp" |> R.attribute "data-timestamp"
;;

let get_author input =
  input
  $$ ".byline-author > span"
  |> to_list
  |> List.map R.leaf_text
  |> Parse.join_strings
;;

let get_content input =
  input
  $$ ".content-lock-content > *"
  |> to_list
  |> List.map (fun x ->
    Parse.convert_a x "businessinsider";
    if List.mem (name x) [ "p"; "h2" ]
    then Parse.to_string_classless x
    else if name x = "figure"
    then (
      let img = x $ "img" in
      to_string
        (Parse.update_img
           ~src:
             (R.attribute "data-srcs" img
              |> String.split_on_char '\"'
              |> fun y -> List.nth y 1)
           img)
      ^ (x $ ".image-source-caption" |> Parse.to_string_classless))
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
    ; name = "Business Insider"
    }
  in
  Lwt.return @@ Parse.convert website
;;
