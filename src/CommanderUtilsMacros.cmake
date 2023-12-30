### Headers Management

function(generate_nested_headers destination)
    # Check if the header file exists and generate nested header file accordingly
    foreach (header ${ARGN})
        if (EXISTS ${header})
            file(RELATIVE_PATH path ${destination} ${header})
        elseif (EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${header})
            file(RELATIVE_PATH path ${destination} ${CMAKE_CURRENT_SOURCE_DIR}/${header})
        else()
            message(FATAL_ERROR "Can't find header file ${header}")
        endif()

        get_filename_component(header ${header} NAME)
        file(WRITE ${destination}/${header} "#include \"${path}\"")
    endforeach()
endfunction()
