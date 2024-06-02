string(TIMESTAMP PUTTY_DATE "%Y%m%d")
message(STATUS ${PUTTY_DATE})
configure_file(${SOURCE_DIR}/cpack/CPackOptions.cmake.in
    ${BINARY_DIR}/CPackOptions.cmake
    @ONLY
)
