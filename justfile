
set shell := ["bash", "-euo", "pipefail", "-c"]
set export
set dotenv-load

uid   := `id -u`
gid   := `id -g`
user  := `id -un`
group := `id -gn`
home  := env_var('HOME')

# NOTE: symlink .env -> .arg

build-all: build-buildroot build-toolchain build-nim

# build buildroot image
build-buildroot:
  earthly +buildroot

# build the toolchain from builroot 'config' file
build-toolchain:
  earthly  +toolchain

# build nim
build-nim:
  earthly -i +nim \
    --home='{{home}}' \
    --user='{{user}}' \
    --group='{{group}}' \
    --uid='{{uid}}' \
    --gid='{{uid}}'

# configure buildroot using menuconfig
menu:
  #!/bin/bash
  # copy 'config' to container before starting menuconfig
  docker run -ti --rm -v "$(pwd)/config:/.config:rw" $BUILDROOT_TAG \
    sh -c "cp /.config /buildroot/; make menuconfig; cp /buildroot/.config /"
  # copy 'config' from container volume after exiting menuconfig
