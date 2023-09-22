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
    x
    $$ "a"
    |> to_list
    |> List.iter (fun y ->
      let href = R.attribute "href" y in
      if String.starts_with ~prefix:"https://www.makeuseof.com" href
      then
        set_attribute
          "href"
          ("/makeuseof" ^ String.sub href 26 (String.length href - 26))
          y);
    if name x = "p"
    then to_string x
    else if name x = "h2"
    then to_string x
    else (
      let img = x $? "img" in
      if Option.is_some img
      then (
        let img = Option.get img in
        List.iter
          (fun y -> delete_attribute y img)
          [ "width"; "height"; "class"; "style" ];
        set_attribute "src" ("/proxy/" ^ Option.get @@ attribute "data-img-url" img) img;
        delete_attribute "data-img-url" img;
        to_string img)
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
