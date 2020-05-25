# Reset previously used 3rdparties
macro(reset_previously_3rdparties)
    foreach(library_name ${libraries_list})
        unset(${library_name} CACHE)	
    endforeach()
endmacro(reset_previously_3rdparties)

# Stack for add 3rdparties for subprojects
macro(push_target_stack target_name)

    list(APPEND CURRENT_TARGET_STACK ${target_name})
    set( CURRENT_TARGET ${target_name} )

    message("Target changed to ${CURRENT_TARGET}.")

endmacro(push_target_stack)

macro(pop_target_stack)

    list( LENGTH CURRENT_TARGET_STACK length)
    
    math(EXPR index "${length} - 1")
    math(EXPR new_index "${length} - 2")

    
    if(${length} GREATER "0")
        list(REMOVE_AT CURRENT_TARGET_STACK ${index})
        
        if(${new_index} GREATER "-1")
            list(GET CURRENT_TARGET_STACK ${new_index} CURRENT_TARGET)
            message("Target changed back to ${CURRENT_TARGET}.")

        else()
             set(CURRENT_TARGET "")
        endif()
        
    else()
        set(CURRENT_TARGET "")
        
        #check.. this shouldn't appear
        message(FATAL_ERROR "Popping empty target stack. Something is most definitely wrong.")
    endif()

endmacro()