add_library (HelloWorld
  HelloWorld.cpp)

target_include_directories(HelloWorld PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})

install (TARGETS HelloWorld DESTINATION bin)
install (FILES HelloWorld.h DESTINATION include)

print_target_properties(HelloWorld COLOR green)