
option(WITH_LOGGING "writes cmake massages to logfile" OFF)

message("## WITH_LOGGING: ${WITH_LOGGING}")
if(WITH_LOGGING)
    if(NOT LOG_FILENAME)
       set(LOG_FILENAME CMakeLogger.txt)
    endif()
    message("## LOG_FILENAME: ${LOG_FILENAME}")
    # if(NOT EXISTS ${LOG_FILENAME})
    # set(logContent "")
    if(NOT messageOverride)
    function(message)
        if(ARGV)
            _message(${ARGN})
            set(logContent ${logContent}\n${ARGV} PARENT_SCOPE)
            set(messageOverride TRUE PARENT_SCOPE)
        endif()
    endfunction()
    endif()
endif()
function(flushLog)
    message(${logContent})
    file(WRITE ${LOG_FILENAME} ${logContent})
    unset(logContent PARENT_SCOPE)
endfunction()

function(convert2Html)
    get_filename_component(name ${LOG_FILENAME} NAME_WE)
    get_filename_component(dir ${LOG_FILENAME} DIRECTORY)
    set(MarkdownFile ${dir}/${name}.md)
    message("### ${MarkdownFile}")
    execute_process(
        COMMAND aha -f ${LOG_FILENAME} -n --black --title "CMakeLog" 
        OUTPUT_VARIABLE html
        )
    file(WRITE ${MarkdownFile}
        "<pre style=\"background-color:#232627;color:#eff0f1\">\n
        ${html}\n
        </pre>")
    

endfunction()