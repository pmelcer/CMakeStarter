# Get directory list in directory
macro(SUBDIRLIST result directory)
    file(GLOB subfolders RELATIVE ${directory} ${directory}/*)
    set(dirlist "")
    foreach(subfolder ${subfolders})
        if(IS_DIRECTORY ${directory}/${subfolder})
            list(APPEND dirlist "${subfolder}")
        endif()
    endforeach()
    set(${result} ${dirlist})
endmacro()

# Get file list in directory
macro(FILELIST result directory)
    file(GLOB files RELATIVE ${directory} ${directory}/*)
    set(filelist "")
    foreach(one_file ${files})
        if(NOT IS_DIRECTORY ${directory}/${one_file})
            list(APPEND filelist "${one_file}")
        endif()
    endforeach()
    set(${result} ${filelist})
endmacro()