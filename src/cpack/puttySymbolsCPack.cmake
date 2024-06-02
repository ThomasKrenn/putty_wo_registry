######################################
### Package for Symbols and source ###
######################################

set(CPACK_PACKAGE_NAME "Putty")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Putty")
set(CPACK_PACKAGE_CONTACT "thomas.krenn@kabsi.at")

set(CPACK_PACKAGE_DESCRIPTION "______________TODO______________")


if(CMAKE_SYSTEM_NAME MATCHES "Windows")
  set(CPACK_GENERATOR "ZIP")
else()
  set(CPACK_GENERATOR "ZIP")
endif()  

include(CPack)