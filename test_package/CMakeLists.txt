project(test_package)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH}
                      ${CMAKE_CURRENT_SOURCE_DIR}/modules)

include(${CMAKE_BINARY_DIR}/conanbuildinfo.cmake)
conan_basic_setup()
conan_define_targets()

find_package(BNFC REQUIRED)

set(BNFC_OUTPUT_DIR ${CMAKE_BINARY_DIR}/bnfc-gen)
bnfc_target(FrancaGrammarParserGen ${CMAKE_SOURCE_DIR}/example.cf
            ${BNFC_OUTPUT_DIR})

add_executable(example ${BNFC_OUTPUT_DIR}/Test.C ${BNFC_FrancaGrammarParserGen_OUTPUT_SOURCES})
target_include_directories(example PUBLIC  $<BUILD_INTERFACE:${BNFC_OUTPUT_DIR}>)