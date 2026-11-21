# Nintendo Switch packaging: romfs + NACP + NRO.
#
# romfs:/ carries everything Torch and the engine read from the install dir on
# desktop (config.yml, the asset yamls, paperboat.o2r). User data (pm64.o2r,
# saves, config, mods, logs) lives on the SD card in sdmc:/switch/PaperBoat/.

set(PAPERBOAT_SWITCH_ROMFS "${CMAKE_BINARY_DIR}/romfs")
file(MAKE_DIRECTORY "${PAPERBOAT_SWITCH_ROMFS}")

file(GLOB_RECURSE PAPERBOAT_SWITCH_ROMFS_INPUTS CONFIGURE_DEPENDS "${CMAKE_SOURCE_DIR}/assets/*")
set(PAPERBOAT_SWITCH_ROMFS_STAMP "${CMAKE_BINARY_DIR}/romfs.stamp")
add_custom_command(
    OUTPUT "${PAPERBOAT_SWITCH_ROMFS_STAMP}"
    COMMENT "Staging romfs..."
    COMMAND ${CMAKE_COMMAND} -E rm -rf "${PAPERBOAT_SWITCH_ROMFS}"
    COMMAND ${CMAKE_COMMAND} -E make_directory "${PAPERBOAT_SWITCH_ROMFS}"
    COMMAND ${CMAKE_COMMAND} -E copy_if_different "${CMAKE_SOURCE_DIR}/config.yml" "${PAPERBOAT_SWITCH_ROMFS}/config.yml"
    COMMAND ${CMAKE_COMMAND} -E copy_directory "${CMAKE_SOURCE_DIR}/assets/" "${PAPERBOAT_SWITCH_ROMFS}/assets/"
    COMMAND ${CMAKE_COMMAND} -E copy_if_different "${PAPERBOAT_PORT_O2R}" "${PAPERBOAT_SWITCH_ROMFS}/paperboat.o2r"
    COMMAND ${CMAKE_COMMAND} -E touch "${PAPERBOAT_SWITCH_ROMFS_STAMP}"
    DEPENDS "${CMAKE_SOURCE_DIR}/config.yml" ${PAPERBOAT_SWITCH_ROMFS_INPUTS} "${PAPERBOAT_PORT_O2R}"
    VERBATIM
)
add_custom_target(PaperboatSwitchRomfs DEPENDS "${PAPERBOAT_SWITCH_ROMFS_STAMP}")
add_dependencies(PaperboatSwitchRomfs GeneratePortO2R)

set(PAPERBOAT_SWITCH_VERSION "${PROJECT_VERSION}")
if(CMAKE_PROJECT_GIT_COMMIT_HASH)
    set(PAPERBOAT_SWITCH_VERSION "${PROJECT_VERSION}-${CMAKE_PROJECT_GIT_COMMIT_HASH}")
endif()

nx_generate_nacp(Paperboat.nacp
    NAME "PaperBoat"
    AUTHOR "Harbour Masters"
    VERSION "${PAPERBOAT_SWITCH_VERSION}"
)

nx_create_nro(${PROJECT_NAME}
    NACP Paperboat.nacp
    ICON "${CMAKE_SOURCE_DIR}/switch/icon.jpg"
    ROMFS "${PAPERBOAT_SWITCH_ROMFS}"
    OUTPUT "${CMAKE_BINARY_DIR}/PaperBoat.nro"
)
add_dependencies(${PROJECT_NAME}_nro PaperboatSwitchRomfs)
