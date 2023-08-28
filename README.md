# nim2-buildroot-toolchain

This project provides a Docker [buildroot](https://buildroot.org) cross-compilation toolchain for building fully static [musl](https://musl.libc.org) executables for C/C++ and [Nim](https://nim-lang.org). 

Static linking results in binaries that have all the necessary libraries bundled within, eliminating dependency issues, and runs on any Linux distribution.

Support for OpenSSL, PCRE, Treesitter, libpq, libgit2, libmagic, xxhash, libcurl, libsqlite is included and more.


# Usage

```bash
# build buildroot and toolchain images
just buildroot-build toolchain-build

# build nim program
docker run -ti --rm -v $(pwd):$(pwd) -w $(pwd) dh4x/toolchain:2022.11.1-1_2.0.0-1 nim c test.nim
```

# References

- [just](https://github.com/casey/just) - used for building project
