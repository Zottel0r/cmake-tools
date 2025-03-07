cmake_minimum_required (VERSION 3.20)
project (CMakeTest)

set (${PROJECT_NAME}_VERSION_MAJOR 1)
set (${PROJECT_NAME}_VERSION_MINOR 0)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/..)
message("CMAKE_MODULE_PATH: ${CMAKE_MODULE_PATH}")
include(utils)

add_subdirectory (Hello)

add_executable (${PROJECT_NAME} Hello main.cpp)

target_link_libraries (${PROJECT_NAME} PUBLIC HelloWorld)

install (TARGETS ${PROJECT_NAME} DESTINATION bin)