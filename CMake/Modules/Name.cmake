CREATE_LIBRARY( Name )

##################################################################
# Options
set( NAME_LIB_INCLUDE modules/Name/include )
set( NAME_LIB_SRC modules/Name/src )

target_include_directories(${CURRENT_TARGET} PRIVATE ${CMAKE_SOURCE_DIR}/${NAME_LIB_INCLUDE} )


ADD_3RDPARTY_GLM()

##################################################################
# Add Headers and Sources

ADD_HEADER_DIRECTORY( ${CMAKE_SOURCE_DIR}/${NAME_LIB_INCLUDE} )
ADD_SOURCE_DIRECTORY( ${CMAKE_SOURCE_DIR}/${NAME_LIB_SRC} )


##################################################################
# Finalize library
target_sources(${CURRENT_TARGET} PRIVATE "${${CURRENT_TARGET}_HEADERS}" "${${CURRENT_TARGET}_SOURCES}")

ADD_SOURCE_GROUPS( ${NAME_LIB_INCLUDE}
                   ${NAME_LIB_SRC}

                   GUI
)


set_target_properties( ${CURRENT_TARGET} PROPERTIES
                PROJECT_LABEL lib${CURRENT_TARGET}
                DEBUG_POSTFIX d
                LINK_FLAGS "${LINK_FLAGS}"
)

pop_target_stack()