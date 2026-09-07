cmake_minimum_required(VERSION 3.16)
project(plasma-text-widget)

find_package(ECM REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})

set(ORGANISATION_NAME customcut)
set(ORGANISATION_DOMAIN ch)

include(KDEInstallDirs)

add_subdirectory(plugin)

install(DIRECTORY contents
    DESTINATION ${KDE_INSTALL_DATADIR}/plasma/plasmoids/${ORGANISATION_DOMAIN}.${ORGANISATION_NAME}.plasma.textwidget
)

install(FILES metadata.json
    DESTINATION ${KDE_INSTALL_DATADIR}/plasma/plasmoids/${ORGANISATION_DOMAIN}.${ORGANISATION_NAME}.plasma.textwidget
)

# --- Configurazione CPack per pacchetto RPM ---
set(CPACK_GENERATOR "RPM")
set(CPACK_PACKAGE_NAME "plasma-text-widget")
set(CPACK_PACKAGE_VERSION "1.0.0")
set(CPACK_RPM_PACKAGE_RELEASE "1")
set(CPACK_RPM_PACKAGE_LICENSE "GPL-3.0-or-later")
set(CPACK_PACKAGE_CONTACT "Damiano Lombardi <damiano.lombardi@customcut.ch>")
set(CPACK_RPM_PACKAGE_GROUP "System/GUI/KDE")

include(CPack)
