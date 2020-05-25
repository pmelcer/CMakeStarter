include( ${CONFIG_CMAKE_MACROS_PATH}/Scan3rdPartyUtility.cmake )

function(run_scanning_3rdParty)

    check_one_scan_runner()

    recognize_platform()
    set_toolset()
    resetScan()

    if(NOT WIN32)
        return()
    endif()

    option( BUILD_USE_3RDPARTIES_FROM_BUILD_INFO "Should be used 3rdParty library from build_info.txt" OFF)

    checkPath()
    
    SUBDIRLIST(PATH_SUBDIRS "${CONFIG_PATH_TO_3RDPARTY}")
    set(ALL_SUBDIRS "${PATH_SUBDIRS}")

    if(EXISTS "${CONFIG_PATH_TO_CUSTOM_3RDPARTY}")
        SUBDIRLIST(PATH_EXTRA_SUBDIRS "${CONFIG_PATH_TO_CUSTOM_3RDPARTY}")
        list(APPEND ALL_SUBDIRS "${PATH_EXTRA_SUBDIRS}")
    endif()

    list(LENGTH PATH_SUBDIRS len)
    if(${len} LESS 1)
        message("${CONFIG_PATH_TO_3RDPARTY} ${CONFIG_PATH_TO_CUSTOM_3RDPARTY} not contains any folder.")
        return()
    endif()

    list(SORT ALL_SUBDIRS)

    set(3rdParty_names "")
    set(current_3rdParty_name "")

    # Detect the same 3rdParties
    detect_3rdParties()

    # Scan build info
	scan_build_info()

    delete_detected_3rdparty()	

    foreach(3rdParty ${3rdParty_names})

        sort_libs_version("${3rdParty}_property_string")
        
        resolve_experimental_suffix()

        list(FIND ${3rdParty}_property_string "${previous_value}" index2)

        set(missing_previous_value FALSE)
		if("${index2}" EQUAL "-1") 
            set(missing_previous_value TRUE)
        endif()

        set(tmp_property_list ${${3rdParty}_property_string})
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
                set(newer_3rdParties_alert TRUE PARENT_SCOPE)
            
                list(APPEND newer_3rdParties_list "${3rdParty}")
            endif()
        
        elseif(NOT "${previous_value}" STREQUAL "")
        
            if("${previous_value_version}" VERSION_LESS_EQUAL "${new_regular_value_version}")  
                set(newer_3rdParties_alert TRUE PARENT_SCOPE)
            
                list(APPEND newer_3rdParties_list "experimental ${3rdParty}")

            elseif(NOT "${previous_value}" STREQUAL "${new_experimental_value}" AND "${previous_value_version}" VERSION_LESS "${new_experimental_value_version}")    

                set(newer_3rdParties_alert TRUE PARENT_SCOPE)
            
                list(APPEND newer_3rdParties_list "${3rdParty}")
            endif()

        endif()

        set(3RDPARTY_${3rdParty} "${final_value}" CACHE STRING "")
        set_property(CACHE 3RDPARTY_${3rdParty} PROPERTY STRINGS "${${3rdParty}_property_string}")
        mark_as_advanced(CLEAR 3RDPARTY_${3rdParty})
        unset(previous_value)
        unset(new_regular_value)
        unset(new_experimental_value)

        list(APPEND detected_libs 3RDPARTY_${3rdParty})	

    endforeach()


    set(newer_3rdParties_list "${newer_3rdParties_list}" PARENT_SCOPE)
    set(previously_detected_3rdparty ${detected_libs} CACHE INTERNAL "")

    foreach(3rdParty ${3rdParty_names})
        set(${3rdParty}_FOUND TRUE CACHE INTERNAL "")

        string(TOUPPER ${3rdParty} capitalized_name)
        set(${capitalized_name}_FOUND TRUE CACHE INTERNAL "")

        if("${3RDPARTY_${3rdParty}}" IN_LIST PATH_SUBDIRS)            
            set(PATH_TO_LIB "${CONFIG_PATH_TO_3RDPARTY}")
        else()
            set(PATH_TO_LIB "${CONFIG_PATH_TO_CUSTOM_3RDPARTY}")
        endif()

        set(${3rdParty}_INCLUDE_DIRS "${PATH_TO_LIB}/${3RDPARTY_${3rdParty}}/include" CACHE INTERNAL "")
        set(${3rdParty}_3RDPARTY_DIRS "${PATH_TO_LIB}/${3RDPARTY_${3rdParty}}/lib" CACHE INTERNAL "")
        set(${3rdParty}_BINARY_DIRS  "${PATH_TO_LIB}/${3RDPARTY_${3rdParty}}/bin" CACHE INTERNAL "")

        set(${3rdParty}_PATH "${PATH_TO_LIB}/${3RDPARTY_${3rdParty}}" CACHE INTERNAL "")

        FILELIST(tmp ${${3rdParty}_3RDPARTY_DIRS})
        foreach(filename ${tmp})
            string(REGEX MATCH "^.*\\.lib$" result ${filename})

            if(NOT result STREQUAL "")
                list(APPEND ${3rdParty}_all_3RDPARTIES ${filename})
            endif()
            set(result "")
        endforeach()

        list(LENGTH ${3rdParty}_all_3RDPARTIES length)
        if(${length} GREATER "0")
            list(SORT ${3rdParty}_all_3RDPARTIES) 
        endif()   

        foreach(filename ${${3rdParty}_all_3RDPARTIES})

            set(is_all_name False)

            foreach(3rdname ${all_3rdparty_names})
                string(TOLOWER ${3rdname} 3rdname_lower)
                string(TOLOWER ${filename} filename_lower)

                if("${3rdname_lower}.lib" STREQUAL ${filename_lower})
                    set(is_all_name True)
                    break()
                endif()
            endforeach()

            if(NOT is_all_name)
                string(REGEX MATCH "^.*d\\.lib$" result ${filename})
            endif()
            if(result STREQUAL "")
                list(APPEND ${3rdParty}_optimized_3RDPARTIES ${filename})
            else()			
                list(APPEND ${3rdParty}_debug_3RDPARTIES ${filename})
            endif()

            # Debug dd.lib vs d.lib optimized cases
            string(REGEX REPLACE "^(.*d)d\\.lib$" "\\1" dd_result ${filename})

            if(NOT dd_result STREQUAL "" AND NOT ${dd_result} STREQUAL ${filename})
                list(REMOVE_ITEM ${3rdParty}_debug_3RDPARTIES "${dd_result}.lib")
                list(APPEND ${3rdParty}_optimized_3RDPARTIES "${dd_result}.lib")
            endif()
            
            set(dd_result "")
            set(result "")
        endforeach()

        foreach(filename ${${3rdParty}_optimized_3RDPARTIES})
    
            contains_debug_lib(result debug_name ${filename} ${3rdParty}_debug_3RDPARTIES)
        
            if(${result} STREQUAL "FALSE")
                list(APPEND ${3rdParty}_3RDPARTIES "general" ${filename})		#all configurations
            else()
                list(APPEND ${3rdParty}_3RDPARTIES "optimized" ${filename})	#all except debug
                list(APPEND ${3rdParty}_3RDPARTIES "debug" ${debug_name})		#only for debug
            endif()
        
            set(result "")
            set(debug_name "")

        endforeach()    
        set(${3rdParty}_3RDPARTIES ${${3rdParty}_3RDPARTIES} PARENT_SCOPE)

    endforeach()
endfunction(run_scanning_3rdParty)