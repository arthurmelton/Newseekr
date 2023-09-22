# Newseekr
An alternative frontend for your favorite news outlets

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

- [The Verge](https://theverge.com)
