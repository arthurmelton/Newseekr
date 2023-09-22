open Option
open Sources

let get_domain url = List.nth (String.split_on_char '/' url) 2

let get_path url =
  String.split_on_char '/' url |> List.tl |> List.tl |> List.tl |> String.concat "/"
;;

let find req =
  let url = get @@ Dream.query req "url" in
  let domain = get_domain url in
  let name = if List.mem domain Theverge.domain then some "theverge" else none in
  if is_some name
  then Dream.redirect req @@ "/" ^ get name ^ "/" ^ get_path url
  else Dream.html @@ Core.In_channel.read_all "static/url_not_supported.html"
;;
