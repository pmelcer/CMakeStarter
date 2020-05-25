# Initialize 3rdparties stuff
############################################

set(GLAD_3RDPARTY_NAME	"GLAD")
set(GLFW_3RDPARTY_NAME	"glfw")

list(APPEND all_3rdparty_names ${GLFW_3RDPARTY_NAME})
list(APPEND all_3rdparty_names ${GLAD_3RDPARTY_NAME})

# Adding 3rdparties to target
############################################
macro(ADD_3RDPARTY_GLFW)
    ADD_3RDPARTY(${GLFW_3RDPARTY_NAME} ${ARGV})
    target_compile_definitions( ${CURRENT_TARGET} PRIVATE NOMINMAX )
endmacro()

macro(ADD_3RDPARTY_GLAD)
    ADD_3RDPARTY(${GLAD_3RDPARTY_NAME} ${ARGV})
    target_compile_definitions( ${CURRENT_TARGET} PRIVATE NOMINMAX )
endmacro()