
include_directories(../src ../ext/googletest/include)
link_directories(/usr/local/opt/flex/lib)

add_executable(kiwi-ecc-test kiwi/ecc/compiler.cc)

target_link_libraries(kiwi-ecc-test kiwi-ecc gtest gtest_main fl)

add_test(kiwi-ecc-test kiwi-ecc-test)

