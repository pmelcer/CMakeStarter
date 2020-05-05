# Unset options from previosly selected project
macro(unset_options _options_to_unset)
    foreach(_option ${_options_to_unset})
        unset(${_option} CACHE)	
    endforeach()
endmacro()