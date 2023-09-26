open Soup

let domain = [ "www.foxnews.com"; "foxnews.com" ]

let get_tags input =
  input $$ ".article-meta > .eyebrow > a" |> to_list |> List.map R.leaf_text
;;

let get_title input = input $ "h1.headline" |> R.leaf_text
let get_publish input = input $ ".article-date > time" |> R.leaf_text

let get_author input =
  input
  $$ ".author-byline > *"
  |> to_list
  |> List.filter (fun y -> not @@ List.mem "author-headshot" @@ classes y)
  |> List.hd
  $ "span"
  |> texts
  |> List.hd
;;

let get_content input =
  input
  $$ ".article-body > *"
  |> to_list
  |> List.map (fun x ->
    Parse.convert_a x "foxnews";
    if name x = "p"
    then (
      delete_attribute "class" x;
      let a = x $? "a" in
      if Option.is_some a
         && texts x |> List.hd = (Option.get a |> R.leaf_text)
      then ""
      else to_string x)
    else if name x = "div" && (List.mem "image-ct" @@ classes x)
    then (
      let img = x $? "img" in
      if Option.is_some img
      then (
        let img = Parse.update_img @@ Option.get img in
        let info = x $ ".info > .caption > p" in
        to_string img ^ to_string info)
      else "")
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
    ; name = "Fox News"
    }
  in
  Lwt.return @@ Parse.convert website
;;
