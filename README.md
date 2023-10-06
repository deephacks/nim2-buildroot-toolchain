# nim2-buildroot-toolchain

This project provides a Docker [buildroot](https://buildroot.org) cross-compilation toolchain for building fully static [musl](https://musl.libc.org) executables for C/C++ and [Nim](https://nim-lang.org). 

Static linking results in binaries that have all the necessary libraries bundled within, eliminating dependency issues, and runs on any Linux distribution.

Support for openssl, pcre, tree-sitter, libpq, libgit2, libmagic, xxhash, libcurl, libsqlite is included and more.

# Usage

```bash
# build buildroot and toolchain images
just build-buildroot build-toolchain build-nim

# build nim program
docker run -ti --rm -u docker -v $(pwd):$(pwd) -w $(pwd) nim-2.0.0 c test.nim
```

# References

- [just](https://github.com/casey/just) - used for building project
- [earthly](https://github.com/earthly/earthly) - make for docker
