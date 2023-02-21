#!/usr/bin/env bash

set -ex
shopt -s nullglob

case $1 in
    1)
        :
        # pushd ~/opam-repository || exit
        # git fetch origin -q opam2
        # git reset --hard $OPAM_SHA
        # rsync -ar --update --exclude='.git' ./ /cygdrive/c/opam/.opam/repo/default
        # ocaml-env exec -- opam update
        # popd || exit
        ;;
    2)
        :
        ocaml-env exec -- opam pin -yn sha.1.15.4 https://github.com/djs55/ocaml-sha/releases/download/v1.15.4/sha-1.15.4.tbz
        ;;
    3)
        pushd ocluster || exit
        git fetch -q MisterDA
        git reset --hard obuilder-docker-backend
        git submodule update --recursive
        popd || exit
        ;;
    4)
        pushd ocluster/obuilder || exit
        ocaml-env exec -- opam install --deps-only --with-test -y .
        popd || exit
        ;;
    5)
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
        popd || exit

        INPUT=("ocluster/install/bin")
        OUTPUT=/home/opam/base-images-builder/output
        for dir in "${INPUT[@]}"; do
            for exe in "$dir"/*.exe ; do
                for dll in $(PATH="/usr/x86_64-w64-mingw32/sys-root/mingw/bin:$PATH" cygcheck "$exe" | grep -F x86_64-w64-mingw32 | sed -e 's/^ *//'); do
                    if [ ! -e "$OUTPUT/$(basename "$dll")" ] ; then
                        cp "$dll" "$OUTPUT/"
                    else
                        printf "%s uses %s (already extracted)" "$exe" "$dll"
                    fi
                done
                printf "Extracted %s" "$exe"
                cp "$exe" "$OUTPUT/"
            done
        done
        ;;
esac
