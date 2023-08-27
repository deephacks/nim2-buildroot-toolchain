#!/usr/bin/env bash
set -xeuo pipefail

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "$(mktemp -d)"

curl -sL https://github.com/tree-sitter/tree-sitter/archive/refs/tags/v0.20.6.tar.gz | bsdtar -xf- --strip-components=1
git apply < "$dir/build-static-tree-sitter-makefile.patch"

sudo make "PREFIX=$TOOLCHAIN_HOME/x86_64-buildroot-linux-musl/sysroot/usr" clean libtree-sitter.a
sudo install -v -o docker -g users -m755 libtree-sitter.a "$TOOLCHAIN_HOME/x86_64-buildroot-linux-musl/sysroot/usr/lib/"
sudo install -v -o docker -g users -d "$TOOLCHAIN_HOME/x86_64-buildroot-linux-musl/sysroot/usr/include/tree_sitter"
sudo install -v -o docker -g users -m644 lib/include/tree_sitter/*.h "$TOOLCHAIN_HOME/x86_64-buildroot-linux-musl/sysroot/usr/include/tree_sitter"
