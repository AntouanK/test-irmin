#!/bin/bash

opam pin add -yn ppx_irmin.dev './' && \
    opam pin add -yn irmin.dev './' && \
    opam pin add -yn irmin-unix.dev './' && \
    opam pin add -yn irmin-type.dev './' && \
    opam pin add -yn irmin-test.dev './' && \
    opam pin add -yn irmin-pack.dev './' && \
    opam pin add -yn irmin-mirage.dev './' && \
    opam pin add -yn irmin-mirage-graphql.dev './' && \
    opam pin add -yn irmin-mirage-git.dev './' && \
    opam pin add -yn irmin-mem.dev './' && \
    opam pin add -yn irmin-layers.dev './' && \
    opam pin add -yn irmin-http.dev './' && \
    opam pin add -yn irmin-graphql.dev './' && \
    opam pin add -yn irmin-git.dev './' && \
    opam pin add -yn irmin-fuzz.dev './' && \
    opam pin add -yn irmin-fs.dev './' && \
    opam pin add -yn irmin-containers.dev './' && \
    opam pin add -yn irmin-chunk.dev './' && \
    opam pin add -yn irmin-bench.dev './'

opam install .;

dune external-lib-deps --missing @@default;

echo 'install gnuplot!';

opam install alcotest alcotest-lwt astring base64 bechamel bheap cmdliner cohttp cohttp-lwt cohttp-lwt-unix conduit conduit-lwt conduit-lwt-unix conduit-mirage crowbar cstruct digestif fmt fpath git git-mirage git-unix graphql graphql-cohttp graphql-lwt graphql_parser hex index irmin-watcher jsonm logs lwt metrics metrics-lwt metrics-unix mirage-clock mirage-kv mtime ocamlgraph ppx_deriving_yojson ppxlib ptime uri uutf webmachine yaml yojson

dune build;

