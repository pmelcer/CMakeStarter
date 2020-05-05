##########################################################
cmake_minimum_required(VERSION 3.15)
message(STATUS "CMake version ${CMAKE_VERSION}")

# Compilation flags and settings
set(CMAKE_CONFIGURATION_TYPES Release Debug)

if( NOT MSVC )
      set( CMAKE_BUILD_TYPE "Release" CACHE STRING "Choose the build type." )
      set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Release;Debug")
endif()

# Initialize CXX
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS ON) 

# CMake settings
set( CONFIG_CMAKE_ROOT_DIR ${CMAKE_SOURCE_DIR} )
set( CONFIG_CMAKE_MACROS_PATH "${CONFIG_CMAKE_ROOT_DIR}/CMake/Macros" )
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CONFIG_CMAKE_MACROS_PATH}")



#Include CMake macros
include( CheckCXXCompilerFlag )

#Initialize build target stack
set( CONFIG_CURRENT_TARGET_STACK "") 


# Settings for main project
set(BUILD_APP_NAME "Sample" CACHE STRING "Choose what application is required to generate.")
project( ${BUILD_APP_NAME} )
set(CMAKE_INSTALL_PREFIX ${CMAKE_BINARY_DIR}/${BUILD_APP_NAME}/bin CACHE PATH "" FORCE)

include( ${CONFIG_CMAKE_MACROS_PATH}/Utility.cmake )
include( ${CONFIG_CMAKE_MACROS_PATH}/3rdParty.cmake )
include( ${CONFIG_CMAKE_MACROS_PATH}/Scan3rdParty.cmake )

# Scanning 3rdParty libraries.
run_scanning_3rdParty()
if(NOT ${SCAN_SUCCESS} STREQUAL "TRUE")
    return()
endif()