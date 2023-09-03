#Zephyr development environment

FROM debian:11.7-slim AS base

FROM base AS west

RUN \
  apt-get -y update \
  && apt-get -y install --no-install-recommends \
  usbutils \
  minicom \
  python3 \
  python3-pip \
  python3-wheel \
  && pip3 install west \
  && apt-get remove -y --purge \
  python3-pip \
  python3-wheel \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

FROM west AS python

ARG ZEPHYR_VERSION=v3.3.0
ENV ZEPHYR_VERSION=${ZEPHYR_VERSION}

RUN \
  apt-get -y update \
  && apt-get -y install --no-install-recommends \
  libusb-1.0-0-dev \
  git \
  python3 \
  python3-pip \
  python3-wheel \
  && pip3 install \
  -r https://raw.githubusercontent.com/zephyrproject-rtos/zephyr/${ZEPHYR_VERSION}/scripts/requirements-base.txt \
  && pip3 install cmake \
  # Workaround until https://github.com/zephyrproject-rtos/zephyr/issues/56215 is fixed
  && pip3 install requests \
  && pip3 install click \
  && pip3 install cryptography \
  && pip3 install cbor2 \
  && pip3 install ply \
  && pip3 install pyserial \
  && pip3 install tabulate \
  && pip3 install -U pyocd \
  && pyocd pack update \
  && pyocd pack install stm32l552zetxq \
  && apt-get remove -y --purge \
  python3-pip \
  python3-wheel \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

FROM python AS sdk

ARG ZEPHYR_SDK_VERSION=0.16.0
ARG ZEPHYR_SDK_INSTALL_DIR=/opt/zephyr-sdk
ENV ZEPHYR_SDK_INSTALL_DIR=${ZEPHYR_SDK_INSTALL_DIR}
ARG TOOLCHAIN=arm-zephyr-eabi
ENV TOOLCHAIN=${TOOLCHAIN}
ARG TEST_TOOLCHAIN=x86_64-zephyr-elf

RUN \
  export sdk_file_name="zephyr-sdk-${ZEPHYR_SDK_VERSION}_linux-$(uname -m)_minimal.tar.xz" \
  && apt-get -y update \
  && apt-get -y install --no-install-recommends \
  protobuf-compiler \
  python3-protobuf \
  device-tree-compiler \
  git \
  ninja-build \
  wget \
  xz-utils \
  && wget -q "https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${ZEPHYR_SDK_VERSION}/${sdk_file_name}" \
  && mkdir -p ${ZEPHYR_SDK_INSTALL_DIR} \
  && tar -xvf ${sdk_file_name} -C ${ZEPHYR_SDK_INSTALL_DIR} --strip-components=1 \
  && ${ZEPHYR_SDK_INSTALL_DIR}/setup.sh -t ${TOOLCHAIN} -t ${TEST_TOOLCHAIN} \
  && rm ${sdk_file_name} \
  && apt-get remove -y --purge \
  wget \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

#SSH for git authentication
RUN  apt-get -y update \
    && apt-get -yqq install ssh \
    && mkdir -p -m 0700 ~/.ssh \
    && ssh-keyscan github.com >> ~/.ssh/known_hosts \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

FROM sdk AS jlink

ARG JLINK_INSTALL_LOC=/opt/SEGGER

#Add local Segger package
ADD JLink_Linux*.tgz ${JLINK_INSTALL_LOC}

#Install dependencies
RUN apt-get -y update \
  && apt-get -y install --no-install-recommends \
  libfreetype6 libsm6 libxrender1 libxrandr2 \
  libxfixes3 libxcursor1 libfontconfig1 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

#Set permissions and add location to path
RUN export jlink_install_dir=$(find ${JLINK_INSTALL_LOC} -name JLink_Linux_V*_$(uname -m)) \
  && echo "Using JLink Installation at: ${jlink_install_dir}" \
  && chmod a-w ${jlink_install_dir} \
  && echo "export PATH=${PATH}:${jlink_install_dir}" >> /etc/bash.bashrc \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

FROM jlink AS cmock_unity_module

RUN \
  apt-get -y update \
  && apt-get -y install --no-install-recommends \
  xz-utils file make gcc gcc-multilib g++-multilib libsdl2-dev libmagic1 curl \
	ruby \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

FROM cmock_unity_module AS renode

ARG RENODE_VERSION=1.13.3
ARG RENODE_INSTALL_DIR=/opt/renode
ARG RENODE_ARCHIVE=renode-${RENODE_VERSION}.linux-portable.tar.gz

RUN \
    apt-get -y update && \
    apt-get -y install --no-install-recommends \
    wget \
    python3 \
    python3-pip \
    python3-wheel \
    mono-complete \
    && mkdir -p ${RENODE_INSTALL_DIR} \
    && wget https://github.com/renode/renode/releases/download/v${RENODE_VERSION}/${RENODE_ARCHIVE} \
    && tar xf ${RENODE_ARCHIVE} -C ${RENODE_INSTALL_DIR} --strip-components=1 \
    && rm ./${RENODE_ARCHIVE} \
    && chmod a-w ${RENODE_INSTALL_DIR} \
    && echo "export PATH=${PATH}:${RENODE_INSTALL_DIR}" >> /etc/bash.bashrc \
    && pip3 install git+https://github.com/antmicro/dts2repl.git \
    && apt-get remove -y --purge \
    wget \
    python3-pip \
    python3-wheel \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

#Installing nano for convenience
FROM renode AS nano

RUN \
    apt-get -y update && \
    apt-get -y install --no-install-recommends \
    nano \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

FROM nano AS qemu_x86

RUN \
  apt-get -y update \
  && apt-get -y install \
  qemu-system-x86 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

FROM qemu_x86 AS net_tools

RUN \
  apt-get -y update \
  && apt-get -y install \
  socat \
  iproute2 \
  libpcap-dev \
  autoconf \
  libtool \
  net-tools \
  iputils-ping \
  netcat \
  bridge-utils \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

FROM net_tools AS codechecker

RUN \
  apt-get -y update \
  && apt-get -y install \
  python3 \
  python3-pip \
  python3-wheel \
  clang-tools \
  cppcheck \
  clang-tidy \
  && pip3 install codechecker \
  && apt-get remove -y --purge \
  python3-pip \
  python3-wheel \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*


# !!! Set this to the name of the root folder in your workspace !!!
ENV PRJ_ROOT_DIR /workspaces/Zephyr-Dev-Container-Template

ENV TEST_DIR ${PRJ_ROOT_DIR}/app_tests
ENV APP_DIR ${PRJ_ROOT_DIR}/app
ENV ZEPHYR_BASE ${PRJ_ROOT_DIR}/zephyr_project/zephyr
ENV NET_TOOLS_BASE ${PRJ_ROOT_DIR}/zephyr_project/tools/net-tools
ENV APP_CODECHECKER_CONFIG_FILE ${PRJ_ROOT_DIR}/app/codechecker.json

CMD [ "(test -d .west || (west init -l app && west update && cd $NET_TOOLS_BASE && make)) && west update" ]