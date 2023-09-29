open Soup

let domain = [ "www.cnn.com"; "cnn.com" ]
let get_title input = input $ ".headline__text" |> R.leaf_text
let get_publish input = input $ ".timestamp" |> R.leaf_text
let get_author input = input $ ".byline__name" |> R.leaf_text

let get_content input =
  input
  $$ ".article__content > *"
  |> to_list
  |> List.map (fun x ->
    Parse.convert_a x "cnn";
    List.iter
      (fun y -> delete_attribute y x)
      [ "class"
      ; "data-uri"
      ; "data-editable"
      ; "data-component-name"
      ; "data-article-gutter"
      ];
    if name x = "p"
    then Parse.to_string_classless x
    else (
      let img = x $? ".image__picture > img" in
      if Option.is_some img
      then
        to_string (Parse.update_img @@ Option.get img)
        ^ Parse.to_string_classless (x $ ".image__metadata")
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
    ; name = "CNN"
    }
  in
  Lwt.return @@ Parse.convert website
;;
