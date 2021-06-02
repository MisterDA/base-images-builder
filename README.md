# base-images-builder

Build the [OCluster][ocluster] tools required to build OCaml and Opam
[Docker base images][docker-base-images].

The current Docker Hub user/repo the images are pushed to is
[`antonindecimo/opam-windows`][docker-hub] and it's a hack as I don't
use a staging user. Change it in `build.sh` and in the script below,
in `--allow-push`.

Download and extract the repo, have Docker for Windows configured to
run Windows jobs, then

``` batchfile
cd base-images-builder		@rem the current repo
set LIB=%APPDATA%\ocluster\var\lib	@rem the OCluster state
mkdir "%LIB%" capnp-secrets

@rem Build everything
deps.cmd && build.cmd

.\output\ocluster-scheduler.exe --install ^
  --capnp-secret-key-file=%CD%\capnp-secrets\key.pem ^
  --capnp-listen-address=tcp:0.0.0.0:9000 ^
  --capnp-public-address=tcp:localhost:9000 ^
  --state-dir=%LIB%\ocluster-scheduler ^
  --secrets-dir=%CD%\capnp-secrets ^
  --pools=windows-x86_64

sc start ocluster-scheduler		@rem as an Administrator

.\output\ocluster-worker.exe --install ^
  --state-dir=%LIB%\ocluster-worker ^
  --name=%COMPUTERNAME%-worker ^
  --capacity=%NUMBER_OF_PROCESSORS% ^
  --allow-push antonindecimo/opam-windows ^
  --prune-threshold=10 ^
  %CD%\capnp-secrets\pool-windows-x86_64.cap

sc start ocluster-worker		@rem as an Administrator

.\output\ocluster-admin.exe add-client ^
  --connect=%CD%\capnp-secrets\admin.cap user > .\capnp-secrets\user.cap

.\output\base-images.exe ^
  --submission-service=%CD%\capnp-secrets\user.cap ^
  --staging-password-file=C:\ProgramData\Docker\secrets\ocurrent-hub
```

[ocluster]: https://github.com/ocurrent/ocluster/
[docker-base-images]: https://github.com/ocurrent/docker-base-images
[docker-hub]: https://hub.docker.com/r/antonindecimo/opam-windows
