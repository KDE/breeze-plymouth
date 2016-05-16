project(breeze-plymouth)
set(PROJECT_VERSION "5.6.90")
set(PROJECT_VERSION_MAJOR 5)

cmake_minimum_required(VERSION 2.8.12 FATAL_ERROR)

find_package(ECM 1.8.0 REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake ${ECM_MODULE_PATH} ${ECM_KDE_MODULE_DIR})

include(FeatureSummary)

find_package(Plymouth REQUIRED)

find_library(MATH_LIBRARY m)

# Otherwise MODULE libs have a lib prefix, which is not compatible with
# plymouth plugin names (i.e we want breeze-text.so not libbreeze-text.so).
set(CMAKE_SHARED_MODULE_PREFIX "")

set(DISTRO_NAME "Plasma" CACHE STRING "Name to use on splash screen")
set(DISTRO_VERSION ${PROJECT_VERSION} CACHE STRING "Version to use on splash screen")
set(DISTRO_LOGO "plasma" CACHE STRING "Image filename to use on splash screen")
set(BACKGROUND_TOP_COLOR "plasma_blue" CACHE STRING "Color for top of splash screen")
set(BACKGROUND_BOTTOM_COLOR "icon_blue" CACHE STRING "Color for bottom of splash screen")

add_feature_info(DISTRO_NAME On "name to use on splash screen is '${DISTRO_NAME}'")
add_feature_info(DISTRO_VERSION On "version to use on splash screen is '${DISTRO_VERSION}'")
add_feature_info(DISTRO_LOGO On "image filename to use on splash screen is '${DISTRO_LOGO}'")
add_feature_info(BACKGROUND_TOP_COLOR On "Color for top of splash screen is '${BACKGROUND_TOP_COLOR}'")
add_feature_info(BACKGROUND_BOTTOM_COLOR On "Color for bottom of splash screen is '${BACKGROUND_BOTTOM_COLOR}'")

add_subdirectory(breeze-text)
add_subdirectory(breeze)

feature_summary(WHAT ALL INCLUDE_QUIET_PACKAGES FATAL_ON_MISSING_REQUIRED_PACKAGES)
