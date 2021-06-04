#!/usr/bin/env bash

set -ex

export "PATH=/usr/x86_64-w64-mingw32/bin:$PATH"

case $1 in
1)
  ocaml-env exec -- opam source mirage-crypto.0.10.1
  cd mirage-crypto.0.10.1
  ocaml-env exec -- opam install -y --deps-only --with-test ./mirage-crypto.opam
  ocaml-env exec -- env PKG_CONFIG_PATH=/cygdrive/c/opam/.opam/4.12/lib/pkgconfig dune build -p mirage-crypto @install
  ocaml-env exec -- env PKG_CONFIG_PATH=/cygdrive/c/opam/.opam/4.12/lib/pkgconfig opam install -y ./mirage-crypto.opam

  cd ..
  ocaml-env exec -- opam source mirage-crypto-ec.0.10.1
  cd mirage-crypto-ec.0.10.1
  ocaml-env exec -- opam install -y --deps-only --with-test ./mirage-crypto-ec.opam
  ocaml-env exec -- env PKG_CONFIG_PATH=/cygdrive/c/opam/.opam/4.12/lib/pkgconfig dune build -p mirage-crypto-ec @install
  ocaml-env exec -- env PKG_CONFIG_PATH=/cygdrive/c/opam/.opam/4.12/lib/pkgconfig opam install -y ./mirage-crypto-ec.opam

  cd ../docker-base-images/ocurrent
  ocaml-env exec -- opam install -y --deps-only .
;;
2)
  cd ocluster
  # sed -i'' '/conf-libev/d' ocluster.opam
  ocaml-env exec -- opam install -y --deps-only .
;;
3)
  cd docker-base-images
  ocaml-env exec -- opam install -y --deps-only .
;;
extract)
  rm -rf docker-base-images ocluster
  git clone --recursive --depth=1 --branch=windows https://github.com/MisterDA/docker-base-images.git
  git clone --recursive --depth=1 --branch=windows https://github.com/MisterDA/ocluster.git
  cd docker-base-images || exit

  sed -i'' \
      -e 's|ocurrent/opam-staging|antonindecimo/opam-windows|g' \
      -e 's|ocaml/opam|antonindecimo/opam-windows|g' \
      -e 's|\"ocurrent\"|\"antonindecimo\"|g' \
      -e 's/  | `Linux | `Windows -> true/  | `Windows -> true/g' \
      src/conf.ml
  sed -i'' \
      -e 's|\"ocurrentbuilder\"|\"antonindecimo\"|g' \
      src/base_images.ml

  PROFILE=release

  opam reinstall -y lwt prometheus-app winsvc

  cd ../ocluster || exit
  mkdir -p install
  # ocaml-env exec -- opam install -y .

  patch -Np1 <<EOF
diff --git a/bin/winsvc_wrapper.winsvc.ml b/bin/winsvc_wrapper.winsvc.ml
index c4055ec..2802854 100644
--- a/bin/winsvc_wrapper.winsvc.ml
+++ b/bin/winsvc_wrapper.winsvc.ml
@@ -1,6 +1,6 @@
 let formatter =
-  let f = Filename.null in
-  (* let f = Filename.(concat (Sys.getenv "APPDATA") (Sys.executable_name |> basename |> remove_extension |> Fun.flip (^) ".log")) in *)
+  (* let f = Filename.null in *)
+  let f = Filename.(concat (Sys.getenv "APPDATA") (Sys.executable_name |> basename |> remove_extension |> Fun.flip (^) ".log")) in
   Format.formatter_of_out_channel (open_out_bin f)

 let run name main =
EOF

  ocaml-env exec -- dune build @install --profile=$PROFILE --root=.
  ocaml-env exec -- dune install --prefix=install --relocatable --root=.

  cd ../docker-base-images || exit
  mkdir -p install
  # ocaml-env exec -- opam install -y .
  ocaml-env exec -- dune build @install --profile=$PROFILE
  ocaml-env exec -- dune install --prefix=install --relocatable

  cd .. || exit
  for dir in docker-base-images/install/bin ocluster/install/bin; do
    for exe in $dir/*.exe ; do
      for dll in $(PATH="/usr/x86_64-w64-mingw32/sys-root/mingw/bin:$PATH" cygcheck "$exe" | fgrep x86_64-w64-mingw32 | sed -e 's/^ *//'); do
        if [ ! -e /cygdrive/c/output/$(basename "$dll") ] ; then
          echo "Extracting $dll for $exe"
          cp "$dll" /cygdrive/c/output/
        else
        echo "$exe uses $dll (already extracted)"
        fi
      done
      echo "Extracted $exe"
      cp "$exe" /cygdrive/c/output/
    done
  done
;;
esac
