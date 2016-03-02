project(breeze-plymouth)
set(PROJECT_VERSION "5.6.90")
set(PROJECT_VERSION_MAJOR 5)

cmake_minimum_required(VERSION 2.8.12 FATAL_ERROR)

find_package(ECM 1.8.0 REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake ${ECM_MODULE_PATH} ${ECM_KDE_MODULE_DIR})

include(FeatureSummary)

find_package(Plymouth REQUIRED)

# Otherwise MODULE libs have a lib prefix, which is not compatible with
# plymouth plugin names (i.e we want breeze-text.so not libbreeze-text.so).
set(CMAKE_SHARED_MODULE_PREFIX "")

add_subdirectory(breeze-text)
install(DIRECTORY breeze DESTINATION ${Plymouth_THEMESDIR})

feature_summary(WHAT ALL INCLUDE_QUIET_PACKAGES FATAL_ON_MISSING_REQUIRED_PACKAGES)
