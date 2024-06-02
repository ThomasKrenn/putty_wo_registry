#########################
### Package generator ###
#########################

set(CPACK_PACKAGE_NAME "Putty")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Putty SSH client")
set(CPACK_PACKAGE_CONTACT "thomas.krenn@kabsi.at")

set(CPACK_PACKAGE_DESCRIPTION "______________TODO______________")


set(CPACK_PACKAGE_BASE_FILE_NAME "putty")

if(CMAKE_SYSTEM_NAME MATCHES "Windows")

set(CPACK_COMPONENT_INCLUDE_TOPLEVEL_DIRECTORY ON)

else()
 ## add RPM and DEB for Linux
set(CPACK_COMPONENT_INCLUDE_TOPLEVEL_DIRECTORY ON)

endif()  

message("------------------------------------------" )
message("CPACK_PACKAGE_VERSION_MAJOR: ${CPACK_PACKAGE_VERSION_MAJOR}" )
message("CPACK_PACKAGE_VERSION_MINOR: ${CPACK_PACKAGE_VERSION_MINOR}" )
message("CPACK_PACKAGE_VERSION_PATCH: ${CPACK_PACKAGE_VERSION_PATCH}" )
message("------------------------------------------" )

## 
## https://stackoverflow.com/questions/9613051/rename-the-output-of-cpack
## setting the CPACK_* variables happens at "configure" time.
## You can't override CPACK_PACKAGE_FILE_NAME at build time because CPack reads 
## it from a config file. You have to set CPACK_PROJECT_CONFIG_FILE to a file that
## is generated at build time. This is what the code in my answer does.
##

# function that adds a custom target
# the target creates a CPackOption File to set 
# custom CPACK_PACKAGE_FILE_NAME
function(cpackoptionsfirst)
  
  if(${CMAKE_CL_64})
    set(PUTTY_X64 "-x64")
  else()
    set(PUTTY_X64 "")
  endif()

  add_custom_target(cpackoptions ALL

      # generate cpackoptions.cmake at BUILD time so we get the
      # aktual date (or revision)
      COMMAND ${CMAKE_COMMAND}
      -DSOURCE_DIR=${CMAKE_SOURCE_DIR}
      -DBINARY_DIR=${CMAKE_BINARY_DIR}
      -DPUTTY_X64=${PUTTY_X64}
      -P ${CMAKE_SOURCE_DIR}/cpack/create-cpackoptions.cmake
  )

endfunction()


# run a customtarget to set a custom CPACK_PACKAGE_FILE_NAME
cpackoptionsfirst()
# use the new file to set the CPACK_PACKAGE_FILE_NAME
set(CPACK_PROJECT_CONFIG_FILE ${CMAKE_BINARY_DIR}/CPackOptions.cmake)


#
# Install etc
#
install(DIRECTORY ${CMAKE_SOURCE_DIR}/../documentation/
        DESTINATION documentation
        COMPONENT binaries
        ) 
      
#
# two component groups
#
set(CPACK_COMPONENT_BINARIES_GROUP "rel")
set(CPACK_COMPONENT_PDB_GROUP "pdb")

#
# package each component group to a zip
#
set(CPACK_ARCHIVE_COMPONENT_INSTALL ON)
   
#
# Tell CPack about the components and group the data components together 
# (CPACK_COMPONENT_${COMPONENT_NAME_ALL_CAPS}_GROUP).
#
set(CPACK_COMPONENTS_ALL binaries pdb)


if(CMAKE_SYSTEM_NAME MATCHES "Windows")

set(CPACK_TOPLEVEL_TAG "${CPACK_PACKAGE_BASE_FILE_NAME}_@PUTTY_VERSION_DATE@_${CPACK_SYSTEM_NAME}@PUTTY_X64@")
 
  set(CPACK_GENERATOR "ZIP")
else()
  set(CPACK_GENERATOR "TGZ")
endif()  

include(CPack)
