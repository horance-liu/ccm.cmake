cmake_minimum_required(VERSION 3.14)

project(flink-example VERSION 1.0)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

include(cc_flink)
include(cc_module)
include(CTest)

enable_testing()

add_subdirectory(lib)
add_subdirectory(main)