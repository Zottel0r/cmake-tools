include(${CMAKE_CURRENT_LIST_DIR}/stringTools.cmake)

#
# Usage:
# msg(<msg_type> <variable|string>)
# outputs a colored Message according to:
# - HIGH: Magenta
# - NOTE: Cyan
# - OK:   Green
# - WARN: BoldYellow
# - ERR:  Red
# - CRIT: BoldRed
function(msg msg_type msg_var)
    if(${msg_type} STREQUAL HIGH OR ${msg_type} STREQUAL INFO)
        str2color(COLOR magenta msg_var)
        message(" ## ${msg_var} ")
    elseif(${msg_type} STREQUAL NOTE OR ${msg_type} STREQUAL STATUS)
        str2color(COLOR Cyan msg_var)
        message(" ## ${msg_var} ")
    elseif(${msg_type} STREQUAL OK)
        str2color(COLOR Green msg_var)
        message(" ## ${msg_var} ")
    elseif(${msg_type} STREQUAL ERR)
        str2color(COLOR Red msg_var)
        message(" ## ${msg_var} ")
    elseif(${msg_type} STREQUAL CRIT)
        str2color(BOLD COLOR Red msg_var)
        message(" ## ${msg_var} ")
    elseif(${msg_type} STREQUAL WARN)
        str2color(BOLD COLOR Yellow msg_var)
        message(" ## ${msg_var} ")
    else()
        message(${msg_type} ${msg_var})
    endif()
endfunction()

#
# Usage:
# printVar(<variable>)
function(printVar)
    if(NOT DEFINED PRINT_COLOR)
        set(PRINT_COLOR White)
    endif()

    set(var_name ${ARGV0})
    set(var_value ${${ARGV0}})

    str2color(BOLD COLOR ${PRINT_COLOR} var_name)
    str2color(COLOR ${PRINT_COLOR} var_value)

    message(">> ${var_name} = ${var_value} ")
endfunction()

#
# Usage:
# print(<variable> [COLOR <color>])
# print(<list> [NUM <num_values_shown>] [GLUE <glue_string>]  [COLOR <color>] [BREAK])
function(print)
    set(options BREAK)
    set(oneValueArgs NUM GLUE COLOR)
    set(multiValueArgs)
    cmake_parse_arguments(p "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    list(LENGTH ${ARGV0} len)

    if(p_COLOR)
        set(PRINT_COLOR ${p_COLOR})
    endif()

    if(len GREATER 1)
        printList(${ARGV0} ${ARGN})
    else()
        printVar(${ARGV0})
    endif()
endfunction()

#
# Usage:
# printList(<list> [NUM <num_values_shown>] [GLUE <glue_string>] [BREAK])
function(printList liste)
    if(NOT DEFINED PRINT_COLOR)
        set(PRINT_COLOR White)
    endif()

    set(options BREAK)
    set(oneValueArgs NUM GLUE)
    set(multiValueArgs)
    cmake_parse_arguments(p "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    set(sep ": ")

    if(p_GLUE)
        set(glue ${p_GLUE})

        if(p_BREAK)
            set(sep ":\n${glue}")
            set(glue "\n${glue}")
        else()
            set(sep ": ")
        endif()
    else()
        set(glue "\n  -- ")
        set(sep ": ${glue}")
    endif()

    if(p_BREAK OR p_GLUE)
        set(sep "${sep}")
    else()
        set(glue ";")
    endif()

    list(LENGTH ${liste} len)
    set(myList "${${liste}}")
    set(name ${liste})
    set(start 0)
    set(stop ${len})

    if(p_NUM GREATER 0)
        set(stop ${p_NUM})
    elseif(p_NUM LESS 0)
        math(EXPR start "${len} + ${p_NUM}" OUTPUT_FORMAT DECIMAL)
    endif()

    list(SUBLIST ${liste} ${start} ${stop} liste)

    str2color(BOLD COLOR ${PRINT_COLOR} name)

    list(GET liste 0 result)
    str2color(COLOR ${PRINT_COLOR} result)

    list(SUBLIST liste 1 ${stop} liste)
    foreach(v ${liste})
        str2color(COLOR ${PRINT_COLOR} v)
        set(result "${result}${glue}${v}")
    endforeach()
    message(">> ${name}${sep}${result}")
endfunction()

#
# Usage:
# dump_variables()
# dump_variables([NUM <num_values_shown>] [GLUE <glue_string>] [BREAK])
# dump_variables(<include_regex> [NUM <num_values_shown>] [GLUE <glue_string>] [BREAK])
# dump_variables(<include_regex> <exclude_regex> [NUM <num_values_shown>] [GLUE <glue_string>] [BREAK])
function(dump_variables)
    set(options BREAK)
    set(oneValueArgs NUM GLUE COLOR)
    set(multiValueArgs)
    cmake_parse_arguments(p "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    #Compatibility to CMake 3.14 (Yocto)
    # list(POP_FRONT p_UNPARSED_ARGUMENTS regexp_i)
    # list(POP_FRONT p_UNPARSED_ARGUMENTS regexp_e)
    list(LENGTH p_UNPARSED_ARGUMENTS length)
    if(length GREATER 0)
        list(GET p_UNPARSED_ARGUMENTS 0 regexp_i)
    endif ()
    if(length GREATER 1)
        list(GET p_UNPARSED_ARGUMENTS 1 regexp_e)
    endif ()

    # Formatting parameters to passed by
    if(p_COLOR)
        list(APPEND printArgs COLOR ${p_COLOR})
    endif()
    if(p_GLUE)
        list(APPEND printArgs GLUE ${p_GLUE})
    endif()
    if(p_BREAK)
        list(APPEND printArgs BREAK)
    endif()
    message(" -------------------- ")

    # Filter list by include/exclude patterns
    get_cmake_property(_variableNames VARIABLES)
    list(SORT _variableNames)
    foreach(_variableName ${_variableNames})
        if(regexp_i)
            unset(MATCHED)
            string(REGEX MATCH ${regexp_i} MATCHED ${_variableName})

            if(NOT MATCHED)
                continue()
            else()
                set(includeFound TRUE)
            endif()
        endif()

        if(regexp_e)
            unset(MATCHED)
            string(REGEX MATCH ${regexp_e} MATCHED ${_variableName})

            if(MATCHED)
                continue()
            else()
                set(excludeFound TRUE)
            endif()
        endif()
        list(APPEND matchList ${_variableName})
    endforeach()

    # Shorten filtered list by NUM parameter
    if(p_NUM)
        list(LENGTH matchList len)
        set(start 0)
        set(stop ${len})
        if(p_NUM GREATER 0)
            set(stop ${p_NUM})
        elseif(p_NUM LESS 0)
            math(EXPR start "${len} + ${p_NUM}" OUTPUT_FORMAT DECIMAL)
        endif()
        list(SUBLIST matchList ${start} ${stop} matchList)
    endif()

    # Print variables
    foreach( var ${matchList})
        print(${var} ${printArgs})#p_UNPARSED_ARGUMENTS})
    endforeach()

    # print regex error
    if(NOT includeFound AND regexp_i)
        set(notFound  NOT_FOUND )
        str2color(COLOR green regexp_i BOLD)
        str2color(COLOR white notFound BOLD)
        message(">> Include RegExp ${regexp_i} ${notFound} ")
    endif()
    if(NOT excludeFound AND regexp_e)
        set(notFound  NOT_FOUND )
        str2color(COLOR red regexp_e BOLD)
        str2color(COLOR white notFound BOLD)
        message(">> Exclude RegExp ${regexp_e} ${notFound} ")
    endif()

    message(" -------------------- ")
endfunction()

include(${CMAKE_CURRENT_LIST_DIR}/propertyUtils.cmake)

# set(bar 1 2 3 4 )

# print(bar NUM -2  COLOR "." BREAK)
# >> bar:
# .3
# .4

# print(CMAKE_CURRENT_SOURCE_DIR)

# >> CMAKE_CURRENT_SOURCE_DIR = /home/foo/work/fobi/2023-02-02-KDAB-CMake/training-handout/cmake/lab-codegenerator

# print(bar BREAK)
# >> bar:
# ---- 1
# ---- 2
# ---- 3
# ---- 4

# print(bar GLUE ".")
# >> bar: 1.2.3.4
