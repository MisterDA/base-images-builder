# escape=`
FROM ocaml/opam:windows-mingw-ltsc2022-ocaml-4.14
ARG OPAMJOBS
ENV CAPNP_VERSION=0.10.4
ADD https://capnproto.org/capnproto-c++-win32-$CAPNP_VERSION.zip capnproto-c++-win32-$CAPNP_VERSION.zip
RUN C:\cygwin64\bin\bash.exe --login -c "unzip -j capnproto-c++-win32-$CAPNP_VERSION.zip capnproto-tools-win32-$CAPNP_VERSION/capnp.exe -d /usr/bin"
RUN opam repo add --rank=3 opam-repository git+https://github.com/ocaml/opam-repository
RUN ocaml-env exec -- opam depext -yi conf-gmp conf-graphviz conf-sqlite3 conf-libffi
RUN git clone --recursive https://github.com/ocurrent/ocluster.git
RUN opam config set-global jobs %OPAMJOBS%
RUN git config --global --add safe.directory /home/opam/ocluster && `
    git config --global --add safe.directory /home/opam/ocluster/obuilder
