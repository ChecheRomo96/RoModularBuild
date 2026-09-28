set(ROMODULAR_ARM_CPU "cortex-m0plus" CACHE STRING "Target Arm CPU" FORCE)
set(ROMODULAR_FLOAT_ABI "soft" CACHE STRING "Target floating-point ABI" FORCE)
set(ROMODULAR_FPU "" CACHE STRING "Target FPU name" FORCE)

include("${CMAKE_CURRENT_LIST_DIR}/../arm-none-eabi.cmake")
