# Scanning must be only once, it is not allowed multiple scanning
macro(check_one_scan_runner)
    if(NOT DEFINED scan_runned)
        set(scan_runned TRUE PARENT_SCOPE)
    else()
        message(WARNING "Scanning is already running.")
        return()
    endif()
endmacro(check_one_scan_runner)


# Remove previously detected 3rdparty libraries
function(delete_detected_3rdparty)	
    foreach(3rdparty_name ${previously_detected_3rdparty})
        unset(${3rdparty_name} CACHE)	
    endforeach()
endfunction()

# Order libraries by version
macro(sort_libs_version _library_version_list)
    unset(ordered_list)
    
    foreach(version ${${_library_version_list}})
        
        if(NOT ordered_list)
            list(APPEND ordered_list ${version})
            list(APPEND ordered_list "999999999")
            continue()
        endif()
    
        #get only the version string..
        string(FIND ${version} " " _index)

        math(EXPR _result "${_index} + 1")
        string(SUBSTRING "${version}" ${_result} -1 version1)
        
        
        set(pointer 0)
        
        foreach(item2 ${ordered_list})
                        
            string(FIND ${item2} " " _index)
            math(EXPR _result "${_index} + 1")
            string(SUBSTRING ${item2} ${_result} -1 version2)
        
            if("${version2}" VERSION_GREATER "${version1}")
                list(INSERT ordered_list ${pointer} ${version})
                break()
            endif()
            
            math(EXPR pointer "${pointer} + 1")
        endforeach()

        
    endforeach()
    list(REMOVE_ITEM ordered_list "999999999")
    set(${_list} ${ordered_list})    
endmacro()

macro(scan_build_info)
    if(EXISTS "${CONFIG_CMAKE_ROOT_DIR}/apps/${BUILD_APP_NAME}/build_info.txt" AND ${BUILD_USE_LIBRARIES_FROM_BUILD_INFO})

        file(STRINGS "${CMAKE_SOURCE_DIR}/apps/${BUILD_APP_NAME}/build_info.txt" lines)
        foreach(line ${lines})
            string(FIND "${line}" " " _index)
            string(SUBSTRING "${line}" 0 ${_index} library_name)
            list(APPEND backup_names LIBRARY_${library_name})
            list(APPEND backup_values ${line})
        endforeach()
    else()
        set(backup_names ${previously_detected_libs})
        foreach(libname ${previously_detected_libs})
            list(APPEND backup_values ${${libname}})
        endforeach()
    endif()
endmacro()

macro(contains_debug_lib result debug_name filename debug_list)

    string(REPLACE ".lib" "d.lib" ${debug_name} ${filename})
    
    list(FIND ${debug_list} ${${debug_name}} found)
    if(${found} GREATER "-1")
        set(${result} TRUE)
    else()
        set(${result} FALSE)
    endif()
    
endmacro()

# Recognize platform
function(recognize_platform)
    message(STATUS ${CMAKE_GENERATOR})
    if(CMAKE_GENERATOR MATCHES "^.*x32$")
        set (architecture "x32" PARENT_SCOPE)
        message(STATUS "Architecture: x32")
    else()
        set (architecture "x64" PARENT_SCOPE)
        message(STATUS "Architecture: x64")
    endif()
endfunction(recognize_platform)

function(set_toolset)

    string(REPLACE " " ";" list_CMAKE_GENERATOR ${CMAKE_GENERATOR})
    list(GET list_CMAKE_GENERATOR 2 compiler_version)

    message(STATUS "Compiler: ${CMAKE_CXX_COMPILER_ID}, version: ${compiler_version}")

    if(NOT "${CMAKE_GENERATOR_TOOLSET}" STREQUAL "")
        message(STATUS  "Toolset: ${CMAKE_GENERATOR_TOOLSET}")
        string(SUBSTRING ${CMAKE_GENERATOR_TOOLSET} 1 2 toolset_number)
    else()
        message(STATUS  "Toolset: ${CMAKE_VS_PLATFORM_TOOLSET}")
        string(SUBSTRING ${CMAKE_VS_PLATFORM_TOOLSET} 1 2 toolset_number)
    endif()

endfunction(set_toolset)


function(checkPath)
    set(CONFIG_PATH_TO_3RDPARTY "R:/${architecture}" CACHE PATH "Path to folder with your 3rdParty library.")
    set(CONFIG_PATH_TO_CUSTOM_3RDPARTY "" CACHE PATH "Location for private or obsolete library.")

    if(NOT EXISTS "${CONFIG_PATH_TO_3RDPARTY}")
        message(WARNING "Path '${CONFIG_PATH_TO_3RDPARTY}' does not exist!")
        set(scan_runned FALSE)
        set(SCAN_SUCCESS FALSE PARENT_SCOPE)
        return()
    else()
        message(STATUS "3rdParty path: ${CONFIG_PATH_TO_3RDPARTY}.")
        set(SCAN_SUCCESS TRUE PARENT_SCOPE)
    endif()

    if(NOT IS_DIRECTORY ${CONFIG_PATH_TO_3RDPARTY})	
        message(FATAL_ERROR "${CONFIG_PATH_TO_3RDPARTY} is not an existing directory.")
    endif()
endfunction(checkPath)

# reset scan variables for 3rdParty library
function(resetScan)
    if(NOT 3rdparty_names)
        message(FATAL_ERROR "3rdparty_names not defined.")
    endif()

    foreach(name ${3rdparty_names})
        set(${name}_FOUND FALSE CACHE INTERNAL "")
        string(TOUPPER ${name} capitalized_name)
        set(${capitalized_name}_FOUND FALSE CACHE INTERNAL "")
    endforeach()
endfunction(resetScan)


macro(detect_libraries)
    foreach(dirname ${ALL_SUBDIRS})
        string(REPLACE " " ";" list_dirname ${dirname})
        list(GET list_dirname 0 tmp_libname)

        if(tmp_libname STREQUAL current_libname)
            list(APPEND ${current_libname}_property_string ${dirname})		       
        else()
            set(current_libname ${tmp_libname})
            list(APPEND library_names ${current_libname})
            set(${current_libname}_property_string ${dirname})
        endif()
    endforeach()
endmacro(detect_libraries)