#!/usr/bin/env bash

set -ex
shopt -s nullglob

case $1 in
    1)
        ocaml-env exec -- opam pin --no-action -y cmdliner.1.1.0 'git+https://github.com/dbuenzli/cmdliner.git#a89ae0aa42aec20744bc066a753bc586954d06c7'
        ocaml-env exec -- opam pin --no-action -y lwt.5.5.0 'git+https://github.com/MisterDA/lwt.git#windows-fixes'
        ocaml-env exec -- opam pin --no-action -y tcpip.7.0.1 'git+https://github.com/mirage/mirage-tcpip.git#42bed9fd75a31dbc49ae861b3e738964347a7cc6'
        ocaml-env exec -- opam pin --no-action -y mirage-crypto.0.10.5 'git+https://github.com/MisterDA/mirage-crypto.git#a08015bc333662f753ad89419062b253d63b49fc'
        ocaml-env exec -- opam pin --no-action -y mirage-crypto-ec.0.10.5 'git+https://github.com/MisterDA/mirage-crypto.git#a08015bc333662f753ad89419062b253d63b49fc'
        ;;
    2)
        pushd ocluster || exit
        git fetch MisterDA
        git switch windows
        git submodule update --recursive
        popd || exit
        ;;
    3)
        pushd ocluster/obuilder || exit
        ocaml-env exec -- opam install --deps-only --with-test -y .
        popd || exit
        ;;
    4)
        pushd ocluster || exit
        ocaml-env exec -- opam install --deps-only --with-test -y .
        popd || exit
        ;;
    extract)
        PROFILE=debug

        pushd ocluster || exit
        mkdir -p install
        ocaml-env exec -- dune build @install --profile=$PROFILE --root=.
        ocaml-env exec -- dune install --prefix=install --relocatable --root=.

        OUTPUT=ocluster/install/bin
        for dir in ocluster/install/bin; do
            for exe in "$dir"/*.exe ; do
                for dll in $(PATH="/usr/x86_64-w64-mingw32/sys-root/mingw/bin:$PATH" cygcheck "$exe" | grep -F x86_64-w64-mingw32 | sed -e 's/^ *//'); do
                    if [ ! -e "$OUTPUT/$(basename "$dll")" ] ; then
                        cp "$dll" "$OUTPUT/"
                    fi
                done
            done
        done
        ;;
esac
