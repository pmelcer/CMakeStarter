# Project name

project( ${BUILD_APP_NAME} )

CREATE_EXECUTABLE( ${BUILD_APP_NAME} )

set( APP_PATH ${APPLICATION_SOURCE_FOLDER_PATH}/Sample )

# Add 3rdparties
ADD_3RDPARTY_GLFW()
ADD_3RDPARTY_GLM()
ADD_3RDPARTY_GLAD()
ADD_3RDPARTY_LINMATH()
# header files
ADD_HEADER_DIRECTORY( ${APP_PATH}/include )

# source files
ADD_SOURCE_DIRECTORY( ${APP_PATH}/src )

target_include_directories(${CURRENT_TARGET} PRIVATE ${CMAKE_CURRENT_BINARY_DIR} )

# Create library from inside cmake project
CREATE_LIB_TARGET( ${PROJECT_LIB_NAME} )

# Add all files to target
target_sources(${CURRENT_TARGET} PRIVATE 
                        ${${CURRENT_TARGET}_HEADERS}
                        ${${CURRENT_TARGET}_SOURCES}
                         )

# Create source groups
SOURCE_GROUP( "Header Files" REGULAR_EXPRESSION "^dummyrule$" )
SOURCE_GROUP( "Source Files" REGULAR_EXPRESSION "^dummyrule$" )

# Set debug postfix, output directories, etc.
set_target_properties( ${CURRENT_TARGET} PROPERTIES
                       LINKER_LANGUAGE CXX
                       PROJECT_LABEL ${CURRENT_TARGET}
                       DEBUG_POSTFIX d
                       LINK_FLAGS "${LINK_FLAGS}"
                       )

add_dependencies( ${CURRENT_TARGET} Name)

# Add libraries
target_link_libraries( ${CURRENT_TARGET} PRIVATE
                       ${PROJECT_LIB_NAME}
                       )

# Installation of files
if(WIN32)
    # Gather files first ...
    set(files "")
    set(filesd "")

    #INSTALL_LIB(${SDL_LIB_NAME})
        
    #install needed files to run..    
    INSTALL_FILES_TO_BIN("${files}" "${filesd}" .)
    
    INSTALL_REQUIRED_SYSTEM_LIBS_TO_BIN()
endif()