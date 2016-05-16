configure_file(breeze.plymouth.cmake ${CMAKE_CURRENT_BINARY_DIR}/breeze.plymouth)
configure_file(breeze.script.cmake ${CMAKE_CURRENT_BINARY_DIR}/breeze.script)

install(FILES breeze.grub
              ${CMAKE_CURRENT_BINARY_DIR}/breeze.script
              ${CMAKE_CURRENT_BINARY_DIR}/breeze.plymouth
        DESTINATION ${Plymouth_THEMESDIR}/breeze)
install(DIRECTORY images
        DESTINATION ${Plymouth_THEMESDIR}/breeze)
