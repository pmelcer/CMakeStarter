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

# Create default empty file
if(NOT EXISTS "${CMAKE_BINARY_DIR}/empty.hpp")
    message(STATUS "Creating empty helper file.")
    file(WRITE ${CMAKE_BINARY_DIR}/empty.hpp "")
endif()

#Include CMake macros
include( CheckCXXCompilerFlag )

#Initialize build target stack
set( CONFIG_CURRENT_TARGET_STACK "") 


# Settings for main project
set(BUILD_APP_NAME "Sample" CACHE STRING "Choose what application is required to generate.")
project( ${BUILD_APP_NAME} )
set(CMAKE_INSTALL_PREFIX ${CMAKE_BINARY_DIR}/${BUILD_APP_NAME}/bin CACHE PATH "" FORCE)

set(projects Sample Sample2)
set_property(CACHE BUILD_APP_NAME PROPERTY STRINGS "${projects}")
set(build_info_path "${CMAKE_BINARY_DIR}/${BUILD_APP_NAME}/bin/build_info.txt")

include( ${CONFIG_CMAKE_MACROS_PATH}/Utility.cmake )
include( ${CONFIG_CMAKE_MACROS_PATH}/3rdParty.cmake )
include( ${CONFIG_CMAKE_MACROS_PATH}/Scan3rdParty.cmake )
include( ${CONFIG_CMAKE_MACROS_PATH}/Project.cmake )
include( ${CONFIG_CMAKE_MACROS_PATH}/Add3rdPartyLibrary.cmake )
include( ${CONFIG_CMAKE_MACROS_PATH}/Install.cmake )

# Scanning 3rdParty libraries.
run_scanning_3rdParty()
if(NOT ${SCAN_SUCCESS} STREQUAL "TRUE")
    return()
endif()

reset_previously_3rdparties()

set(BUILD_${BUILD_APP_NAME} "TRUE")
message(STATUS "Configuring project [${BUILD_APP_NAME}]")

if(NOT PREVIOUSLY_BUILD_APP_NAME)
    set(PREVIOUSLY_BUILD_APP_NAME "" CACHE INTERNAL "")
    set(options_to_unset "" CACHE INTERNAL "")
endif()

if(NOT "${PREVIOUSLY_BUILD_APP_NAME}" STREQUAL "${BUILD_APP_NAME}")
    set(PREVIOUSLY_BUILD_APP_NAME ${BUILD_APP_NAME} CACHE INTERNAL "")

    unset_options("${options_to_unset}")
    set(options_to_unset "" CACHE INTERNAL "")
endif()

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${BUILD_APP_NAME}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${BUILD_APP_NAME}/lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${BUILD_APP_NAME}/lib)


set_property(GLOBAL PROPERTY USE_FOLDERS ON)


set( APPLICATION_SOURCE_FOLDER_PATH ${CMAKE_SOURCE_DIR}/apps)

# Project library names
set( PROJECT_LIB_NAME Name )

add_subdirectory( "${CMAKE_SOURCE_DIR}/apps/${BUILD_APP_NAME}/" ${BUILD_APP_NAME})

# Finalize generating project
file(WRITE ${build_info_path} "")

foreach(name ${all_3rdparty_names})

    string(TOUPPER ${name} capitalized_name)

    GET_PROPERTY(value GLOBAL PROPERTY USED_LIB_${capitalized_name})

    if("${value}" STREQUAL "TRUE")
        file(APPEND ${build_info_path} "${LIBRARY_${name}}\n")
        continue()
    endif()
    
    mark_as_advanced(FORCE 3RDPARTY_${name})
    mark_as_advanced(FORCE INFO_3RDPARTY-DIRS_${name})
    mark_as_advanced(FORCE INFO_INCLUDE-DIRS_${name})
    mark_as_advanced(FORCE INFO_3RDPARTY-LIST_${name})

    # try to remove these 3rdparty from newer lib alert as they are not needed for this project
    list(FIND newer_3rdparties_list "${name}" index)

    if(${index} GREATER "-1")
        list(REMOVE_ITEM newer_3rdparties_list "${name}")
    endif()
    
endforeach()

INSTALL_FILES_TO_BIN_NO_DEBUG(${build_info_path} ".")

# In the case that is required to use 3rdparties specified in 3rdparty_manifest, it is not a good idea to overwrite it in repository
if(NOT ${BUILD_USE_3RDPARTIES_FROM_BUILD_INFO})
    file(COPY ${build_info_path} DESTINATION ${CMAKE_SOURCE_DIR}/apps/${BUILD_APP_NAME})
endif()

# Sets the startup project to selected build project instead of ALL_BUILD
if(MSVC)
    set_property(DIRECTORY PROPERTY VS_STARTUP_PROJECT "${BUILD_APP_NAME}")
endif()

# Deduplicate collected flags - shouldn't be necessary..
string(REPLACE " " ";" list_CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
list(REMOVE_DUPLICATES list_CMAKE_CXX_FLAGS)
string(REPLACE ";" " " CMAKE_CXX_FLAGS "${list_CMAKE_CXX_FLAGS}")

list(LENGTH newer_3rdparties_list length)

if(newer_3rdparties_alert AND ${length} GREATER "0")
    message(AUTHOR_WARNING "There are some new versions (or old missing) of 
    libraries since last Configure was run. Consider deleting cache for the 
    newest versions of everything or you can verify if these 
    libraries are in order: ${newer_3rdparties_list}")
endif()