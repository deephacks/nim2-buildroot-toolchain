ARG BUILDROOT_VERSION
FROM ubuntu:22.04

ARG BUILDROOT_VERSION

# gcc-multilib is needed by haxscramper/hmisc
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
