project(breeze-plymouth)
set(PROJECT_VERSION "5.18.2")
set(PROJECT_VERSION_MAJOR 5)

cmake_minimum_required(VERSION 2.8.12 FATAL_ERROR)

find_package(ECM 1.8.0 REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake ${ECM_MODULE_PATH} ${ECM_KDE_MODULE_DIR})

include(FeatureSummary)
include(KDEClangFormat)

find_package(Plymouth REQUIRED)

find_library(MATH_LIBRARY m)

# Otherwise MODULE libs have a lib prefix, which is not compatible with
# plymouth plugin names (i.e we want breeze-text.so not libbreeze-text.so).
set(CMAKE_SHARED_MODULE_PREFIX "")

set(DISTRO_NAME "Plasma" CACHE STRING "Name to use on splash screen")
set(DISTRO_VERSION ${PROJECT_VERSION} CACHE STRING "Version to use on splash screen")

add_feature_info(DISTRO_NAME On "name to use on splash screen is '${DISTRO_NAME}'")
add_feature_info(DISTRO_VERSION On "version to use on splash screen is '${DISTRO_VERSION}'")

add_subdirectory(breeze-text)
add_subdirectory(breeze)

# add clang-format target for all our real source files
file(GLOB_RECURSE ALL_CLANG_FORMAT_SOURCE_FILES *.cpp *.h)
kde_clang_format(${ALL_CLANG_FORMAT_SOURCE_FILES})

feature_summary(WHAT ALL INCLUDE_QUIET_PACKAGES FATAL_ON_MISSING_REQUIRED_PACKAGES)
