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

    function(romodular_add_toolchain_test
        TEST_NAME
        PROFILE
        PROCESSOR
        C_FLAGS
        CXX_FLAGS
        LINKER_FLAGS
    )
        add_test(
            NAME "romodular.toolchain.${TEST_NAME}"
            COMMAND
                ${CMAKE_COMMAND}
                "-DROMODULAR_ROOT=${CMAKE_CURRENT_LIST_DIR}"
                "-DROMODULAR_PROFILE=${PROFILE}"
                "-DROMODULAR_EXPECTED_PROCESSOR=${PROCESSOR}"
                "-DROMODULAR_EXPECTED_C_FLAGS=${C_FLAGS}"
                "-DROMODULAR_EXPECTED_CXX_FLAGS=${CXX_FLAGS}"
                "-DROMODULAR_EXPECTED_LINKER_FLAGS=${LINKER_FLAGS}"
                -P ${CMAKE_CURRENT_LIST_DIR}/tests/ValidateToolchain.cmake
        )
    endfunction()

    romodular_add_toolchain_test(
        arm_cortex_m0plus_soft
        cmake/toolchains/arm-none-eabi/cortex-m0plus-soft.cmake
        cortex-m0plus
        "-mcpu=cortex-m0plus -mthumb -mfloat-abi=soft -ffunction-sections -fdata-sections"
        "-mcpu=cortex-m0plus -mthumb -mfloat-abi=soft -ffunction-sections -fdata-sections -fno-exceptions -fno-rtti -fcheck-new"
        "-mcpu=cortex-m0plus -mthumb -mfloat-abi=soft -Wl,--gc-sections"
    )
    romodular_add_toolchain_test(
        arm_cortex_m3_soft
        cmake/toolchains/arm-none-eabi/cortex-m3-soft.cmake
        cortex-m3
        "-mcpu=cortex-m3 -mthumb -mfloat-abi=soft -ffunction-sections -fdata-sections"
        "-mcpu=cortex-m3 -mthumb -mfloat-abi=soft -ffunction-sections -fdata-sections -fno-exceptions -fno-rtti -fcheck-new"
        "-mcpu=cortex-m3 -mthumb -mfloat-abi=soft -Wl,--gc-sections"
    )
    romodular_add_toolchain_test(
        arm_cortex_m4f_hard
        cmake/toolchains/arm-none-eabi/cortex-m4f-hard.cmake
        cortex-m4
        "-mcpu=cortex-m4 -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16 -ffunction-sections -fdata-sections"
        "-mcpu=cortex-m4 -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16 -ffunction-sections -fdata-sections -fno-exceptions -fno-rtti -fcheck-new"
        "-mcpu=cortex-m4 -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16 -Wl,--gc-sections"
    )
    romodular_add_toolchain_test(
        arm_cortex_m7f_hard
        cmake/toolchains/arm-none-eabi/cortex-m7f-hard.cmake
        cortex-m7
        "-mcpu=cortex-m7 -mthumb -mfloat-abi=hard -mfpu=fpv5-d16 -ffunction-sections -fdata-sections"
        "-mcpu=cortex-m7 -mthumb -mfloat-abi=hard -mfpu=fpv5-d16 -ffunction-sections -fdata-sections -fno-exceptions -fno-rtti -fcheck-new"
        "-mcpu=cortex-m7 -mthumb -mfloat-abi=hard -mfpu=fpv5-d16 -Wl,--gc-sections"
    )
    romodular_add_toolchain_test(
        avr_atmega328p_avr5
        cmake/toolchains/avr-gcc/atmega328p.cmake
        avr5
        "-mmcu=atmega328p -ffunction-sections -fdata-sections"
        "-mmcu=atmega328p -ffunction-sections -fdata-sections -fno-exceptions -fno-rtti -fcheck-new"
        "-mmcu=atmega328p -Wl,--gc-sections"
    )
endif()
