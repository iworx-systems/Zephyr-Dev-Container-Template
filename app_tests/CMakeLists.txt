# SPDX-License-Identifier: Apache-2.0

cmake_minimum_required(VERSION 3.20.0)

find_package(Zephyr REQUIRED HINTS $ENV{ZEPHYR_BASE})

project($ENV{PROJECT_NAME}test)

# Setup test framework
test_runner_generate(src/main.c)
cmock_handle(${ZEPHYR_BASE}/include/zephyr/drivers/gpio.h drivers)

# Add build sources
FILE(GLOB test_sources src/*.c)
target_sources(app PRIVATE 
    ${test_sources}
)
