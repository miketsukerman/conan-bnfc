if(NOT BNFC_FOUND)

  find_package(BISON REQUIRED)
  find_package(FLEX REQUIRED)

  find_program(
    BNFC_EXECUTABLE
    NAMES bnfc
    DOC "Path to the bnfc executable"
    HINTS ~/.cabal/bin /usr/bin /usr/local/bin)
  mark_as_advanced(BNFC_EXECUTABLE BNFC_FOUND)

  if(BNFC_EXECUTABLE)
    # the bison commands should be executed with the C locale, otherwise the
    # message (which are parsed) may be translated
    set(_BNFC_SAVED_LC_ALL "$ENV{LC_ALL}")
    set(ENV{LC_ALL} C)
    execute_process(
      COMMAND ${BNFC_EXECUTABLE} --version
      OUTPUT_VARIABLE BNFC_version_output
      ERROR_VARIABLE BNFC_version_error
      RESULT_VARIABLE BNFC_version_result
      OUTPUT_STRIP_TRAILING_WHITESPACE)

    set(ENV{LC_ALL} ${_BNFC_SAVED_LC_ALL})

    if(NOT ${BNFC_version_result} EQUAL 0)
      message(
        SEND_ERROR
          "Command \"${BNFC_EXECUTABLE} --version\" failed with output:\n${BNFC_version_error}"
      )
    else()
      if("${BNFC_version_output}" MATCHES "([^,]+)")
        set(BNFC_VERSION "${CMAKE_MATCH_1}")
        mark_as_advanced(BNFC_VERSION)
      endif()

    endif()

    function(prv_parse_file_path URI FILE_PATH FILE_NAME FILE_NAME_WE)
      get_filename_component(PRV_FILE_PATH "${URI}" ABSOLUTE)
      get_filename_component(PRV_FILE_NAME "${PRV_FILE_PATH}" NAME)
      get_filename_component(PRV_FILE_NAME_WE "${PRV_FILE_PATH}" NAME_WE)

      if(NOT EXISTS ${PRV_FILE_PATH})
        message(FATAL_ERROR "There is no such file \"${PRV_FILE_PATH}\"")
      endif()

      set(${FILE_PATH}
          ${PRV_FILE_PATH}
          PARENT_SCOPE)
      set(${FILE_NAME}
          ${PRV_FILE_NAME}
          PARENT_SCOPE)
      set(${FILE_NAME_WE}
          ${PRV_FILE_NAME_WE}
          PARENT_SCOPE)
    endfunction()

    macro(BNFC_TARGET Name BNFCInput BNFCOutputFolder)
      set(BNFC_TARGET_outputs "${BNFCOutputFolder}")
      set(BNFC_TARGET_extraoutputs "")

      # Parsing parameters
      set(BNFC_TARGET_PARAM_OPTIONS)
      set(BNFC_TARGET_PARAM_ONE_VALUE_KEYWORDS COMPILE_FLAGS)
      set(BNFC_TARGET_PARAM_MULTI_VALUE_KEYWORDS)
      cmake_parse_arguments(
        BNFC_TARGET_ARG "${BNFC_TARGET_PARAM_OPTIONS}"
        "${BNFC_TARGET_PARAM_ONE_VALUE_KEYWORDS}"
        "${BNFC_TARGET_PARAM_MULTI_VALUE_KEYWORDS}" ${ARGN})

      prv_parse_file_path(${BNFCInput} FILE_PATH FILE_NAME FILE_NAME_WE)

      set(BNFC_${Name}_OUTPUT_SOURCES ${BNFCOutputFolder}/Absyn.C
                                      ${BNFCOutputFolder}/Printer.C)
      set(BNFC_${Name}_OUTPUT_HEADER
          ${BNFCOutputFolder}/Absyn.H ${BNFCOutputFolder}/Parser.H
          ${BNFCOutputFolder}/Printer.H)

      set(BNFC_${Name}_BISON_OUTPUT ${BNFCOutputFolder}/${FILE_NAME_WE}.y)
      set(BNFC_${Name}_FLEX_OUTPUT ${BNFCOutputFolder}/${FILE_NAME_WE}.l)
      set(BNFC_${Name}_LATEX_OUTPUT ${BNFCOutputFolder}/${FILE_NAME_WE}.tex)

      list(
        APPEND
        BNFC_TARGET_outputs
        ${BNFC_${Name}_OUTPUT_HEADER}
        ${BNFC_${Name}_OUTPUT_SOURCES}
        ${BNFC_${Name}_BISON_OUTPUT}
        ${BNFC_${Name}_FLEX_OUTPUT}
        ${BNFCOutputFolder}/Test.C)

      add_custom_command(
        OUTPUT ${BNFC_TARGET_outputs}
        COMMAND ${BNFC_EXECUTABLE} ${BNFC_TARGET_cmdopt} --cpp ${BNFCInput} -l
                -p bnfc -o ${BNFCOutputFolder}
        DEPENDS ${BNFCInput}
        COMMENT "[BNFC][${Name}] Generating parser and lexer for bison and flex"
                VERBOSE ${BNFCOutputFolder}/BNFC-codegen.out
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})

      add_custom_command(
        OUTPUT ${BNFC_${Name}_LATEX_OUTPUT}
        COMMAND ${BNFC_EXECUTABLE} ${BNFC_TARGET_cmdopt} --latex ${BNFCInput} -o
                ${BNFCOutputFolder}
        DEPENDS ${BNFCInput}
        COMMENT "[BNFC][${Name}] Generating grammar documentation" VERBOSE
                ${BNFCOutputFolder}/BNFC_docs.out
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})

      bison_target(
        Scanner_${Name}
        ${BNFC_${Name}_BISON_OUTPUT}
        ${BNFCOutputFolder}/Bison_Parser.cpp
        DEFINES_FILE
        ${BNFCOutputFolder}/Bison_Parser.h
        REPORT_FILE
        ${BNFCOutputFolder}/Bison.report
        VERBOSE
        ${BNFCOutputFolder}/Bison.out)

      flex_target(
        Lexer_${Name} ${BNFC_${Name}_FLEX_OUTPUT}
        ${BNFCOutputFolder}/Flex_Lexer.cpp DEFINES_FILE
        ${BNFCOutputFolder}/Flex_Lexer.h)
      add_flex_bison_dependency(Lexer_${Name} Scanner_${Name})

      set(BNFC_${Name}_OUTPUT_SOURCES
          ${BNFC_${Name}_OUTPUT_SOURCES} ${BISON_Scanner_${Name}_OUTPUTS}
          ${FLEX_Lexer_${Name}_OUTPUTS} ${BNFC_${Name}_LATEX_OUTPUT})

    endmacro()
  endif()

  # handle the QUIETLY and REQUIRED arguments and set BNFC_FOUND to TRUE if all
  # listed variables are TRUE
  include(FindPackageHandleStandardArgs)

  find_package_handle_standard_args(BNFC DEFAULT_MSG BNFC_EXECUTABLE
                                    BNFC_VERSION)

endif(NOT BNFC_FOUND)
