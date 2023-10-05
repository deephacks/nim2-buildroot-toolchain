
# buildroot toolchain for building static executables in nim and c/c++

# buildroot configuration file 'buildroot/config' is edited by 'just buildroot-menu'
# buildroot image must be pushed after updating buildroot/Dockerfile (i.e BUILDROOT_VERSION)
# toolchain procedure adds 'buildroot/config' so config changes doesn't require new buildroot tag

set shell := ["bash", "-euo", "pipefail", "-c"]
set export
set dotenv-load

BUILDROOT_VERSION := '2022.11.1'  # --build-arg for buildroot/Dockerfile
NIM_VERSION       := '2.0.0'     # --build-arg for toolchain/Dockerfile

buildroot-vers    :=  BUILDROOT_VERSION + '-1'
buildroot-tag     := 'registry:5000/dh4x/buildroot:' + buildroot-vers

toolchain-vers    :=  buildroot-vers + '_' + NIM_VERSION + '-1'
toolchain-tag     := 'registry:5000/dh4x/toolchain:' + toolchain-vers

buildroot-build *opts="":
  #!/bin/bash
  set -euox pipefail
  docker build --cache-to type=inline,mode=max \
    -t {{buildroot-tag}} \
    -f buildroot/Dockerfile buildroot {{opts}} \
    --build-arg BUILDROOT_VERSION={{BUILDROOT_VERSION}}
buildroot-build-no-cache:   (buildroot-build '--no-cache')
buildroot-release:          (buildroot-build)
  docker tag {{buildroot-tag}} {{buildroot-tag}}
  docker push {{buildroot-tag}}

buildroot-menu:             (buildroot-run "(cp /.config /buildroot/; make menuconfig; cp /buildroot/.config /)")
buildroot-run cmd:
  @ cd buildroot && docker run -ti --rm -v $(pwd)/config:/.config:rw {{buildroot-tag}} sh -c "{{cmd}}"
buildroot-dist:
  wget -qO- http://buildroot.org/downloads/buildroot-{{BUILDROOT_VERSION}}.tar.gz | tar xz && mv buildroot-{{BUILDROOT_VERSION}} dist

# build toolchain docker image
toolchain-build *opts="":  
  #!/bin/bash
  set -xeuo pipefail
  trap 'rm toolchain/.config &>/dev/null || true' ERR HUP INT QUIT TERM EXIT
  cp -v buildroot/config toolchain/.config
  docker build --cache-to type=inline,mode=max \
    -t {{toolchain-tag}} \
    -f toolchain/Dockerfile toolchain {{opts}} \
    --build-arg docker_uid=$(id -u) \
    --build-arg docker_gid=$(id -g) \
    --build-arg BUILDROOT_TAG={{buildroot-tag}} \
    --build-arg NIM_VERSION={{NIM_VERSION}} {{opts}}

# build toolchain with no cache
toolchain-build-no-cache:   (buildroot-build '--no-cache')
# tag and push toolchain to 'registry:5000'
toolchain-release:          (toolchain-build)
  docker tag {{toolchain-tag}} {{toolchain-tag}}
  docker push {{toolchain-tag}}

# release all images
release: buildroot-release toolchain-release
