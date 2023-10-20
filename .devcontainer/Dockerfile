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

ARG ZEPHYR_VERSION=v3.4.0
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

ARG ZEPHYR_SDK_VERSION=0.16.1
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

FROM sdk AS cmock_unity_module

RUN \
  apt-get -y update \
  && apt-get -y install --no-install-recommends \
  xz-utils file make gcc gcc-multilib g++-multilib libsdl2-dev libmagic1 curl \
	ruby \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

FROM cmock_unity_module AS qemu_x86

RUN \
  apt-get -y update \
  && apt-get -y install \
  qemu-system-x86 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

FROM qemu_x86 AS shell_tools

RUN \
  apt-get -y update \
  && apt-get -y install \
  shellcheck \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

FROM shell_tools as codechecker
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

# !!! This must match the workspace root !!!
ENV PRJ_ROOT_DIR /workspaces/Zephyr-Dev-Container-Template

ENV TEST_DIR ${PRJ_ROOT_DIR}/app_tests
ENV APP_DIR ${PRJ_ROOT_DIR}/app
ENV ZEPHYR_BASE ${PRJ_ROOT_DIR}/zephyr_project/zephyr
ENV NET_TOOLS_BASE ${PRJ_ROOT_DIR}/zephyr_project/tools/net-tools
ENV APP_CODECHECKER_CONFIG_FILE ${PRJ_ROOT_DIR}/app/codechecker.json
