open Soup

let domain = [ "www.makeuseof.com"; "makeuseof.com" ]
let get_title input = input $ "h1.heading_title" |> R.leaf_text
let get_publish input = input $ "time" |> R.attribute "datetime"
let get_author input = input $ "a.author" |> R.leaf_text

let get_content input =
  input
  $$ ".content-block-regular > *"
  |> to_list
  |> List.map (fun x ->
    Parse.convert_a x "makeuseof";
    if name x = "p"
    then Parse.to_string_classless x
    else if name x = "h2"
    then Parse.to_string_classless x
    else (
      let img = x $? "img" in
      if Option.is_some img
      then (
        let img = Option.get img in
        Parse.to_string_classless
        @@ Parse.update_img ~src:(R.attribute "data-img-url" img) img)
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
    ; name = "Make Use Of"
    }
  in
  Lwt.return @@ Parse.convert website
;;
