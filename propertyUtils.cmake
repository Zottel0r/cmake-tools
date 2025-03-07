# CMake Property Tools
# this is copied and adapted from: https://stackoverflow.com/a/34292622


# Get all propreties that cmake supports
if(NOT CMAKE_PROPERTY_LIST)
    execute_process(COMMAND cmake --help-property-list OUTPUT_VARIABLE CMAKE_PROPERTY_LIST)
    # print(CMAKE_PROPERTY_LIST)
    # Convert command output into a CMake list
    string(REGEX REPLACE ";" "\\\\;" CMAKE_PROPERTY_LIST "${CMAKE_PROPERTY_LIST}")
    string(REGEX REPLACE "\n" ";" CMAKE_PROPERTY_LIST "${CMAKE_PROPERTY_LIST}")
    list(REMOVE_DUPLICATES CMAKE_PROPERTY_LIST)
endif()

function(print_target_properties target color)

    if(NOT TARGET ${target})
      message(STATUS "There is no target named '${target}'")
      return()
    endif()

    foreach(property ${CMAKE_PROPERTY_LIST})
        string(REPLACE "<CONFIG>" "${CMAKE_BUILD_TYPE}" property ${property})

        # Fix https://stackoverflow.com/questions/32197663/how-can-i-remove-the-the-location-property-may-not-be-read-from-target-error-i
        if(property STREQUAL "LOCATION" OR property MATCHES "^LOCATION_" OR property MATCHES "_LOCATION$")
            continue()
        endif()

        get_property(was_set TARGET ${target} PROPERTY ${property} SET)
        if(was_set)
            # set(${property} ${value})
            get_target_property(value ${target} ${property})
            # print(${property})
            # str2color(COLOR ${color} target)
            str2color(BOLD COLOR ${color} property)
            str2color(COLOR ${color} value)
            message(">> ${target} ${property} = ${value}")
            # message(">> ${var_name} = ${var_value} ")
        endif()
    endforeach()
endfunction()