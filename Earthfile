VERSION 0.7
FROM ubuntu:latest

buildroot:
    ARG BUILDROOT_VERSION
    ARG BUILDROOT_TAG
    RUN apt-get update \
      && DEBIAN_FRONTEND=noninteractive apt-get install -y -q \
      bash \
      cmake \
      autoconf \
      automake \
      libtool \
      pkg-config \
      bc \
      curl \
      gcc-multilib \
      libarchive-tools \
      binutils \
      build-essential \
      bzip2 \
      ca-certificates \
      cpio \
      debianutils \
      file \
      g++ \
      gcc \
      git \
      graphviz \
      gzip \
      libncurses5-dev \
      locales \
      make \
      patch \
      perl \
      python3 \
      rsync \
      sed \
      tar \
      unzip \
      wget \
      xcb \
      vim && apt-get clean && rm -rf /var/lib/apt/lists/*

    RUN wget -qO- http://buildroot.org/downloads/buildroot-${BUILDROOT_VERSION}.tar.gz | tar xz && mv buildroot-${BUILDROOT_VERSION} /buildroot
    ENV FORCE_UNSAFE_CONFIGURE=1
    WORKDIR /buildroot
    SAVE IMAGE $BUILDROOT_TAG

toolchain:
    FROM +buildroot
    WORKDIR /buildroot
    COPY config /buildroot/.config
    RUN make
    RUN mv /buildroot/output/host /opt/toolchain
    ENV TOOLCHAIN_HOME=/opt/toolchain
    ENV PATH=${TOOLCHAIN_HOME}/bin:${NIM_HOME}/bin:${NIMBLE_HOME}/bin:$PATH
    ENV LD_LIBRARY_PATH=${TOOLCHAIN_HOME}/lib
    ENV CC=${TOOLCHAIN_HOME}/bin/x86_64-buildroot-linux-musl-gcc

    RUN cd $(mktemp -d) \
      && curl -sL https://github.com/libgit2/libgit2/archive/refs/tags/v1.4.3.tar.gz \
      | bsdtar -xf- --strip-components=1 \
      && mkdir -p build && cd build \
      && cmake .. \
        -DBUILD_SHARED_LIBS=OFF \
        -DLINK_WITH_STATIC_LIBRARIES=ON \
        -DCMAKE_C_COMPILER=$TOOLCHAIN_HOME/bin/x86_64-buildroot-linux-musl-gcc \
        -DCMAKE_PREFIX_PATH="$TOOLCHAIN_HOME/x86_64-buildroot-linux-musl/sysroot/" \
        -DCMAKE_FIND_ROOT_PATH="$TOOLCHAIN_HOME/x86_64-buildroot-linux-musl/sysroot/usr/" \
        -DCMAKE_INSTALL_PREFIX="$TOOLCHAIN_HOME/x86_64-buildroot-linux-musl/sysroot/usr/" \
        -DCMAKE_EXE_LINKER_FLAGS="-no-pie" \
      && make \
      && make install \
      && rm -rf $(pwd)
    
    COPY build-static-tree-sitter-makefile.patch /
    RUN cd $(mktemp -d) \
        && curl -sL https://github.com/tree-sitter/tree-sitter/archive/refs/tags/v0.20.6.tar.gz | bsdtar -xf- --strip-components=1 \
        && git apply < "/build-static-tree-sitter-makefile.patch" \
        && make "PREFIX=$TOOLCHAIN_HOME/x86_64-buildroot-linux-musl/sysroot/usr" clean libtree-sitter.a \
        && install -v -m755 libtree-sitter.a "$TOOLCHAIN_HOME/x86_64-buildroot-linux-musl/sysroot/usr/lib/" \
        && install -v -d "$TOOLCHAIN_HOME/x86_64-buildroot-linux-musl/sysroot/usr/include/tree_sitter" \
        && install -v -m644 lib/include/tree_sitter/*.h "$TOOLCHAIN_HOME/x86_64-buildroot-linux-musl/sysroot/usr/include/tree_sitter"
    
    ARG POSTGRESQL_VERSION=11.14

    RUN cd $(mktemp -d) && \
        curl -fLO "https://ftp.postgresql.org/pub/source/v$POSTGRESQL_VERSION/postgresql-$POSTGRESQL_VERSION.tar.gz" && \
        tar xzf "postgresql-$POSTGRESQL_VERSION.tar.gz" && cd "postgresql-$POSTGRESQL_VERSION" && \
        CPPFLAGS=-I$TOOLCHAIN_HOME/x86_64-buildroot-linux-musl/sysroot/usr/include LDFLAGS=-L$TOOLCHAIN_HOME/x86_64-buildroot-linux-musl/sysroot/usr/lib/ ./configure --with-openssl --without-readline --prefix=$TOOLCHAIN_HOME/x86_64-buildroot-linux-musl/sysroot/usr/ && \
        cd src/interfaces/libpq && make all-static-lib && make install-lib-static && \
        cd ../../bin/pg_config && make && make install && \
        rm -r /tmp/*
    SAVE ARTIFACT /opt/toolchain AS LOCAL build/toolchain

nim:
    COPY build/toolchain /opt/toolchain
    ARG NIM_VERSION=2.0.0
    ARG uid=1000
    ARG gid=1000
    ARG home=/home/docker
    ARG user=docker
    ARG group=users

    ENV TERM=xterm-256color
    ENV HOME=${home}
    ENV NIM_HOME=${home}/opt/nim
    ENV NIMBLE_HOME=${home}/.nimble
    ENV TOOLCHAIN_HOME=/opt/toolchain
    ENV PATH=${TOOLCHAIN_HOME}/bin:${NIM_HOME}/bin:${NIMBLE_HOME}/bin:$PATH
    ENV LD_LIBRARY_PATH=${TOOLCHAIN_HOME}/lib
    ENV CC=${TOOLCHAIN_HOME}/bin/x86_64-buildroot-linux-musl-gcc

    RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y -q \
        curl \
        libsqlite-dev \
        libarchive-tools \
        sudo \
        ca-certificates \
        vim \
        upx \
        git \
        make \
        autoconf \
        automake \
        libltdl-dev \
        pkg-config \
        cmake \
        libtool \
        gcc \
        g++ \
        build-essential \
        xz-utils \
      && apt-get clean \
      && rm -rf /var/lib/apt/lists/*

    RUN groupadd --gid $gid $user \
      && useradd  --system --shell /bin/bash --uid $uid --gid $gid --groups sudo --create-home --comment "Docker User" $user \
      && echo $user ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$user \
      && chmod 0440 /etc/sudoers.d/$user

    USER $user
    RUN touch $home/.sudo_as_admin_successful

    COPY --chown=$user:$group nim.cfg $home/.config/nim/nim.cfg
    RUN mkdir -p ${NIM_HOME}

    RUN curl https://nim-lang.org/choosenim/init.sh -sSf | bash -s -- -y
    # RUN choosenim 1.6.14

    # RUN cd ${NIM_HOME} \
    #   && curl -sL https://nim-lang.org/download/nim-${NIM_VERSION}-linux_x64.tar.xz \
    #     | bsdtar --strip-components=1 -xf -

    RUN nimble install nimgen -y
    RUN nimble install nimterop -y

    RUN nimble install -y \
      fusion \
      npeg \
      cello \
      csvtools \
      xxhash \
      cligen \
      psutil \
      libssh2 \
      yaml \
      libcurl \
      msgpack4nim \
      nake \
      docopt \
      lmdb \
      confutils \
      parsetoml \
      templates \
      nake \
      oauth \
      nimlsp \
      nimquery \
      zippy \
      zero_functional \
      https://github.com/genotrance/nimfuzzy \
      https://github.com/status-im/nim-metrics@#master \
      https://github.com/cheatfate/asynctools.git \
      packedjson \
      confutils \
      serialization \
      result \
      https://github.com/z-------------/semver2 \
      htsparse \
      hmisc \
      ormin \
      https://github.com/joachimschmidt557/nim-lscolors \
      datamancer \
      nimlangserver \
      puppy \
      asyncftpclient \
      https://github.com/nim-works/cps \
      random \
      memo \
      ws \
      protobuf \
      smtp \
      db_connector \
      protobuf_serialization

    ENV PATH=$PATH:$HOME/bin:$HOME/lib
    WORKDIR $HOME
    ARG NIM_TAG
    SAVE IMAGE $NIM_TAG
