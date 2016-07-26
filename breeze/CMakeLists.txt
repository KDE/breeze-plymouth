set(DISTRO_LOGO "plasma" CACHE STRING "Image filename to use on splash screen")
set(BACKGROUND_TOP_COLOR "black" CACHE STRING "Color for top of splash screen")
set(BACKGROUND_BOTTOM_COLOR "black" CACHE STRING "Color for bottom of splash screen")

add_feature_info(DISTRO_LOGO On "image filename to use on splash screen is '${DISTRO_LOGO}'")
add_feature_info(BACKGROUND_TOP_COLOR On "Color for top of splash screen is '${BACKGROUND_TOP_COLOR}'")
add_feature_info(BACKGROUND_BOTTOM_COLOR On "Color for bottom of splash screen is '${BACKGROUND_BOTTOM_COLOR}'")

configure_file(breeze.plymouth.cmake ${CMAKE_CURRENT_BINARY_DIR}/breeze.plymouth)
configure_file(breeze.script.cmake ${CMAKE_CURRENT_BINARY_DIR}/breeze.script)

install(FILES breeze.grub
              ${CMAKE_CURRENT_BINARY_DIR}/breeze.script
              ${CMAKE_CURRENT_BINARY_DIR}/breeze.plymouth
        DESTINATION ${Plymouth_THEMESDIR}/breeze)
install(DIRECTORY images
        DESTINATION ${Plymouth_THEMESDIR}/breeze)
