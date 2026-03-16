cmake_minimum_required(VERSION 3.16)

find_package(Qt6 REQUIRED COMPONENTS Core)
find_package(KF6 REQUIRED COMPONENTS I18n)

add_library(textwidgetplugin MODULE
    plugin.cpp
    textprovider.cpp
    textprovider.h
)

target_link_libraries(textwidgetplugin
    PRIVATE
        Qt6::Core
        KF6::I18n
)

set_target_properties(textwidgetplugin PROPERTIES
    LIBRARY_OUTPUT_NAME textwidgetplugin
)

install(TARGETS textwidgetplugin
    LIBRARY DESTINATION ${KDE_INSTALL_QMLDIR}/org/example/plasma/textwidget
)

install(FILES qmldir
    DESTINATION ${KDE_INSTALL_QMLDIR}/org/example/plasma/textwidget
)