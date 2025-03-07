add_library (HelloWorld
  HelloWorld.cpp)

target_include_directories(HelloWorld PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})

install (TARGETS HelloWorld DESTINATION bin)
install (FILES HelloWorld.h DESTINATION include)

# ====================================================

msg(INFO "This is a INFO")
msg(HIGH "This is a HIGH")
msg(NOTE "This is a NOTE")
msg(STATUS "This is a STATUS")
msg(WARN "This is a WARN")
msg(ERR "This is a ERR")
msg(CRIT "This is a CRIT")
msg(OK "This is a OK")

set(myString "This is a string")
set(myBool TRUE)
set(myEmpty)
print(myString)
print(myBool)
print(myEmpty)
print(myNotExistentVar)
print(CMAKE_CXX_COMPILER_ID COLOR yellow)

set(myList 1 2 3 4 )
print(myList)
print(myList NUM 2 BREAK)
print(myList GLUE "|")
print(myList NUM -2 GLUE " * " BREAK COLOR cyan)

find_package(Python)
dump_variables(VERSION "(^_|CM(AKE|ake))")
dump_variables("C[0-9].*FEATURES" NUM 50 COLOR red GLUE "   |-- "  BREAK)

dump_variables("CMAKE_CXX_FLAGS" COLOR magenta )
dump_variables("CMAKE_CXX_FLAGS" ".*DEB.*" COLOR green )

dump_variables(".*foo[a-y]+" "\\nbar(res)")

str2color(COLOR orange CMAKE_BUILD_TYPE BOLD)