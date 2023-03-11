FROM ubuntu:latest

# These are additional dependencies needed by PyTest Embedded and QEMU
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    libglib2.0-dev \
    libgcrypt-dev \
    libdbus-1-dev \
    python3-pip \
    libpixman-1-dev \
    python3.10-venv \
    openocd \
    git \
    ninja-build \
    build-essential \
    wget \
  && rm -rf /var/lib/apt/lists/*

# install cmake
RUN wget https://github.com/Kitware/CMake/releases/download/v3.24.1/cmake-3.24.1-Linux-x86_64.sh \
      -q -O /tmp/cmake-install.sh \
      && chmod u+x /tmp/cmake-install.sh \
      && mkdir /opt/cmake-3.24.1 \
      && /tmp/cmake-install.sh --skip-license --prefix=/opt/cmake-3.24.1 \
      && rm /tmp/cmake-install.sh \
      && ln -s /opt/cmake-3.24.1/bin/* /usr/local/bin

RUN pip install pyecharts
RUN pip install idf_build_apps
RUN pip install PyYaml

# set path up front for QEMU binaries target destination
ENV PATH=/qemu-xtensa:${PATH}

# clone and build QMEU, currently disabled as it needs GitLab credentials
WORKDIR /
RUN cd / && git clone https://github.com/espressif/qemu.git --recursive
RUN mkdir /qemu-xtensa && cd /qemu-xtensa && ../qemu/configure --prefix=`pwd`/root --target-list=xtensa-softmmu,xtensaeb-softmmu
RUN cd /qemu-xtensa && make install
