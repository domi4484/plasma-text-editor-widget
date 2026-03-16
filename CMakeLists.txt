cmake_minimum_required(VERSION 3.16)
project(plasma-text-widget)

find_package(ECM REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})

include(KDEInstallDirs)

add_subdirectory(plugin)

install(DIRECTORY contents
    DESTINATION ${KDE_INSTALL_DATADIR}/plasma/plasmoids/org.example.plasma.textwidget
)

install(FILES metadata.json
    DESTINATION ${KDE_INSTALL_DATADIR}/plasma/plasmoids/org.example.plasma.textwidget
)