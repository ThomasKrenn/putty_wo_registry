cmake_minimum_required(VERSION 3.19)

set(CMAKE_PROJECT_VERSION_MAJOR    0)
set(CMAKE_PROJECT_VERSION_MINOR    81)
set(CMAKE_PROJECT_VERSION_PATCH    2)
set(CMAKE_PROJECT_VERSION_TWEAK    0)
set(PROJECT_VERSION_DATE           "2024-06-04")
set(PROJECT_VERSION_YEAR           "2024")

project(putty 
   HOMEPAGE_URL "github.com/ThomasKrenn/putty_wo_registry"
   VERSION ${CMAKE_PROJECT_VERSION_MAJOR}.${CMAKE_PROJECT_VERSION_MINOR}.${CMAKE_PROJECT_VERSION_PATCH}.${CMAKE_PROJECT_VERSION_TWEAK}
   LANGUAGES C
 )

set(CMAKE_C_STANDARD 99)

message("------------------------------------------" )
message("CMAKE_PREFIX_PATH: ${CMAKE_PREFIX_PATH}" )
message("CMAKE_SYSTEM_NAME: ${CMAKE_SYSTEM_NAME}" )
message("CMAKE_SYSTEM_PROCESSOR: ${CMAKE_SYSTEM_PROCESSOR}" )
message("------------------------------------------" )

set_property(GLOBAL PROPERTY USE_FOLDERS ON)
set_property(GLOBAL PROPERTY PREDEFINED_TARGETS_FOLDER "CMakeBuild")

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/x64)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/x64)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/x64)

set(PUTTY_BIN_DESTINATION "bin" CACHE INTERNAL "bin")

include(cmake/setup.cmake)

# Scan the docs directory first, so that when we start calling
# installed_program(), we'll know if we have man pages available
add_subdirectory(doc)

add_compile_definitions(HAVE_CMAKE_H)

include_directories(terminal)

add_library(utils STATIC
  ${GENERATED_COMMIT_C})
add_dependencies(utils cmake_commit_c)
add_subdirectory(utils)
add_subdirectory(stubs)

add_library(logging OBJECT
  logging.c)

add_library(eventloop STATIC
  callback.c timing.c)

add_library(console STATIC
  clicons.c console.c)

add_library(settings STATIC
  cmdline.c settings.c)

add_library(crypto STATIC
  proxy/cproxy.c proxy/sshproxy.c)
add_subdirectory(crypto)

add_library(network STATIC
  errsock.c logging.c x11disp.c
  proxy/proxy.c
  proxy/http.c
  proxy/socks4.c
  proxy/socks5.c
  proxy/telnet.c
  proxy/local.c
  proxy/interactor.c)

add_library(keygen STATIC
  import.c)
add_subdirectory(keygen)

add_library(agent STATIC
  sshpubk.c pageant.c aqsync.c)

add_library(guiterminal STATIC
  terminal/terminal.c terminal/bidi.c
  ldisc.c config.c dialog.c
  $<TARGET_OBJECTS:logging>)

add_library(noterminal STATIC
  stubs/no-term.c ldisc.c)

add_library(all-backends OBJECT
  pinger.c)

add_library(sftpclient STATIC
  psftpcommon.c)
add_subdirectory(ssh)

add_library(otherbackends STATIC
  $<TARGET_OBJECTS:all-backends>
  $<TARGET_OBJECTS:logging>)
add_subdirectory(otherbackends)

add_executable(testcrypt
  test/testcrypt.c sshpubk.c ssh/crc-attack-detector.c)
target_link_libraries(testcrypt
  keygen crypto utils ${platform_libraries})

add_executable(test_host_strfoo
  utils/host_strchr_internal.c)
target_compile_definitions(test_host_strfoo PRIVATE TEST)
target_link_libraries(test_host_strfoo utils ${platform_libraries})

add_executable(test_decode_utf8
  utils/decode_utf8.c)
target_compile_definitions(test_decode_utf8 PRIVATE TEST)
target_link_libraries(test_decode_utf8 utils ${platform_libraries})

add_executable(test_tree234
  utils/tree234.c)
target_compile_definitions(test_tree234 PRIVATE TEST)
target_link_libraries(test_tree234 utils ${platform_libraries})

add_executable(test_wildcard
  utils/wildcard.c)
target_compile_definitions(test_wildcard PRIVATE TEST)
target_link_libraries(test_wildcard utils ${platform_libraries})

add_executable(test_cert_expr
  utils/cert-expr.c)
target_compile_definitions(test_cert_expr PRIVATE TEST)
target_link_libraries(test_cert_expr utils ${platform_libraries})

add_executable(bidi_gettype
  terminal/bidi_gettype.c)
target_link_libraries(bidi_gettype guiterminal utils ${platform_libraries})

add_executable(bidi_test
  terminal/bidi_test.c)
target_link_libraries(bidi_test guiterminal utils ${platform_libraries})

add_executable(plink
  ${platform}/plink.c)
# Note: if we ever port Plink to a platform where we can't implement a
# serial backend, this be_list command will need to become platform-
# dependent, so that it only sets the SERIAL option on platforms where
# that backend exists. For the moment, though, we have serial port
# backends for both our platforms, so we can do this unconditionally.
be_list(plink Plink SSH SERIAL OTHERBACKENDS)
target_link_libraries(plink
  eventloop noterminal console sshclient otherbackends settings network crypto
  utils
  ${platform_libraries})
installed_program(plink)
#
# Install the executable (belongs in the "binaries" component)
#
install(TARGETS plink
        RUNTIME DESTINATION ${PUTTY_BIN_DESTINATION}
        COMPONENT binaries)

if(CMAKE_HOST_WIN32)
install(FILES $<TARGET_PDB_FILE:plink>
        DESTINATION ${PUTTY_BIN_DESTINATION} OPTIONAL
        COMPONENT pdb)
endif()

add_executable(pscp
  pscp.c)
be_list(pscp PSCP SSH)
target_link_libraries(pscp
  sftpclient eventloop console sshclient settings network crypto utils
  ${platform_libraries})
installed_program(pscp)
#
# Install the executable (belongs in the "binaries" component)
#
install(TARGETS pscp
        RUNTIME DESTINATION ${PUTTY_BIN_DESTINATION}
        COMPONENT binaries)

if(CMAKE_HOST_WIN32)
install(FILES $<TARGET_PDB_FILE:pscp>
        DESTINATION ${PUTTY_BIN_DESTINATION} OPTIONAL
        COMPONENT pdb)
endif()

add_executable(psftp
  psftp.c)
be_list(psftp PSFTP SSH)
target_link_libraries(psftp
  sftpclient eventloop console sshclient settings network crypto utils
  ${platform_libraries})
installed_program(psftp)
#
# Install the executable (belongs in the "binaries" component)
#
install(TARGETS psftp
        RUNTIME DESTINATION ${PUTTY_BIN_DESTINATION}
        COMPONENT binaries)

if(CMAKE_HOST_WIN32)
install(FILES $<TARGET_PDB_FILE:psftp>
        DESTINATION ${PUTTY_BIN_DESTINATION} OPTIONAL
        COMPONENT pdb)
endif()

add_executable(psocks
  ${platform}/psocks.c
  psocks.c
  stubs/no-rand.c
  proxy/nocproxy.c
  proxy/nosshproxy.c
  ssh/portfwd.c)
target_link_libraries(psocks
  eventloop console network utils
  ${platform_libraries})

foreach(subdir ${platform} ${extra_dirs})
  add_subdirectory(${subdir})
endforeach()

configure_file(cmake/cmake.h.in ${GENERATED_SOURCES_DIR}/cmake.h)


include(${CMAKE_CURRENT_SOURCE_DIR}/cpack/puttyCPack.cmake)