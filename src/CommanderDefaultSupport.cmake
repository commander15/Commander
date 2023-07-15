function(commander_add_app name)
    add_x_executable(${name} WIN32 MACOSX_BUNDLE ${ARGN})
endfunction()

function(commander_add_service name)
    add_x_executable(${name} ${ARGN})
endfunction()

function(commander_add_tool name)
    add_x_executable(${name} ${ARGN})
endfunction()

function(commander_add_test name args wrk_dir sources)
    add_x_executable(${name} ${sources})
    add_x_test(NAME ${name}
        COMMAND ${name} ${args}
        WORKING_DIRECTORY ${wrk_dir}
    )
endfunction()

function(commander_add_plugin name)
    add_x_library(${name} MODULE ${ARGN})
endfunction()

function(commander_add_library name)
    add_x_library(${name} ${ARGN})
endfunction()

function(commander_finalize_target target type)
    get_target_property(OUT_DIR ${target} ${type}_OUTPUT_DIRECTORY)
    if (NOT OUT_DIR AND CMAKE_${type}_OUTPUT_DIRECTORY)
        set(OUT_DIR ${CMAKE_${type}_OUTPUT_DIRECTORY})
    else()
        return()
    endif()

    set_target_properties(${target} PROPERTIES
        ARCHIVE_OUTPUT_DIRECTORY ${OUT_DIR}
        LIBRARY_OUTPUT_DIRECTORY ${OUT_DIR}
        RUNTIME_OUTPUT_DIRECTORY ${OUT_DIR}
    )
endfunction()

function(commander_install_target target type destinations)
    unset(LIB)
    unset(RUN)
    foreach (destination ${destinations} ${destinations})
        if (NOT LIB)
            set(LIB ${destination})
        elseif (NOT RUN)
            set(RUN ${destination})
        else()
            break()
        endif()
    endforeach()

    if (${LIB} STREQUAL ${RUN})
        message(DEBUG "Installing '${target}'(${type}) to ${RUN}...")
    else()
        message(DEBUG "Installing '${target}'(${type}) to ${LIB} and ${RUN}...")
    endif()

    x_install(TARGETS ${target}
        ${ARGN}
        ARCHIVE DESTINATION ${LIB}
        LIBRARY DESTINATION ${LIB}
        RUNTIME DESTINATION ${RUN}
    )
endfunction()
