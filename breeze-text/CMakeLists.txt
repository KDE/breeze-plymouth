cmake_minimum_required(VERSION 3.0)

include(FindPkgConfig)
pkg_check_modules(PLYMOUTH REQUIRED ply-boot-client ply-splash-core)
exec_program(${PKG_CONFIG_EXECUTABLE}
    ARGS ply-splash-core --variable=pluginsdir
    OUTPUT_VARIABLE PLYMOUTH_PLUGINSDIR)

set(CMAKE_SHARED_MODULE_PREFIX "")

add_library(breeze-text MODULE plugin.c ply-text-progress-bar.c)
target_link_libraries(breeze-text ${PLYMOUTH_LIBRARIES})
target_include_directories(breeze-text PRIVATE ${PLYMOUTH_INCLUDE_DIRS})
install(TARGETS breeze-text DESTINATION ${PLYMOUTH_PLUGINSDIR})
