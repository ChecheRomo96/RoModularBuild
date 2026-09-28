if(NOT DEFINED ROMODULAR_ROOT OR NOT IS_DIRECTORY "${ROMODULAR_ROOT}")
    message(FATAL_ERROR "ROMODULAR_ROOT must name the repository root")
endif()

set(ROMODULAR_REQUIRED_FILES
    VERSION
    LICENSE
    README.md
    CMakePresets.json
    cmake/RoModularBuildVersion.cmake
    cmake/presets/native.json
    cmake/presets/arm-none-eabi.json
    cmake/presets/avr-gcc.json
    cmake/toolchains/arm-none-eabi.cmake
    cmake/toolchains/arm-none-eabi/cortex-m0plus-soft.cmake
    cmake/toolchains/arm-none-eabi/cortex-m3-soft.cmake
    cmake/toolchains/arm-none-eabi/cortex-m4f-hard.cmake
    cmake/toolchains/arm-none-eabi/cortex-m7f-hard.cmake
    cmake/toolchains/avr-gcc.cmake
    cmake/toolchains/avr-gcc/atmega328p.cmake
    scripts/common.sh
    scripts/common.ps1
    scripts/validate.sh
    scripts/validate.ps1
    docs/Architecture.md
    docs/BootstrapContract.md
    docs/ToolchainContract.md
)

foreach(ROMODULAR_REQUIRED_FILE IN LISTS ROMODULAR_REQUIRED_FILES)
    if(NOT EXISTS "${ROMODULAR_ROOT}/${ROMODULAR_REQUIRED_FILE}")
        message(FATAL_ERROR
            "Required repository file is missing: ${ROMODULAR_REQUIRED_FILE}"
        )
    endif()
endforeach()

file(STRINGS
    "${ROMODULAR_ROOT}/VERSION"
    ROMODULAR_ACTUAL_VERSION
    LIMIT_COUNT 1
)
string(STRIP "${ROMODULAR_ACTUAL_VERSION}" ROMODULAR_ACTUAL_VERSION)
if(NOT ROMODULAR_ACTUAL_VERSION STREQUAL ROMODULAR_EXPECTED_VERSION)
    message(FATAL_ERROR
        "Version mismatch: expected ${ROMODULAR_EXPECTED_VERSION}, got "
        "${ROMODULAR_ACTUAL_VERSION}"
    )
endif()

set(ROMODULAR_GENERIC_FILES
    cmake/RoModularBuildVersion.cmake
    cmake/presets/native.json
    cmake/presets/arm-none-eabi.json
    cmake/presets/avr-gcc.json
    cmake/toolchains/arm-none-eabi.cmake
    cmake/toolchains/arm-none-eabi/cortex-m0plus-soft.cmake
    cmake/toolchains/arm-none-eabi/cortex-m3-soft.cmake
    cmake/toolchains/arm-none-eabi/cortex-m4f-hard.cmake
    cmake/toolchains/arm-none-eabi/cortex-m7f-hard.cmake
    cmake/toolchains/avr-gcc.cmake
    cmake/toolchains/avr-gcc/atmega328p.cmake
    scripts/common.sh
    scripts/common.ps1
    scripts/validate.sh
    scripts/validate.ps1
)

foreach(ROMODULAR_GENERIC_FILE IN LISTS ROMODULAR_GENERIC_FILES)
    file(READ
        "${ROMODULAR_ROOT}/${ROMODULAR_GENERIC_FILE}"
        ROMODULAR_GENERIC_CONTENT
    )
    if(ROMODULAR_GENERIC_CONTENT MATCHES "FOUNDATION_|MCC_")
        message(FATAL_ERROR
            "Project-specific identifier found in ${ROMODULAR_GENERIC_FILE}"
        )
    endif()
endforeach()

message(STATUS "RoModularBuild ${ROMODULAR_ACTUAL_VERSION} contract is valid")
