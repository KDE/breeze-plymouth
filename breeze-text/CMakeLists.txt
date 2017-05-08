add_library(breeze-text MODULE plugin.c ply-text-progress-bar.c)
target_link_libraries(breeze-text ${Plymouth_LIBRARIES} ${MATH_LIBRARY})
target_include_directories(breeze-text PRIVATE ${Plymouth_INCLUDE_DIRS})
install(TARGETS breeze-text DESTINATION ${Plymouth_PLUGINSDIR})

configure_file(breeze-text.plymouth.cmake ${CMAKE_CURRENT_BINARY_DIR}/breeze-text.plymouth)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/breeze-text.plymouth preview.png
    DESTINATION ${Plymouth_THEMESDIR}/breeze-text)
