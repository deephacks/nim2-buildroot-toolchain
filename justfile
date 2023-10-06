
set shell := ["bash", "-euo", "pipefail", "-c"]
set export
set dotenv-load

# NOTE: symlink .env -> .arg

# build buildroot image
build-buildroot:
  earthly +buildroot

# build the toolchain from builroot 'config' file
build-toolchain:
  earthly  +toolchain

# build nim
build-nim:
  earthly +nim --uid=$(id -u) --gid=$(id -g)

# configure buildroot using menuconfig
menu:
  #!/bin/bash
  # copy 'config' to container before starting menuconfig
  docker run -ti --rm -v "$(pwd)/config:/.config:rw" $BUILDROOT_TAG \
    sh -c "cp /.config /buildroot/; make menuconfig; cp /buildroot/.config /"
  # copy 'config' from container volume after exiting menuconfig
