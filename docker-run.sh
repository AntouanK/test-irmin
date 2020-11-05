#!/bin/bash

set -e;
eval $(opam env);

dune exec examples/custom_graphql.exe;