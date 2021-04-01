project(Program)

set(CMAKE_CXX_FLAGS_RELEASE="-Wall -pedantic")
set(CMAKE_CXX_STANDARD 17)

file(GLOB SRC *.cpp *.h)
set(SOURCES ${SRC})

add_executable(main ${SOURCES})

add_custom_target(run ./main)

add_custom_target(check valgrind ./main)

add_custom_target(cleanall rm -rf CMakeCache.txt  CMakeFiles  cmake_install.cmake  Makefile main)
