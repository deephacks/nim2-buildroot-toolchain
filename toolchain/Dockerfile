ARG NIM_VERSION
ARG BUILDROOT_TAG
FROM ${BUILDROOT_TAG}

ARG NIM_VERSION

# STAGE 1

WORKDIR /buildroot
ADD .config /buildroot/.config
RUN make

# STAGE 2

FROM ubuntu:22.04

ARG NIM_VERSION

ENV \
  TERM=xterm-256color \
  HOME=/home/docker \
  NIM_HOME=/home/docker/opt/nim \
  NIMBLE_HOME=/home/docker/.nimble \
  TOOLCHAIN_HOME=/opt/toolchain \
  docker_home=/home/docker \
  docker_user=docker \
  docker_group=users \
  docker_uid=1000 \
  docker_gid=1000

ENV PATH=${TOOLCHAIN_HOME}/bin:${NIM_HOME}/bin:${NIMBLE_HOME}/bin:$PATH
ENV LD_LIBRARY_PATH=${TOOLCHAIN_HOME}/lib
COPY --from=0 /buildroot/output/host/ /opt/toolchain/

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


RUN groupadd --gid $docker_gid $docker_user \
  && useradd  --system --shell /bin/bash --uid $docker_uid --gid $docker_gid --groups sudo --create-home --comment "Docker User" $docker_user \
  && echo $docker_user ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$docker_user \
  && chmod 0440 /etc/sudoers.d/$docker_user

# RUN cd $(mktemp -d) && git clone --branch master --depth 1 https://github.com/yaml/libyaml.git .  \
#   && mkdir -p build && cd build && cmake .. && make && make install

# RUN cd $(mktemp -d) \
#   && git clone --depth 1 https://github.com/pantoniou/libfyaml.git . \
#   && autoreconf -fi \
#   && ./configure \
#   && make \
#   && make install \
#   && ldconfig

USER $docker_user
RUN touch $docker_home/.sudo_as_admin_successful

# put nim.cfg in the container user $HOME (i.e. '/home/docker/.config/nim/nim.cfg')
# builds starts from host's $HOME -- nim will still use 'docker' as user to find the nim.cfg 

COPY --chown=$docker_user nim.cfg $docker_home/.config/nim/nim.cfg
RUN sudo mkdir -p ${NIM_HOME} && sudo chown -R $docker_user:$docker_group ${NIM_HOME}
RUN sudo chown -R $docker_user:$docker_group $TOOLCHAIN_HOME
RUN ln -s $TOOLCHAIN_HOME/bin/x86_64-buildroot-linux-musl-strip $TOOLCHAIN_HOME/bin/strip
ENV CC=/opt/toolchain/bin/x86_64-buildroot-linux-musl-gcc

RUN cd ${NIM_HOME} \
  && curl -sL https://nim-lang.org/download/nim-${NIM_VERSION}-linux_x64.tar.xz \
    | bsdtar --strip-components=1 -xvf -

RUN cd $(mktemp -d) \
  && curl -sL https://github.com/libgit2/libgit2/archive/refs/tags/v1.4.3.tar.gz \
  | bsdtar -xf- --strip-components=1 \
  && mkdir -p build && cd build \
  && cmake .. \
    -DBUILD_SHARED_LIBS=OFF \
    -DLINK_WITH_STATIC_LIBRARIES=ON \
    -DCMAKE_C_COMPILER=/opt/toolchain/bin/x86_64-buildroot-linux-musl-gcc \
    -DCMAKE_PREFIX_PATH="$TOOLCHAIN_HOME/x86_64-buildroot-linux-musl/sysroot/" \
    -DCMAKE_FIND_ROOT_PATH="$TOOLCHAIN_HOME/x86_64-buildroot-linux-musl/sysroot/usr/" \
    -DCMAKE_INSTALL_PREFIX="$TOOLCHAIN_HOME/x86_64-buildroot-linux-musl/sysroot/usr/" \
    -DCMAKE_EXE_LINKER_FLAGS="-no-pie" \
  && make \
  && sudo make install \
  && rm -rf $(pwd)

COPY --chown=$docker_user:$docker_group build-static-tree-sitter* /
RUN bash /build-static-tree-sitter.bash

ARG POSTGRESQL_VERSION=11.14

# CPPFLAGS=-I\"$TOOLCHAIN_HOME/x86_64-buildroot-linux-musl/sysroot/usr/\" LDFLAGS=-L\"$TOOLCHAIN_HOME/x86_64-buildroot-linux-musl/sysroot/usr/\" ./configure --with-openssl --without-readline --prefix=\"$TOOLCHAIN_HOME/x86_64-buildroot-linux-musl/sysroot/usr/\"

RUN echo "Building libpq" && \
    cd /tmp && \
    curl -fLO "https://ftp.postgresql.org/pub/source/v$POSTGRESQL_VERSION/postgresql-$POSTGRESQL_VERSION.tar.gz" && \
    tar xzf "postgresql-$POSTGRESQL_VERSION.tar.gz" && cd "postgresql-$POSTGRESQL_VERSION" && \
    CPPFLAGS=-I$TOOLCHAIN_HOME/x86_64-buildroot-linux-musl/sysroot/usr/include LDFLAGS=-L$TOOLCHAIN_HOME/x86_64-buildroot-linux-musl/sysroot/usr/lib/ ./configure --with-openssl --without-readline --prefix=$TOOLCHAIN_HOME/x86_64-buildroot-linux-musl/sysroot/usr/ && \
    cd src/interfaces/libpq && make all-static-lib && make install-lib-static && \
    cd ../../bin/pg_config && make && make install && \
    rm -r /tmp/*


RUN nimble install nimgen -y
RUN nimble install nimterop -y

# TODO: integrate nimlsp with vscode (language server) 
# github.com/PMunch/nimlsp: nim language server 
# github.com/status-im/nim-metrics: metrics client library supporting the Prometheus monitoring toolkit, StatsD and Carbon
# nimarchive \
# nim_cjson \
# iterrr
# itertools

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
  slicerator \
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
  protobuf

# HACK for '$HOME/boot/bin/nim':
# put the real 'nim' executable first on $PATH, so that the 
# wrapper script doesn't run inside container!
ENV PATH=$PATH:$HOME/bin:$HOME/lib
WORKDIR $HOME
