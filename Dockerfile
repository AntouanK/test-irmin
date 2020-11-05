FROM ocurrent/opam

USER root
RUN mkdir -p /home/opam/irmin
RUN chown -R opam /home/opam

WORKDIR /home/opam
USER opam

RUN sudo apt-get update
RUN sudo apt-get install -y m4
RUN sudo apt-get install -y gnuplot
RUN sudo apt-get install -y pkg-config
RUN sudo apt-get install -y libgmp-dev

RUN opam repository set-url default https://opam.ocaml.org

############################################################################

RUN opam update;
RUN opam install dune;

WORKDIR /home/opam/irmin

COPY ./src ./src
COPY ./examples ./examples

COPY ./irmin-bench.opam .
COPY ./irmin-chunk.opam .
COPY ./irmin-containers.opam .
COPY ./irmin-fs.opam .
COPY ./irmin-fuzz.opam .
COPY ./irmin-git.opam .
COPY ./irmin-graphql.opam .
COPY ./irmin-http.opam .
COPY ./irmin-layers.opam .
COPY ./irmin-mem.opam .
COPY ./irmin-mirage-git.opam .
COPY ./irmin-mirage-graphql.opam .
COPY ./irmin-mirage.opam .
COPY ./irmin.opam .
COPY ./irmin-pack.opam .
COPY ./irmin-test.opam .
COPY ./irmin-type.opam .
COPY ./irmin-unix.opam .
COPY ./ppx_irmin.opam .

RUN opam pin add -yn ppx_irmin.dev './' && \
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

RUN opam install .

COPY ./.ocamlformat .
COPY ./.ocamlformat-ignore .
COPY ./dune-project .

# chown again all the copied files
USER root
RUN chown -R opam /home/opam
USER opam

COPY ./docker-install.sh .
RUN ./docker-install.sh

COPY ./docker-run.sh .
CMD ./docker-run.sh

