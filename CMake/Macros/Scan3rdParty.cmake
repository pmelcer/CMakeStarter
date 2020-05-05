include( ${CONFIG_CMAKE_MACROS_PATH}/Scan3rdPartyUtility.cmake )

function(run_scanning_3rdParty)

    check_one_scan_runner()

    recognize_platform()
    set_toolset()
    resetScan()

    if(NOT WIN32)
        return()
    endif()

    option( BUILD_USE_LIBRARIES_FROM_BUILD_INFO "Should be used 3rdParty library from build_info.txt" OFF)

    checkPath()
    
    SUBDIRLIST(PATH_SUBDIRS "${CONFIG_PATH_TO_3RDPARTY}")
    set(ALL_SUBDIRS "${PATH_SUBDIRS}")

    if(EXISTS "${CONFIG_PATH_TO_CUSTOM_3RDPARTY}")
        SUBDIRLIST(PATH_EXTRA_SUBDIRS "${CONFIG_PATH_TO_CUSTOM_3RDPARTY}")
        list(APPEND ALL_SUBDIRS "${PATH_EXTRA_SUBDIRS}")
    endif()

    list(LENGTH PATH_SUBDIRS len)
    if(${len} LESS 1)
        message(FATAL_ERROR "${CONFIG_PATH_TO_CUSTOM_3RDPARTY} not contains any folder.")
    endif()

    list(SORT ALL_SUBDIRS)

    set(library_names "")
    set(current_library_name "")

    # Detect the same libraries
    detect_libraries()

    # Scan build info
	scan_build_info()

    delete_detected_3rdparty()	


    foreach(library ${library_names})

    sort_libs_version("${library}_property_string")
        set(previous_value_is_experimental FALSE)
        list(FIND backup_names LIBRARY_${library} index)
        if(${index} GREATER "-1")   
            list(GET backup_values ${index} previous_value)
                    
            string(FIND ${previous_value} "experimental" result)

            if(${result} GREATER "-1")
                set(previous_value_is_experimental TRUE)
            endif()       
        endif()


        list(FIND ${library}_property_string "${previous_value}" index2)


        set(missing_previous_value FALSE)
		if("${index2}" EQUAL "-1") 
            set(missing_previous_value TRUE)
        endif()



        set(tmp_property_list ${${library}_property_string})
		list(REVERSE tmp_property_list)
			
		foreach(item ${tmp_property_list})
		
			string(FIND ${item} "experimental" result)
				   
			if(${result} GREATER "-1" AND NOT new_experimental_value)
				set(new_experimental_value ${item})
			elseif(${result} LESS "0" AND NOT new_regular_value)
				set(new_regular_value ${item})
			endif()
			
			if(new_experimental_value AND new_regular_value)
				break()
			endif()		
		endforeach()


        if(${missing_previous_value} STREQUAL "FALSE" AND NOT "${previous_value}" STREQUAL "")
            set(final_value ${previous_value})
        else()
            set(final_value ${new_regular_value})           
        endif()
        
		string(FIND "${previous_value}" " " _index)
        math(EXPR _result "${_index} + 1")
        string(SUBSTRING "${previous_value}" ${_result} -1 previous_value_version)
        
        string(FIND "${new_regular_value}" " " _index)
        math(EXPR _result "${_index} + 1")
        string(SUBSTRING "${new_regular_value}" ${_result} -1 new_regular_value_version)
        
        string(FIND "${new_experimental_value}" " " _index)
        math(EXPR _result "${_index} + 1")
        string(SUBSTRING "${new_experimental_value}" ${_result} -1 new_experimental_value_version)		


        if(NOT "${previous_value}" STREQUAL "" AND NOT "${previous_value_is_experimental}" STREQUAL "TRUE")
        
            if(NOT "${previous_value}" STREQUAL "${new_regular_value}") 
                set(newer_libraries_alert TRUE PARENT_SCOPE)
            
                list(APPEND newer_libraries_list "${library}")
            endif()
        
        elseif(NOT "${previous_value}" STREQUAL "")
        
            if("${previous_value_version}" VERSION_LESS_EQUAL "${new_regular_value_version}")  
                set(newer_libraries_alert TRUE PARENT_SCOPE)
            
                list(APPEND newer_libraries_list "experimental ${library}")

            elseif(NOT "${previous_value}" STREQUAL "${new_experimental_value}" AND "${previous_value_version}" VERSION_LESS "${new_experimental_value_version}")    

                set(newer_libraries_alert TRUE PARENT_SCOPE)
            
                list(APPEND newer_libraries_list "${library}")
            endif()

        endif()

        set(LIBRARY_${library} "${final_value}" CACHE STRING "")
        set_property(CACHE LIBRARY_${library} PROPERTY STRINGS "${${library}_property_string}")
        mark_as_advanced(CLEAR LIBRARY_${library})
        unset(previous_value)
        unset(new_regular_value)
        unset(new_experimental_value)

        list(APPEND detected_libs LIBRARY_${library})	

    endforeach()


    set(newer_libraries_list "${newer_libraries_list}" PARENT_SCOPE)
    set(previously_detected_libs ${detected_libs} CACHE INTERNAL "")

    foreach(library ${library_names})
        set(${library}_FOUND TRUE CACHE INTERNAL "")

        string(TOUPPER ${library} capitalized_name)
        set(${capitalized_name}_FOUND TRUE CACHE INTERNAL "")

        if("${LIBRARY_${library}}" IN_LIST PATH_SUBDIRS)            
            set(PATH_TO_LIB "${CONFIG_PATH_TO_3RDPARTY}")
        else()
            set(PATH_TO_LIB "${CONFIG_PATH_TO_CUSTOM_3RDPARTY}")
        endif()

        message("${PATH_SUBDIRS}")


        set(${library}_INCLUDE_DIRS "${PATH_TO_LIB}/${LIBRARY_${library}}/include" CACHE INTERNAL "")
        set(${library}_LIBRARY_DIRS "${PATH_TO_LIB}/${LIBRARY_${library}}/lib" CACHE INTERNAL "")
        set(${library}_BINARY_DIRS  "${PATH_TO_LIB}/${LIBRARY_${library}}/bin" CACHE INTERNAL "")

        set(${library}_PATH "${PATH_TO_LIB}/${LIBRARY_${library}}" CACHE INTERNAL "")

        FILELIST(tmp ${${library}_LIBRARY_DIRS})

        foreach(filename ${tmp})
            string(REGEX MATCH "^.*\\.lib$" result ${filename})

            if(NOT result STREQUAL "")
                list(APPEND ${library}_all_LIBRARIES ${filename})
            endif()
            set(result "")
        endforeach()

        list(LENGTH ${library}_all_LIBRARIES length)
        if(${length} GREATER "0")
            list(SORT ${library}_all_LIBRARIES) 
        endif()   

        foreach(filename ${${library}_all_LIBRARIES})
            string(REGEX MATCH "^.*d\\.lib$" result ${filename})
                
            if(result STREQUAL "")
                list(APPEND ${library}_optimized_LIBRARIES ${filename})
            else()			
                list(APPEND ${library}_debug_LIBRARIES ${filename})
            endif()
        
            # Debug dd.lib vs d.lib optimized cases
            string(REGEX REPLACE "^(.*d)d\\.lib$" "\\1" dd_result ${filename})

            if(NOT dd_result STREQUAL "" AND NOT ${dd_result} STREQUAL ${filename})
                list(REMOVE_ITEM ${library}_debug_LIBRARIES "${dd_result}.lib")
                list(APPEND ${library}_optimized_LIBRARIES "${dd_result}.lib")
            endif()
            
            set(dd_result "")
            set(result "")
        endforeach()

        foreach(filename ${${library}_optimized_LIBRARIES})
    
            contains_debug_lib(result debug_name ${filename} ${library}_debug_LIBRARIES)
        
            if(${result} STREQUAL "FALSE")
                list(APPEND ${library}_LIBRARIES "general" ${filename})		#all configurations
            else()
                list(APPEND ${library}_LIBRARIES "optimized" ${filename})	#all except debug
                list(APPEND ${library}_LIBRARIES "debug" ${debug_name})		#only for debug
            endif()
        
            set(result "")
            set(debug_name "")

        endforeach()    
        set(${library}_LIBRARIES ${${library}_LIBRARIES} PARENT_SCOPE)

    endforeach()
endfunction(run_scanning_3rdParty)