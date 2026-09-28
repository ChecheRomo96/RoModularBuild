set(ROMODULAR_ARM_CPU "cortex-m4" CACHE STRING "Target Arm CPU" FORCE)
set(ROMODULAR_FLOAT_ABI "hard" CACHE STRING "Target floating-point ABI" FORCE)
set(ROMODULAR_FPU "fpv4-sp-d16" CACHE STRING "Target FPU name" FORCE)

include("${CMAKE_CURRENT_LIST_DIR}/../arm-none-eabi.cmake")
