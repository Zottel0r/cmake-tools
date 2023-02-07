
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

function(printVar)
    list(LENGTH ${ARGV0} len)
    message(">> ${ARGV0} = ${${ARGV0}}")
endfunction()

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

function(printList liste)
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
    list(JOIN value "${glue}" value )
    message(">> ${name}${sep}${value}")
endfunction()




function(dump_variables )
    set(options BREAK)
    set(oneValueArgs NUM GLUE)
    set(multiValueArgs)
    cmake_parse_arguments(p "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
#    message("--------------------")
#    set(arg0 ${ARGV0})
#    set(arg1 ${ARGV1})
    list(POP_FRONT  p_UNPARSED_ARGUMENTS regex)
    list(POP_FRONT p_UNPARSED_ARGUMENTS exclude)
#    set(regex ${regex})
#    print(arg0)
#    print(arg1)
#    print(argn)
#    print(regex)
#    print(exclude)
#    print(p_BREAK)
#    set(printArgs NUM ${p_NUM} GLUE ${p_GLUE} ${p_BREAK})
    message("--------------------")

    get_cmake_property(_variableNames VARIABLES)
    list (SORT _variableNames)
    foreach (_variableName ${_variableNames})
        if (regex)
            unset(MATCHED)
            string(REGEX MATCH ${regex} MATCHED ${_variableName})
            if (NOT MATCHED)
                continue()
            endif()
        endif()

        if (exclude)
            unset(MATCHED)
            string(REGEX MATCH ${exclude} MATCHED ${_variableName})
            if (MATCHED)
                continue()
            endif()
        endif()
        print(${_variableName} ${ARGN})
    endforeach()
    message("--------------------")
endfunction()

#set(foo "bar" "ree")
#set(bar "fooree")
#print(foo)
#print(bar)

#dump_variables("conan")

#return()