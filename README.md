# Newseekr
An alternative frontend for your favorite news outlets! Do note though that
using this will not show ads and in effect make the new outlet loose money.

## Requirements

- [Opam/Ocaml](https://ocaml.org/docs/up-and-running#installation-on-unix)

## Configuration

All of the settings are changed through environment variables

- `PORT`=`8080`

## Running

For running on a server and production you should use `flambda` for compiling. To tell opam to do so, you can do the following:

```sh
opam switch create 4.14.0+flambda ocaml-variants.4.14.0+options ocaml-option-flambda
eval (opam env --switch=4.14.0+flambda)
```

To compile the program you will run the following:

```sh
git clone https://github.com/arthurmelton/newseekr
cd newseekr
opam install . --deps-only
dune build --release newseekr
```

Your executable will be at

```sh
_build/default/bin/main.exe
```

## Supports

- [CNN](https://cnn.com)
- [Fox News](https://foxnews.com)
- [Make Use Of](https://makeuseof.com)
- [The Register](https://theregister.com)
- [The Verge](https://theverge.com)
- [Wired](https://wired.com)
