# base-images-builder

Build the [OCluster][ocluster] tools required to build OCaml and Opam
[Docker base images][docker-base-images].

The current Docker Hub user/repo the images are pushed to is
[`ocaml/opam`][docker-hub]. Change it in `build.sh` and in the script
below, in `--allow-push`.

The password for the Docker Hub user need to be written to the usual
mount points of secrets if starting base-images directly and not
through docker-compose. On Windows, that's
`C:\ProgramData\Docker\secrets\ocurrent-hub`.

Encode the cap files in UTF8 (without BOM) or ASCII, with LF line
endings for better results.

Download and extract the repo, have Docker for Windows configured to
run Windows jobs, then

``` batchfile
@rem on the worker
git config --system core.longpaths true

@rem the current repo
cd base-images-builder

@rem the OCluster state
set LIB=C:\Windows\System32\config\systemprofile\AppData\Roaming

@rem the secrets directory
set SECRETS=%CD%\capnp-secrets

@rem the Docker Hub account where to push images
set ALLOW_PUSH=ocurrent/opam-staging

@rem Set the Docker isolation
set ISOLATION=hyperv
@rem Set the Docker network
set NETWORK=nat

@rem Build everything
.\deps.cmd && .\build.cmd

mkdir %SECRETS%


set SCHEDULER_NAME=ocluster-scheduler

.\output\ocluster-scheduler.exe ^
  --state-dir=%LIB%\ocluster-scheduler ^
  --capnp-secret-key-file=%SECRETS%\key.pem ^
  --capnp-listen-address=tcp:0.0.0.0:9000 ^
  --capnp-public-address=tcp:localhost:9000 ^
  --secrets-dir=%SECRETS% ^
  --pools=windows-x86_64 ^
  --verbosity=info

set WORKER_NAME=ocluster-worker

set /a CAPACITY=NUMBER_OF_PROCESSORS/4

.\output\ocluster-worker.exe ^
  --state-dir=%LIB%\ocluster-worker ^
  --name=%WORKER_NAME% ^
  --capacity=%CAPACITY% ^
  --prune-threshold=10 ^
  --connect=%SECRETS%\pool-windows-x86_64.cap ^
  --obuilder-docker-backend=%LIB%\obuilder ^
  --docker-cpus=%CAPACITY% ^
  --docker-memory=12g ^
  --verbose

@rem as an Administrator
sc start %SCHEDULER_NAME%

@rem as an Administrator
sc start %WORKER_NAME%

@rem Create an account on the scheduler
@ren Convert user.cap from CRLF to LF and to UTF-8?
.\output\ocluster-admin.exe add-client ^
  --connect=%SECRETS%\admin.cap user > %SECRETS%\user.cap

@rem To remove the services:
sc delete %SCHEDULER_NAME%
sc delete %WORKER_NAME%
```

[ocluster]: https://github.com/ocurrent/ocluster/
[docker-base-images]: https://github.com/ocurrent/docker-base-images
[docker-hub]: https://hub.docker.com/r/ocaml/opam/tags?ordering=-name&name=windows&page=1
