find_package(FLEX)

FLEX_TARGET(ECCScanner kiwi/ecc/compiler.yy ${CMAKE_CURRENT_BINARY_DIR}/compiler.cc)

include_directories(.)
add_library(kiwi-ecc ${FLEX_ECCScanner_OUTPUTS})

add_executable(ecc kiwi/ecc/ecc.cc)
target_link_libraries(ecc kiwi-ecc fl)
