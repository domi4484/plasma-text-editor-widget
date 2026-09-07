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

# --- Configurazione CPack per pacchetto RPM ---
set(CPACK_GENERATOR "RPM")
set(CPACK_PACKAGE_NAME "plasma-text-widget")
set(CPACK_PACKAGE_VERSION "1.0.0")
set(CPACK_RPM_PACKAGE_RELEASE "1")
set(CPACK_RPM_PACKAGE_LICENSE "GPL-3.0-or-later")
set(CPACK_PACKAGE_CONTACT "domi4484 <domi4484@example.com>")
set(CPACK_RPM_PACKAGE_GROUP "System/GUI/KDE")

include(CPack)