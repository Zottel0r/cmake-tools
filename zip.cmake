# package(simulator
#    FILES
#    $<TARGET_FILE:vcSimulation>
#    ${CMAKE_CURRENT_LIST_DIR}/readme.md
#    DIR_CONTENT_ONLY
# )
function(package name)
    set(options DIR_CONTENT_ONLY)
    set(oneValueArgs TARGET TMP_DIR OUT_ARCHIVE_VAR)
    set(multiValueArgs FILES COMMANDS)
    cmake_parse_arguments(package "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
    dump_variables("^package_" GLUE ", ")

    string(GENEX_STRIP "${package_FILES}" stripped)
    if(NOT (stripped STREQUAL package_FILES))
        message(FATAL_ERROR "no GENEXP in Files allowed!")
    endif()

    # if(package_TARGET)
    #     get_directory_property(targetList DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} BUILDSYSTEM_TARGETS)
    #     if(NOT package_TARGET IN_LIST targetList)
    #         message(FATAL_ERROR "POST_BUILD on target ${package_TARGET} not possible - current source dir does not contain the target!!")
    #     endif()
    # endif()

    if(NOT package_TMP_DIR)
        string(RANDOM LENGTH 5 tmpdir)
        set(package_TMP_DIR ${CMAKE_CURRENT_BINARY_DIR}/tmp_${name})
    endif()
    # print(package_TMP_DIR)
    if(WIN32)
        set(outputArchive ${name}.zip)
        set(tarOptions cf)
    else()
        set(outputArchive ${name}.tar.gz)
        set(tarOptions czf)
    endif()

    
    foreach(file ${package_FILES})
        print(file)

        file(GLOB files ${CMAKE_CURRENT_LIST_DIR}/${file} ${file})
        print(files BREAK)
        list(APPEND filesToCopy ${files})
        foreach(file ${files})
            # file(TO_CMAKE_PATH ${file} _path)
            # string(REPLACE ";" ":" _path "${_path}")
            # print(_path)
            get_filename_component(fileName ${file} NAME)
            list(APPEND copiedFiles ${package_TMP_DIR}/${fileName})
            
        endforeach()
    endforeach()
    # file(GENERATE OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/generated.log" CONTENT "$<IF:$<BOOL:${package_TARGET}>,TARGET ${package_TARGET} POST_BUILD,OUTPUT ${outputArchive}>")
    # if(TARGET ${package_TARGET})
    #     message("BAAAAMM!!")
    #     set(commandType TARGET ${package_TARGET} POST_BUILD)
    #     list(APPEND package_FILES $<TARGET_FILE:${package_TARGET}>)
    #     list(APPEND copiedFiles ${package_TMP_DIR}/$<TARGET_FILE_NAME:${package_TARGET}>)
    # else()
        set(commandType OUTPUT ${outputArchive})
    # endif()
    print(filesToCopy BREAK)
    print(copiedFiles BREAK)
    list(TRANSFORM copiedFiles PREPEND "COMMAND ${CMAKE_COMMAND} -E echo - " OUTPUT_VARIABLE listDone)
    string(REPLACE " " ";" listDone "${listDone}")
    print(listDone BREAK)
    add_custom_command(
        ${commandType}
        ${package_COMMANDS}

        COMMAND ${CMAKE_COMMAND} -E echo "------------------------"
        COMMAND ${CMAKE_COMMAND} -E echo "packing.."
        COMMAND ${CMAKE_COMMAND} -E rm -rf ${package_TMP_DIR}
        # COMMAND ${CMAKE_COMMAND} -E echo "making dir..${package_TMP_DIR}"
        COMMAND ${CMAKE_COMMAND} -E make_directory ${package_TMP_DIR}
        # COMMAND ${CMAKE_COMMAND} -E echo \"copying..${filesToCopy} to ${package_TMP_DIR}\"
        COMMAND ${CMAKE_COMMAND} -E copy_if_different ${filesToCopy} ${package_TMP_DIR}
        # COMMAND ${CMAKE_COMMAND} -E echo \"packing.. ${outputArchive} with ${copiedFiles}\"
        COMMAND ${CMAKE_COMMAND} -E tar ${tarOptions} ${outputArchive} $<$<PLATFORM_ID:Windows>:--format=zip> ${copiedFiles}
        # COMMAND ${CMAKE_COMMAND} -E echo "packaged:"
        ${listDone}
        COMMAND ${CMAKE_COMMAND} -E echo "to:"
        COMMAND ${CMAKE_COMMAND} -E echo "- ${outputArchive}"
        COMMAND ${CMAKE_COMMAND} -E echo "------------------------"
        # BYPRODUCTS ${copiedFiles}
        DEPENDS ${filesToCopy}
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        COMMENT "Build ${name} package"
    )
    if(package_OUT_ARCHIVE_VAR)
        set(${package_OUT_ARCHIVE_VAR} ${outputArchive} PARENT_SCOPE)
    endif()
endfunction()