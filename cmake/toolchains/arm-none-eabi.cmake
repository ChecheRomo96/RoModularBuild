# Project-independent GNU Arm Embedded toolchain.
# Profile files set ROMODULAR_ARM_CPU, ROMODULAR_FLOAT_ABI, and optionally
# ROMODULAR_FPU before including this file.

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

set(ROMODULAR_ARM_TOOLCHAIN_ROOT "" CACHE PATH
    "Optional GNU Arm Embedded installation root")
set(ROMODULAR_ARM_TOOLCHAIN_PREFIX "arm-none-eabi" CACHE STRING
    "GNU Arm Embedded compiler prefix")
set(ROMODULAR_ARM_CPU "cortex-m3" CACHE STRING "Target Arm CPU")
set(ROMODULAR_FLOAT_ABI "soft" CACHE STRING "Target floating-point ABI")
set(ROMODULAR_FPU "" CACHE STRING "Target FPU name")
set(ROMODULAR_ARM_ADDITIONAL_FLAGS "" CACHE STRING
    "Additional flags shared by C and C++")
set(ROMODULAR_ARM_SYSROOT "" CACHE PATH
    "Optional target sysroot containing the C runtime headers and libraries")

set(CMAKE_SYSTEM_PROCESSOR "${ROMODULAR_ARM_CPU}")

if(NOT ROMODULAR_ARM_SYSROOT STREQUAL "")
    set(CMAKE_SYSROOT "${ROMODULAR_ARM_SYSROOT}")
endif()

set(_romodular_arm_program_hints)
if(NOT ROMODULAR_ARM_TOOLCHAIN_ROOT STREQUAL "")
    list(APPEND _romodular_arm_program_hints
        "${ROMODULAR_ARM_TOOLCHAIN_ROOT}/bin"
    )
endif()

find_program(CMAKE_C_COMPILER
    NAMES "${ROMODULAR_ARM_TOOLCHAIN_PREFIX}-gcc"
    HINTS ${_romodular_arm_program_hints}
    REQUIRED
)
find_program(CMAKE_CXX_COMPILER
    NAMES "${ROMODULAR_ARM_TOOLCHAIN_PREFIX}-g++"
    HINTS ${_romodular_arm_program_hints}
    REQUIRED
)
find_program(CMAKE_AR
    NAMES "${ROMODULAR_ARM_TOOLCHAIN_PREFIX}-ar"
    HINTS ${_romodular_arm_program_hints}
    REQUIRED
)
find_program(CMAKE_RANLIB
    NAMES "${ROMODULAR_ARM_TOOLCHAIN_PREFIX}-ranlib"
    HINTS ${_romodular_arm_program_hints}
    REQUIRED
)

if(ROMODULAR_FLOAT_ABI STREQUAL "hard" AND ROMODULAR_FPU STREQUAL "")
    message(FATAL_ERROR "ROMODULAR_FPU is required when ROMODULAR_FLOAT_ABI=hard")
endif()

set(_romodular_arm_flags
    "-mcpu=${ROMODULAR_ARM_CPU} -mthumb -mfloat-abi=${ROMODULAR_FLOAT_ABI}"
)
if(NOT ROMODULAR_FPU STREQUAL "")
    string(APPEND _romodular_arm_flags " -mfpu=${ROMODULAR_FPU}")
endif()
if(NOT ROMODULAR_ARM_ADDITIONAL_FLAGS STREQUAL "")
    string(APPEND _romodular_arm_flags
        " ${ROMODULAR_ARM_ADDITIONAL_FLAGS}"
    )
endif()

set(_romodular_arm_common_flags
    "${_romodular_arm_flags} -ffunction-sections -fdata-sections"
)

set(CMAKE_C_FLAGS_INIT "${_romodular_arm_common_flags}")
set(CMAKE_CXX_FLAGS_INIT
    "${_romodular_arm_common_flags} -fno-exceptions -fno-rtti -fcheck-new"
)
set(CMAKE_EXE_LINKER_FLAGS_INIT
    "${_romodular_arm_flags} -Wl,--gc-sections"
)

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
