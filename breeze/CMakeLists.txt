configure_file(breeze.plymouth.cmake ${CMAKE_CURRENT_BINARY_DIR}/breeze.plymouth)

install(FILES breeze.grub
              breeze.script
              ${CMAKE_CURRENT_BINARY_DIR}/breeze.plymouth
        DESTINATION ${Plymouth_THEMESDIR}/breeze)
install(DIRECTORY images
        DESTINATION ${Plymouth_THEMESDIR}/breeze)
