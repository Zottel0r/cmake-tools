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
function(___)
endfunction()

#
# Usage:
# str2Color(<color> <variable> [REVERSE])
# sourrounds a string with escape sequences. Example:
#
# Example:
# set(foo "Wow my text")
# str2Color(Red foo)
# # then foo will be: "\x1b[31mWow my Text\x1b[m"
# - REVERSE: will first put the color reset, then the color
# # then foo will be: "\x1b[mWow my Text\x1b[31m")
function(str2color s2c_type var)
    if(NOT WIN32)
        string(ASCII 27 Esc)
        set(ColourReset "${Esc}[m")
        set(ColourBold "${Esc}[1m")
        set(Red "${Esc}[31m")
        set(Green "${Esc}[32m")
        set(Yellow "${Esc}[33m")
        set(Blue "${Esc}[34m")
        set(Magenta "${Esc}[35m")
        set(Cyan "${Esc}[36m")
        set(White "${Esc}[37m")
        set(BoldRed "${Esc}[1;31m")
        set(BoldGreen "${Esc}[1;32m")
        set(BoldYellow "${Esc}[1;33m")
        set(BoldBlue "${Esc}[1;34m")
        set(BoldMagenta "${Esc}[1;35m")
        set(BoldCyan "${Esc}[1;36m")
        set(BoldWhite "${Esc}[1;37m")
    endif()

    if(DEFINED ${s2c_type})
        if(ARGN STREQUAL REVERSE)
            set(${var} ${ColourReset}${${var}}${${s2c_type}} PARENT_SCOPE)
        else()
            set(${var} ${${s2c_type}}${${var}}${ColourReset} PARENT_SCOPE)
        endif()
    endif()
endfunction()

#
# Usage:
# msg(<msg_type> <variable|string>)
# outputs a colored Message according to:
# - HIGH: Magenta
# - NOTE: Cyan
# - OK: Green
# - ERR: BoldRed
# - CRIT: BoldYellow
function(msg msg_type msg_var)
    if(${msg_type} STREQUAL HIGH)
        str2color(Magenta msg_var)
        message("## ${msg_var}")
    elseif(${msg_type} STREQUAL NOTE)
        str2color(Cyan msg_var)
        message("## ${msg_var}")
    elseif(${msg_type} STREQUAL OK)
        str2color(Green msg_var)
        message("## ${msg_var}")
    elseif(${msg_type} STREQUAL ERR)
        str2color(BoldRed msg_var)
        message("## ${msg_var}")
    elseif(${msg_type} STREQUAL CRIT)
        str2color(BoldYellow msg_var)
        message("## ${msg_var}")
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
    str2color(Bold${PRINT_COLOR} var_name)
    str2color(${PRINT_COLOR} var_value)
    message(">> ${var_name} = ${var_value}")
endfunction()

#
# Usage:
# print(<variable>)
# print(<list> [NUM <num_values_shown>] [GLUE <glue_string>] [BREAK])
function(print)
    set(options BREAK)
    set(oneValueArgs NUM GLUE)
    set(multiValueArgs)
    cmake_parse_arguments(p "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    list(LENGTH ${ARGV0} len)

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

    list(SUBLIST ${liste} ${start} ${stop} value)
    str2color(${PRINT_COLOR} glue REVERSE)
    list(JOIN value "${glue}" value)
    str2color(Bold${PRINT_COLOR} name)
    str2color(${PRINT_COLOR} sep REVERSE)
    message("${name}${sep}${value}")
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
    list(POP_FRONT p_UNPARSED_ARGUMENTS regex)
    list(POP_FRONT p_UNPARSED_ARGUMENTS exclude)

    # set(regex ${regex})
    # print(arg0)
    # print(arg1)
    # print(argn)
    # print(regex)
    # print(exclude)
    # print(p_BREAK)
    # set(printArgs NUM ${p_NUM} GLUE ${p_GLUE} ${p_BREAK})
    message("--------------------")

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

        print(${_variableName} ${ARGN})
    endforeach()

    message("--------------------")
endfunction()
