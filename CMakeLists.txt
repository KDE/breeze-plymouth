project(breeze-plymouth)
set(PROJECT_VERSION "5.24.6")
set(PROJECT_VERSION_MAJOR 5)

cmake_minimum_required(VERSION 2.8.12 FATAL_ERROR)

find_package(ECM 1.8.0 REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake ${ECM_MODULE_PATH} )

include(FeatureSummary)
include(KDEClangFormat)
include(KDEGitCommitHooks)

find_package(Plymouth REQUIRED)

find_library(MATH_LIBRARY m)

# Otherwise MODULE libs have a lib prefix, which is not compatible with
# plymouth plugin names (i.e we want breeze-text.so not libbreeze-text.so).
set(CMAKE_SHARED_MODULE_PREFIX "")

if(NOT DISTRO_NAME AND "${CMAKE_VERSION}" VERSION_GREATER_EQUAL "3.22.0")
    cmake_host_system_information(RESULT PRETTY_NAME QUERY DISTRIB_PRETTY_NAME)
endif()

if(NOT PRETTY_NAME)
    set(PRETTY_NAME "Plasma ${PROJECT_VERSION}")
endif()

set(DISTRO_NAME "${PRETTY_NAME}" CACHE STRING "Name to use on splash screen (defaults to os-release)")
set(DISTRO_VERSION "" CACHE STRING "Version to use on splash screen") # prefer to have the version in the name, makes it easier for os-release data

add_feature_info(DISTRO_NAME On "name to use on splash screen is '${DISTRO_NAME}'")
add_feature_info(DISTRO_VERSION On "extra version to use on splash screen is '${DISTRO_VERSION}'")

add_subdirectory(breeze-text)
add_subdirectory(breeze)

# add clang-format target for all our real source files
file(GLOB_RECURSE ALL_CLANG_FORMAT_SOURCE_FILES *.cpp *.h *.c)
kde_clang_format(${ALL_CLANG_FORMAT_SOURCE_FILES})
kde_configure_git_pre_commit_hook(CHECKS CLANG_FORMAT)

feature_summary(WHAT ALL INCLUDE_QUIET_PACKAGES FATAL_ON_MISSING_REQUIRED_PACKAGES)
