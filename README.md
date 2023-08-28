# nim2-buildroot-toolchain

This project provides a Docker [buildroot](https://buildroot.org) cross-compilation toolchain for building fully static [musl](https://musl.libc.org) executables for C/C++ and [Nim](https://nim-lang.org). 

Static linking results in binaries that have all the necessary libraries bundled within, eliminating dependency issues, and runs on any Linux distribution.

Support for OpenSSL, PCRE, Treesitter, libpq, libgit2, libmagic, xxhash, libcurl, libsqlite is included and more.


# Usage

```bash
just buildroot-build toolchain-build
```

# References

- [just](https://github.com/casey/just) - used for building project
