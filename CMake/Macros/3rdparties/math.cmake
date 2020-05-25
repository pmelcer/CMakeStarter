# Initialize 3rdparties stuff
############################################
set(LINMATH_3RDPARTY_NAME	"linmath")
set(GLM_3RDPARTY_NAME	"glm")

list(APPEND all_3rdparty_names ${LINMATH_3RDPARTY_NAME})
list(APPEND all_3rdparty_names ${GLM_3RDPARTY_NAME})


# Adding 3rdparties to target
############################################
macro(ADD_3RDPARTY_GLM)
ADD_3RDPARTY(${GLM_3RDPARTY_NAME} ${ARGV})
target_compile_definitions( ${CURRENT_TARGET} PRIVATE NOMINMAX )
endmacro()

macro(ADD_3RDPARTY_LINMATH)
ADD_3RDPARTY(${LINMATH_3RDPARTY_NAME} ${ARGV})
target_compile_definitions( ${CURRENT_TARGET} PRIVATE NOMINMAX )
endmacro()