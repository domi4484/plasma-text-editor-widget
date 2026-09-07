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

# Derive the package version from the latest git tag (e.g. "v1.0.1" -> "1.0.1").
# RPM versions can't contain the "v" prefix. Falls back to 0.0.0 when there's
# no git repo/tag available (e.g. a source tarball without .git).
set(CPACK_PACKAGE_VERSION_FALLBACK "0.0.0")
find_package(Git QUIET)
if(GIT_FOUND)
    execute_process(
        COMMAND ${GIT_EXECUTABLE} describe --tags --abbrev=0
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        OUTPUT_VARIABLE GIT_LATEST_TAG
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_QUIET
        RESULT_VARIABLE GIT_DESCRIBE_RESULT
    )
endif()

if(GIT_DESCRIBE_RESULT EQUAL 0 AND GIT_LATEST_TAG)
    string(REGEX REPLACE "^v" "" CPACK_PACKAGE_VERSION "${GIT_LATEST_TAG}")
else()
    set(CPACK_PACKAGE_VERSION "${CPACK_PACKAGE_VERSION_FALLBACK}")
endif()

set(CPACK_GENERATOR "RPM")
set(CPACK_PACKAGE_NAME "plasma-text-widget")
set(CPACK_RPM_PACKAGE_RELEASE "1")
set(CPACK_RPM_PACKAGE_LICENSE "GPL-3.0-or-later")
set(CPACK_PACKAGE_CONTACT "Damiano Lombardi <damiano.lombardi@customcut.ch>")
set(CPACK_RPM_PACKAGE_GROUP "System/GUI/KDE")

include(CPack)
