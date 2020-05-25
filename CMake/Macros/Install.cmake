# Install no debug files to bin output
macro( INSTALL_FILES_TO_BIN_NO_DEBUG files_to_install subfolder)

    foreach(item ${files_to_install})
    
        get_filename_component(tmp_directory_path ${item} DIRECTORY)
        get_filename_component(tmp_item_name ${item} NAME)

        find_file(tmp_result "${tmp_item_name}" "${tmp_directory_path}" NO_DEFAULT_PATH)

        if(tmp_result)
            install(FILES ${item}       DESTINATION Debug/${subfolder}			CONFIGURATIONS Debug)
            install(FILES ${item}		DESTINATION RelWithDebInfo/${subfolder} CONFIGURATIONS RelWithDebInfo)
            install(FILES ${item}		DESTINATION Release/${subfolder}		CONFIGURATIONS Release)
        endif()
        
        unset(tmp_result CACHE)
    
    endforeach()
        
endmacro()

# Install files to bin output
macro( INSTALL_FILES_TO_BIN files_to_install debug_files_to_install subfolder)

    foreach(item ${files_to_install})
        get_filename_component(tmp_directory_path ${item} DIRECTORY)
        get_filename_component(tmp_item_name ${item} NAME)

        find_file(tmp_result "${tmp_item_name}" "${tmp_directory_path}" NO_DEFAULT_PATH)

        if(tmp_result)
            install(FILES ${item}		DESTINATION RelWithDebInfo/${subfolder} CONFIGURATIONS RelWithDebInfo)
            install(FILES ${item}		DESTINATION Release/${subfolder}		CONFIGURATIONS Release)
        endif()
        unset(tmp_result CACHE)
    endforeach()
    
    foreach(item ${debug_files_to_install})
        get_filename_component(tmp_directory_path ${item} DIRECTORY)
        get_filename_component(tmp_item_name ${item} NAME)
        find_file(tmp_result "${tmp_item_name}" "${tmp_directory_path}" NO_DEFAULT_PATH)
        if(tmp_result)
            install(FILES ${item} DESTINATION Debug/${subfolder} CONFIGURATIONS Debug)
        endif()
        unset(tmp_result CACHE)
    endforeach()
endmacro(INSTALL_FILES_TO_BIN)

# Installation of requred libs on windows
function(INSTALL_REQUIRED_SYSTEM_LIBS_TO_BIN)

    if(NOT WIN32)
        return()
    endif()

    #Install basic ms redistributable stuff everytime..
    if(NOT BUILD_INSTALL_ALSO_REQUIRED_SYSTEM_LIBS)
    
        set(CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP TRUE)    #prevent immediate install

        include(InstallRequiredSystemLibraries)             #this does the work

        message(STATUS "Found required system libraries: ${CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS}")

        string(REPLACE "\\" "/" fixed_CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS "${CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS}")

        INSTALL_FILES_TO_BIN_NO_DEBUG("${fixed_CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS}" .)

        return()
    endif()
     
    
    set(CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP TRUE)    #prevent immediate install
    set(CMAKE_INSTALL_UCRT_LIBRARIES TRUE)              #this catches all the tiny ucrt libraries
        
    include(InstallRequiredSystemLibraries)             #this does the work
        
    message(STATUS "Found required system libraries: ${CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS}")
        
    # https://braintrekking.wordpress.com/2013/04/27/dll-hell-how-to-include-microsoft-redistributable-runtime-libraries-in-your-cmakecpack-project/    
    # https://cmake.org/cmake/help/v3.9/module/InstallRequiredSystemLibraries.html
    
    string(REPLACE "\\" "/" fixed_CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS "${CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS}")

    INSTALL_FILES_TO_BIN_NO_DEBUG("${fixed_CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS}" .)       
endfunction()