# Newseekr
An alternative frontend for your favorite news outlets! Do note though that
using this will not show ads and in effect make the new outlet loose money.

## Requirements

- [Opam/Ocaml](https://ocaml.org/docs/up-and-running#installation-on-unix)

## Configuration

All of the settings are changed through environment variables

- `PORT`=`8080`

## Running

```sh
git clone https://github.com/arthurmelton/newseekr
cd newseekr
opam install . --deps-only
dune exec newseekr --release
```

## Supports

- [Make Use Of](https://makeuseof.com)
- [The Register](https://theregister.com)
- [The Verge](https://theverge.com)
- [Wired](https://wired.com)
