#
# run post package command - minisign
#

#function(DISPLAY_PACK_VARS)
#  message(STATUS "CPACK_PACKAGE_DIRECTORY      " ${CPACK_PACKAGE_DIRECTORY})
#  message(STATUS "CPACK_PACKAGE_FILES          " ${CPACK_PACKAGE_FILES})
#  message(STATUS "CPACK_SYSTEM_NAME            " ${CPACK_SYSTEM_NAME})
#  message(STATUS "CPACK_PACKAGE_BASE_FILE_NAME " ${CPACK_PACKAGE_BASE_FILE_NAME})
#  message(STATUS "CPACK_PACKAGE_NAME           " ${CPACK_PACKAGE_NAME})
#  message(STATUS "CPACK_PACKAGE_VERSION        " ${CPACK_PACKAGE_VERSION})
#  message(STATUS "CPACK_PROJECT_CONFIG_FILE    " ${CPACK_PROJECT_CONFIG_FILE})
#endfunction()
#DISPLAY_PACK_VARS()

foreach(item IN LISTS CPACK_PACKAGE_FILES)

    get_filename_component(apack ${item} NAME)
    get_filename_component(apackwo_wle ${item} NAME_WLE)

    file(TO_NATIVE_PATH ${item} pack_fullpath)
    file(TO_NATIVE_PATH ${CPACK_PACKAGE_DIRECTORY}/../devtools/minisign.pub public_key_path)
    file(TO_NATIVE_PATH ${CPACK_PACKAGE_DIRECTORY}/${apack}.minisig minisig_file)  # create the minisig file in the build dir

    ## path to public key -p ${public_key_path}
    execute_process(COMMAND ${CPACK_PACKAGE_DIRECTORY}/../devtools/minisign -Sm "${pack_fullpath}" -t ${apackwo_wle} -x ${minisig_file})
endforeach()
