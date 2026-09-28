cmake_minimum_required(VERSION 3.25)

file(STRINGS
    "${CMAKE_CURRENT_LIST_DIR}/VERSION"
    ROMODULAR_VERSION
    LIMIT_COUNT 1
)
string(STRIP "${ROMODULAR_VERSION}" ROMODULAR_VERSION)

if(NOT ROMODULAR_VERSION MATCHES "^[0-9]+\\.[0-9]+\\.[0-9]+$")
    message(FATAL_ERROR
        "VERSION must contain one semantic version, got '${ROMODULAR_VERSION}'"
    )
endif()

project(RoModularBuild VERSION ${ROMODULAR_VERSION} LANGUAGES NONE)

option(ROMODULAR_BUILD_SELF_TESTS
    "Enable RoModularBuild repository contract tests"
    ON
)

message(STATUS "Validating ${PROJECT_NAME} ${PROJECT_VERSION}")

include(CTest)

if(BUILD_TESTING AND ROMODULAR_BUILD_SELF_TESTS)
    add_test(
        NAME romodular.repository_contract
        COMMAND
            ${CMAKE_COMMAND}
            -DROMODULAR_ROOT=${CMAKE_CURRENT_LIST_DIR}
            -DROMODULAR_EXPECTED_VERSION=${PROJECT_VERSION}
            -P ${CMAKE_CURRENT_LIST_DIR}/tests/ValidateLayout.cmake
    )
endif()
