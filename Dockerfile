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

# set path up front for QEMU binaries target destination
ENV PATH=/qemu-xtensa:${PATH}

# clone and build QMEU, currently disabled as it needs GitLab credentials
WORKDIR /
RUN cd / && git clone https://github.com/espressif/qemu.git --recursive
RUN mkdir /qemu-xtensa && cd /qemu-xtensa && ../qemu/configure --prefix=`pwd`/root --target-list=xtensa-softmmu,xtensaeb-softmmu
RUN cd /qemu-xtensa && make install

# install all the additional esp-idf tools
# note: tools are installed in /root/.espressif folder
# that applies to both - compilers and python env folder used by esp-idf
# GitHub Actions map their folder into /github/home and change HOME folder location
# therefore tools may need to be copied when used in GitHub actions environment
RUN git clone https://github.com/espressif/esp-idf.git \
    && cd esp-idf \
    && ./install.sh all \
    && . ./export.sh \
    && python3 ./tools/idf_tools.py install-python-env --features pytest,ci \
    && cd .. \
    && rm -rf esp-idf


# install additional packages without activating env
RUN echo "------------------------- INSTALLING ADDITIONAL PACKAGES" \
    && . ~/.espressif/python_env/idf5.1_py3.10_env/bin/activate \
    && pip freeze \
    && pip install pyecharts \
    && pip install idf_build_apps \
    && pip install PyYaml \
    && pip install matplotlib \
    && pip install pandas \
    && pip install jira==3.2.0 \
    && pip install PyGithub==1.54.1 \
    && pip install python-gitlab==3.0.0 \      
    && pip install xmltodict \
    && pip install dateutils \
    && echo "------------------------- PACKAGES INSTALLED" \
    && pip freeze

