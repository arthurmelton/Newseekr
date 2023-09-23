open Soup

let domain = [ "www.theverge.com"; "theverge.com" ]

let get_tags input =
  input $$ "ul.article-groups > * > a" |> to_list |> List.map R.leaf_text
;;

let get_title input = input $ "h1" |> R.leaf_text
let get_publish input = input $ "time" |> R.attribute "datetime"

let get_author input =
  input
  $ ".duet--article--article-byline > span + span > span + span > a"
  |> R.leaf_text
;;

let get_content input =
  input
  $$ ".duet--article--article-body-component-container > div > \
      .duet--article--article-body-component"
  |> to_list
  |> List.map (fun x ->
    if Option.is_none (x $? ".duet--article--sidebar")
    then (
      x
      $$ "a"
      |> to_list
      |> List.iter (fun y ->
        let href = R.attribute "href" y in
        if String.starts_with ~prefix:"/" href
        then set_attribute "href" ("/theverge" ^ href) y);
      let p = x $? "> p" in
      if Option.is_some p
      then (
        let p = Option.get p in
        p |> delete_attribute "class";
        p |> to_string)
      else (
        let img = x $? "img[srcset]" in
        if Option.is_some img
        then (
          let img = Option.get img in
          let img_src =
            "/proxy/"
            ^ (R.attribute "srcset" img
               |> String.split_on_char ' '
               |> List.rev
               |> fun y -> List.nth y 1)
          in
          [ "decoding"; "data-nimg"; "style"; "srcset"; "loading"; "sizes" ]
          |> List.iter (fun y -> delete_attribute y img);
          set_attribute "src" img_src img;
          let caption = x $$ ".duet--media--caption > *" |> to_list in
          caption |> List.iter (delete_attribute "class");
          (img |> to_string)
          ^ (caption |> List.map to_string |> String.concat ""))
        else (
          let ul = x $? "ul" in
          if Option.is_some ul
          then (
            let ul = Option.get ul in
            delete_attribute "class" ul;
            ul $$ "li" |> to_list |> List.iter (delete_attribute "class");
            ul |> to_string)
          else "")))
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
    ; name = "The Verge"
    }
  in
  Lwt.return @@ Parse.convert website
;;
