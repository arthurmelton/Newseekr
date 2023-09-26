let[@ocamlformat "disable"] error_template _error _debug_info suggested_response =
  let status = Dream.status suggested_response in
  let code = Dream.status_to_int status
  and reason = Dream.status_to_string status in
  Dream.set_header suggested_response "Content-Type" Dream.text_html;
  let response = [ "<!DOCTYPE html>"
    ; "<html>"
    ;   "<head>"
    ;     "<title>Newseekr - "; reason; "</title>"
    ;     "<link rel=\"stylesheet\" href=\"/static/main.css\">"
    ;   "</head>"
    ;   "<body>"
    ;     "<h1 class=\"center\">"; string_of_int code; " - "; reason;"</h1>"
    ;     "<hr>"
    ;     "<p>"; (
        match String.get (string_of_int code) 0 with
          | '4' -> "This looks like you might have tried going to the wrong page." 
          | '5' -> "Oops, looks like we made an error. This is probably something that should be reported!"
          | _ -> "" (* should never happen *)
        ); "</p>"
    ;     "Please report this issue to <a href=\"https://github.com/arthurmelton/newseekr/issues\">https://github.com/arthurmelton/newseekr/issues</a> if you believe this is an error."
    ;   "</body>"
    ; "</html>"
    ]
    |> String.concat "" in
  Dream.set_body suggested_response response;
  Lwt.return suggested_response
