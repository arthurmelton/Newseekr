(lang dune 3.10)

(name newseekr)

(generate_opam_files true)

(source
 (github arthurmelton/newseekr))

(authors "Arthur Melton")

(maintainers "Arthur Melton")

(license "AGPL-3.0-only")

(package
 (name newseekr)
 (synopsis "An alternative frontend for your favorate news outlets")
 (description "An alternative frontend for your favorate news outlets")
 (depends ocaml dune lambdasoup dream core cohttp-lwt-unix lwt_ssl))
