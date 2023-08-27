
# buildroot toolchain for building static executables in nim and c/c++

# buildroot configuration file 'buildroot/config' is edited by 'just buildroot-menu'
# buildroot image must be pushed after updating buildroot/Dockerfile (i.e BUILDROOT_VERSION)
# toolchain procedure adds 'buildroot/config' so config changes doesn't require new buildroot tag

set shell := ["bash", "-euo", "pipefail", "-c"]
set export
set dotenv-load

BUILDROOT_VERSION := '2022.11.1'  # --build-arg for buildroot/Dockerfile
NIM_VERSION       := '1.6.12'     # --build-arg for toolchain/Dockerfile

buildroot-vers    :=  BUILDROOT_VERSION + '-1'
buildroot-tag     := 'dh4x/buildroot:' + buildroot-vers

toolchain-vers    :=  buildroot-vers + '_' + NIM_VERSION + '-4'
toolchain-tag     := 'dh4x/toolchain:' + toolchain-vers

# show help
help:
  @ just --list

buildroot-build *opts="":
  docker-build {{buildroot-tag}} {{opts}} --build-arg BUILDROOT_VERSION={{BUILDROOT_VERSION}}
buildroot-build-no-cache:   (buildroot-build '--no-cache')
buildroot-release:          (buildroot-build '--release')
buildroot-menu:             (buildroot-run "(cp /.config /buildroot/; make menuconfig; cp /buildroot/.config /)")
buildroot-run cmd:
  @ cd $(rx dockerimage {{buildroot-tag}}) && docker run -ti --rm -v $(pwd)/config:/.config:rw {{buildroot-tag}} sh -c "{{cmd}}"
buildroot-dist:
  wget -qO- http://buildroot.org/downloads/buildroot-{{BUILDROOT_VERSION}}.tar.gz | tar xz && mv buildroot-{{BUILDROOT_VERSION}} dist


# build toolchain docker image
toolchain-build *opts="":  
  #!/bin/bash
  set -euo pipefail
  trap 'rm toolchain/.config &>/dev/null || true' ERR HUP INT QUIT TERM EXIT
  cp -v buildroot/config toolchain/.config
  export debug=1
  docker-build {{toolchain-tag}} --build-arg BUILDROOT_TAG={{buildroot-tag}} --build-arg NIM_VERSION={{NIM_VERSION}} {{opts}}

# build toolchain with no cache
toolchain-build-no-cache:   (buildroot-build '--no-cache')
# tag and push toolchain to 'registry:5000'
toolchain-release:          (toolchain-build '--release')

# docker build utils for just
docker-build tag *opts="":
  debug=1 docker-build "{{tag}}" {{opts}}

# release all images
release: buildroot-release toolchain-release

