#!/bin/bash

set -e;
eval $(opam env);

dune external-lib-deps --missing @@default;

dune build;
