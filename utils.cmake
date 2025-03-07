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
    if(${msg_type} STREQUAL HIGH)
#        str2color(Magenta msg_var)
        str2color(COLOR magenta msg_var)
        message(" ## ${msg_var} ")
    elseif(${msg_type} STREQUAL NOTE)
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
#    if(DEFINED PRINT_COLOR)
##        set(PRINT_COLOR White)
        str2color(BOLD COLOR ${PRINT_COLOR} var_name)
        str2color(COLOR ${PRINT_COLOR} var_value)
#    endif()
    message(">> ${var_name} = ${var_value} ")
endfunction()

#
# Usage:
# print(<variable>)
# print(<list> [NUM <num_values_shown>] [GLUE <glue_string>] [BREAK])
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
# dump_variables(<regex> [NUM <num_values_shown>] [GLUE <glue_string>] [BREAK])
# dump_variables(<regex> <exclude> [NUM <num_values_shown>] [GLUE <glue_string>] [BREAK])
function(dump_variables)
    set(options BREAK)
    set(oneValueArgs NUM GLUE)
    set(multiValueArgs)
    cmake_parse_arguments(p "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    # message("--------------------")
    # set(arg0 ${ARGV0})
    # set(arg1 ${ARGV1})

    #Compatability to CMake 3.14 (Yocto)
    # list(POP_FRONT p_UNPARSED_ARGUMENTS regex)
    # list(POP_FRONT p_UNPARSED_ARGUMENTS exclude)
    list(LENGTH p_UNPARSED_ARGUMENTS length)
    if(length GREATER 0)
        list(GET p_UNPARSED_ARGUMENTS 0 regex)
    endif ()
    if(length GREATER 1)
        list(GET p_UNPARSED_ARGUMENTS 1 exclude)
    endif ()

    # set(regex ${regex})
    # print(arg0)
    # print(arg1)
    # print(argn)
    # print(regex)
    # print(exclude)
    # print(p_BREAK)
    # set(printArgs NUM ${p_NUM} GLUE ${p_GLUE} ${p_BREAK})
    message(" -------------------- ")

    get_cmake_property(_variableNames VARIABLES)
    list(SORT _variableNames)
    foreach(_variableName ${_variableNames})
        if(regex)
            unset(MATCHED)
            string(REGEX MATCH ${regex} MATCHED ${_variableName})

            if(NOT MATCHED)
                continue()
            endif()
        endif()

        if(exclude)
            unset(MATCHED)
            string(REGEX MATCH ${exclude} MATCHED ${_variableName})

            if(MATCHED)
                continue()
            endif()
        endif()
        set(matchFound TRUE)

        print(${_variableName} ${ARGN})
    endforeach()
#    list(LENGTH _variableNames _entries)
#    print(_entries)
    if(NOT matchFound)
        set(notFound  NOT_FOUND )
        str2color(COLOR WHITE regex)
        str2color(COLOR Yellow notFound)
        #    endif()
        message(">> ${regex} = ${notFound} ")
#        msg(WARN ">> ${regex} NOT_FOUND ")
    endif()

    message(" -------------------- ")
endfunction()


# set(bar 1 2 3 4 )

# print(bar NUM -2 GLUE "." BREAK)
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
