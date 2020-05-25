# Unset options from previosly selected project
macro(unset_options _options_to_unset)
    foreach(_option ${_options_to_unset})
        unset(${_option} CACHE)	
    endforeach()
endmacro()

macro( CREATE_EXECUTABLE _EXECUTABLE_NAME )	

    #this updates CURRENT_TARGET
    push_target_stack(${_EXECUTABLE_NAME})
    
    set( ${CURRENT_TARGET}_HEADERS "" )
    set( ${CURRENT_TARGET}_SOURCES "" )
    add_executable(${CURRENT_TARGET} "${CMAKE_BINARY_DIR}/empty.hpp")
    
    target_include_directories(${CURRENT_TARGET} PRIVATE ${CMAKE_SOURCE_DIR}/include )

endmacro()
# Add library project to solution
macro( CREATE_LIB_TARGET _LIB_NAME )
    if( NOT _${_LIB_NAME}_INCLUDED )
        set( _${_LIB_NAME}_INCLUDED 1 )
                
        include( "${CMAKE_SOURCE_DIR}/cmake/Modules/${_LIB_NAME}.cmake" )
        
        # add definitions indicating used libs for testing in precompiled headers
        string(TOUPPER ${_LIB_NAME} capitalized_libname)
        target_compile_definitions(${CURRENT_TARGET} PRIVATE USED_LIB_${capitalized_libname})        
    endif()
endmacro()


# Create Library project
macro( CREATE_LIBRARY _LIBRARY_NAME )

    push_target_stack(${_LIBRARY_NAME})

    
    find_file(library_test_path "${_LIBRARY_NAME}.cmake" ${CMAKE_SOURCE_DIR}/Cmake/Modules NO_DEFAULT_PATH )

    if(NOT library_test_path)
        message(WARNING "Library's cmake ${_LIBRARY_NAME}.cmake was not found.")
    endif()
    
    set( ${CURRENT_TARGET}_HEADERS "" )
    set( ${CURRENT_TARGET}_SOURCES "" )

    if("${ARGV1}" STREQUAL "SHARED")
        add_library( ${CURRENT_TARGET} SHARED "${CMAKE_BINARY_DIR}/empty.hpp")
    else()
        add_library( ${CURRENT_TARGET} STATIC "" ${${CURRENT_TARGET}_CMAKES})
    endif()
    source_group("CMake files" FILES ${${CURRENT_TARGET}_CMAKES})
    unset(library_test_path CACHE)

endmacro()

# Include header directiories to target, modify list of all headers
macro( ADD_HEADER_DIRECTORY _DIR )
    file( GLOB_RECURSE __HEADERS ${_DIR}/*.h ${_DIR}/*.hxx ${_DIR}/*.hpp )

    list(LENGTH __HEADERS LENGTH)

    if( LENGTH GREATER 0 )
        list( APPEND ${CURRENT_TARGET}_HEADERS ${__HEADERS} )
        
        target_include_directories(${CURRENT_TARGET} PRIVATE ${_DIR} )
    endif()
endmacro()

# Modify list of all sources
macro( ADD_SOURCE_DIRECTORY _DIR )
    file( GLOB_RECURSE __SOURCES ${_DIR}/*.c ${_DIR}/*.cpp ${_DIR}/*.cc )
    list( APPEND ${CURRENT_TARGET}_SOURCES ${__SOURCES} )
endmacro()


macro( ADD_SOURCE_GROUPS _DIR_INCLUDE _DIR_SOURCE )

    string(FIND "${_DIR_INCLUDE}" "include" result)

    if(${result} GREATER "-1")
        set(include_group_name_postfix "")
    else()
        set(include_group_name_postfix " headers")
    endif()

    string(FIND "${_DIR_SOURCE}" "src" result)

    if(${result} GREATER "-1")
        set(src_group_name_postfix "")
    else()
        set(src_group_name_postfix " sources")
    endif()




    set(source_group_name "src")
    set(include_group_name "include")

    if(NOT "${include_group_name_postfix}" STREQUAL  "")
        set(include_group_name "${include_group_name}/{include_group_name_postfix}")
    endif()

    if(NOT "${src_group_name_postfix}" STREQUAL  "")
        set(source_group_name "${source_group_name}/${src_group_name_postfix}")
    endif()

    source_group( "${include_group_name}" REGULAR_EXPRESSION "^.*/${_DIR_INCLUDE}/[^/]*\\.(h|hxx|hpp)$" )
    source_group( "${source_group_name}" REGULAR_EXPRESSION "^.*/${_DIR_SOURCE}/[^/]*\\.(c|cpp)$" )


    string(REGEX REPLACE ".*/src" "src" out ${_DIR_SOURCE})


    foreach( subfolder ${ARGN} )

        set(source_group_name "src")
        set(include_group_name "include")

        if(NOT "/${subfolder}${include_group_name_postfix}" STREQUAL  "")
            set(include_group_name "${include_group_name}/${subfolder}${include_group_name_postfix}")
        endif()

        if(NOT "/${subfolder}${src_group_name_postfix}" STREQUAL  "")
            set(source_group_name "${source_group_name}/${subfolder}${src_group_name_postfix}")
        endif()

        source_group( ${include_group_name} REGULAR_EXPRESSION "^.*/${_DIR_INCLUDE}/${subfolder}.*\\.(h|hxx|hpp)$" )
        source_group( ${source_group_name} REGULAR_EXPRESSION "^.*/${_DIR_SOURCE}/${subfolder}.*\\.(c|cpp)$" )
    endforeach()

endmacro()