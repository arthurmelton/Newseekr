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
    x
    $$ "a"
    |> to_list
    |> List.iter (fun y ->
      let href = R.attribute "href" y in
      if String.starts_with ~prefix:"https://www.cnn.com" href
      then
        set_attribute
          "href"
          ("/cnn" ^ String.sub href 22 (String.length href - 22))
          y);
    List.iter
      (fun y -> delete_attribute y x)
      [ "class"
      ; "data-uri"
      ; "data-editable"
      ; "data-component-name"
      ; "data-article-gutter"
      ];
    if name x = "p"
    then to_string x
    else (
      let img = x $? ".image__picture > img" in
      if Option.is_some img
      then (
        let img = Option.get img in
        List.iter
          (fun y -> delete_attribute y img)
          [ "width"
          ; "height"
          ; "class"
          ; "onload"
          ; "onerror"
          ; "height"
          ; "width"
          ; "loading"
          ];
        set_attribute
          "src"
          ("/proxy/" ^ Option.get @@ attribute "src" img)
          img;
        let metadata = x $ ".image__metadata" in
        delete_attribute "class" metadata;
        to_string img ^ to_string metadata)
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
