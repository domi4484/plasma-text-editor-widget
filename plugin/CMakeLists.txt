cmake_minimum_required(VERSION 3.16)

set(QT_DEFAULT_MAJOR_VERSION 6)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Qml)
find_package(KF6 REQUIRED COMPONENTS I18n)

add_library(textwidgetplugin MODULE
    plugin.cpp
    textprovider.cpp
    textprovider.h
)

target_link_libraries(textwidgetplugin
    PRIVATE
        Qt6::Core
        Qt6::Qml
        KF6::I18n
)

set_target_properties(textwidgetplugin PROPERTIES
    LIBRARY_OUTPUT_NAME textwidgetplugin
)

# Force Qt6 QML path
get_target_property(QT6_QMAKE_EXECUTABLE Qt6::qmake IMPORTED_LOCATION)
execute_process(
    COMMAND ${QT6_QMAKE_EXECUTABLE} -query QT_INSTALL_QML
    OUTPUT_VARIABLE QT6_QML_DIR
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

install(TARGETS textwidgetplugin
    LIBRARY DESTINATION ${QT6_QML_DIR}/${ORGANISATION_DOMAIN}/${ORGANISATION_NAME}/plasma/textwidget
)

install(FILES qmldir
    DESTINATION ${QT6_QML_DIR}/${ORGANISATION_DOMAIN}/${ORGANISATION_NAME}/plasma/textwidget
)
