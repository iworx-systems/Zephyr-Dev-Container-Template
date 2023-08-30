
cmake_minimum_required(VERSION 3.20.0)


#******************* PROGRAMMING/DEBUG ****************
set(BOARD_FLASH_RUNNER jlink)
set(BOARD_DEBUG_RUNNER jlink)

#*********************** ZEPHYR ***********************

#Add project config file if it isn't already defined (such as when no building with sysbuild)
if(NOT EXISTS CONF_FILE)
    set(CONF_FILE ${CMAKE_CURRENT_LIST_DIR}/sysbuild/app/prj.conf)
endif()

find_package(Zephyr REQUIRED HINTS $ENV{ZEPHYR_BASE})

#*********************** APPLICATION ***********************
project(Zephyr-Dev-Container-Template)

# Verify through sysbuild that MCUboot is
# included and that MCUboot configurations are
# used when building MCUboot.
test_sysbuild()

#sources
FILE(GLOB app_sources src/*.c)

target_sources(app PRIVATE ${app_sources})
target_include_directories(app PRIVATE ${CMAKE_CURRENT_LIST_DIR}/include)

