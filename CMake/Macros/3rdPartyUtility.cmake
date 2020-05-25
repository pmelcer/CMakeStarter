# Adding 3rdparty library to target
macro(ADD_3RDPARTY 3RDPARTY_NAME)

    set(arguments ${ARGN})
    list(LENGTH arguments num_extra_args)
    
    if("${num_extra_args}" GREATER "0")
        message(STATUS "Adding ${3RDPARTY_NAME} to target ${CURRENT_TARGET}. ${arguments} components only.")
    else()
        message(STATUS "Adding ${3RDPARTY_NAME} to target ${CURRENT_TARGET}.")
    endif()
    
    string(TOUPPER ${3RDPARTY_NAME} capitalized_3rdpartyame)
  
    # Add definitions indicating used libs for testing in precompiled headers
    target_compile_definitions(${CURRENT_TARGET} PRIVATE USED_3RDPARTY_${capitalized_3rdpartyame})
    
    # All without this property are hidden by marking them as advanced.
    # It is a property because one scope level up (with PARENT_SCOPE) doesn't have to be enough.
    SET_PROPERTY(GLOBAL PROPERTY USED_3RDPARTY_${capitalized_3rdpartyame} "TRUE")

    # Undefined 3rdpartyname_found means it is not in folder..
    if(NOT ${3RDPARTY_NAME}_FOUND OR ${${3RDPARTY_NAME}_FOUND} STREQUAL "FALSE")
        
        
        # Scanning 3rdparties didn't find this 3rdparty or platform is not Windows. Try find different way.
        message(STATUS "Looking for 3rdparty ${3RDPARTY_NAME}.")

        find_package(${3RDPARTY_NAME})
        
        if(${3RDPARTY_NAME}_FOUND)
            message("Success.")
        else()
            message(FATAL_ERROR "${3RDPARTY_NAME} was not found. Check the 3rdparty folder.")
        endif()      
    endif()

    #check for empty lists before adding include/link directories..
    if(NOT "${${3RDPARTY_NAME}_INCLUDE_DIRS}" STREQUAL "")
        target_include_directories(${CURRENT_TARGET} PRIVATE ${${3RDPARTY_NAME}_INCLUDE_DIRS})
        
        set( INFO_INCLUDE-DIRS_${3RDPARTY_NAME} ${${3RDPARTY_NAME}_INCLUDE_DIRS} CACHE STRING "${3RDPARTY_NAME} include dirs." FORCE)
        
        list(APPEND info_variable_list INFO_INCLUDE-DIRS_${3RDPARTY_NAME})
    endif()

    if(NOT ${${3RDPARTY_NAME}_3RDPARTY_DIRS} STREQUAL "")	
        set( INFO_3RDPARTY-LIST_${3RDPARTY_NAME} ${${3RDPARTY_NAME}_3RDPARTIES} CACHE STRING "${3RDPARTY_NAME} 3rdparties."  FORCE)
        set( INFO_3RDPARTY-DIRS_${3RDPARTY_NAME} ${${3RDPARTY_NAME}_3RDPARTY_DIRS} CACHE STRING "${3RDPARTY_NAME} 3rdparty dirs."  FORCE)
        mark_as_advanced(CLEAR INFO_3RDPARTY-LIST_${3RDPARTY_NAME} INFO_3RDPARTY-DIRS_${3RDPARTY_NAME})
                
        list(APPEND info_variable_list INFO_3RDPARTY-LIST_${3RDPARTY_NAME})
        list(APPEND info_variable_list INFO_3RDPARTY-DIRS_${3RDPARTY_NAME})
        
        # Go through the 3rdparties, extract keyword, prepend path and link it to current target
        foreach(3rdparty ${${3RDPARTY_NAME}_3RDPARTIES})
            
            if(${3rdparty} STREQUAL "debug" OR ${3rdparty} STREQUAL "optimized" OR ${3rdparty} STREQUAL "general")
                set(keyword ${3rdparty})
                continue()
            endif()
        
            target_link_libraries(${CURRENT_TARGET} PRIVATE "${keyword}" "${${3RDPARTY_NAME}_3RDPARTY_DIRS}/${3rdparty}")
        endforeach()
        
        message(STATUS "Linked 3rdparty at ${${3RDPARTY_NAME}_3RDPARTY_DIRS}: ${${3RDPARTY_NAME}_3RDPARTIES}")
    endif()
endmacro()