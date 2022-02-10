# escape=`
FROM ocaml/opam:windows-mingw-ocaml-4.13
ARG OPAMJOBS
ADD https://capnproto.org/capnproto-c++-win32-0.9.1.zip capnproto-c++-win32-0.9.1.zip
RUN C:\cygwin64\bin\bash.exe --login -c "unzip capnproto-c++-win32-0.9.1.zip capnproto-tools-win32-0.9.1/\* -d /usr/bin"
RUN ocaml-env exec -- opam depext -yi conf-gmp conf-graphviz conf-sqlite3 conf-libffi
RUN git clone --recursive https://github.com/ocurrent/ocluster.git && `
    cd ocluster && `
    git remote add MisterDA https://github.com/MisterDA/ocluster.git && `
    git fetch MisterDA && `
    cd obuilder && `
    git remote add MisterDA https://github.com/MisterDA/obuilder.git && `
    git fetch MisterDA
RUN opam config set-global jobs %OPAMJOBS%
