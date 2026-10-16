include_guard(GLOBAL)

# Applies board mechanics to an existing consumer executable. Product source,
# feature switches, tests, report formats and CI policy belong to the consumer.
function(romodular_configure_stm32g0b1cbt6 target)
    if(NOT TARGET "${target}")
        message(FATAL_ERROR "romodular_configure_stm32g0b1cbt6 requires an executable target")
    endif()
    if(NOT CMAKE_SYSTEM_PROCESSOR STREQUAL "cortex-m0plus" OR
       NOT CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
        message(FATAL_ERROR "STM32G0B1CBT6 board support requires GNU Arm Cortex-M0+")
    endif()
    get_target_property(_type "${target}" TYPE)
    if(NOT _type STREQUAL "EXECUTABLE")
        message(FATAL_ERROR "STM32 board support must be applied to an executable")
    endif()
    set(ROMODULAR_STM32_HEAP_BYTES "16384" CACHE STRING "Reserved newlib heap bytes")
    set(ROMODULAR_STM32_STACK_BYTES "8192" CACHE STRING "Minimum reserved stack bytes")
    foreach(_setting ROMODULAR_STM32_HEAP_BYTES ROMODULAR_STM32_STACK_BYTES)
        if(NOT "${${_setting}}" MATCHES "^[1-9][0-9]*$")
            message(FATAL_ERROR "${_setting} must be a positive byte count")
        endif()
        math(EXPR _remainder "${${_setting}} % 8")
        if(NOT _remainder EQUAL 0)
            message(FATAL_ERROR "${_setting} must be a multiple of 8 bytes")
        endif()
    endforeach()
    set(_assets "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/stm32g0b1cbt6")
    set(_linker "${CMAKE_CURRENT_BINARY_DIR}/${target}-stm32g0b1cbt6.ld")
    configure_file("${_assets}/memory.ld.in" "${_linker}" @ONLY)
    target_sources("${target}" PRIVATE "${_assets}/startup.S" "${_assets}/runtime.cpp")
    # CRT startup may call main; compile it as freestanding even when the
    # application's std::allocator/STL code needs hosted library headers.
    set_property(SOURCE "${_assets}/runtime.cpp" APPEND PROPERTY COMPILE_OPTIONS -ffreestanding)
    target_compile_definitions("${target}" PRIVATE STM32G0B1xx)
    set_target_properties("${target}" PROPERTIES SUFFIX ".elf")
    set_property(TARGET "${target}" APPEND PROPERTY LINK_DEPENDS "${_linker}")
    target_link_options("${target}" PRIVATE
        -nostartfiles --specs=nano.specs "-T${_linker}"
        "-Wl,-Map,$<TARGET_FILE_DIR:${target}>/${target}.map"
        -Wl,--print-memory-usage -Wl,--gc-sections
        -Wl,--no-warn-rwx-segments -Wl,-z,noexecstack)
    get_filename_component(_bin "${CMAKE_CXX_COMPILER}" DIRECTORY)
    find_program(ROMODULAR_ARM_OBJCOPY arm-none-eabi-objcopy HINTS "${_bin}" REQUIRED)
    find_program(ROMODULAR_ARM_SIZE arm-none-eabi-size HINTS "${_bin}" REQUIRED)
    add_custom_command(TARGET "${target}" POST_BUILD
        COMMAND "${ROMODULAR_ARM_OBJCOPY}" -O ihex "$<TARGET_FILE:${target}>"
            "$<TARGET_FILE_DIR:${target}>/${target}.hex"
        COMMAND "${ROMODULAR_ARM_OBJCOPY}" -O binary "$<TARGET_FILE:${target}>"
            "$<TARGET_FILE_DIR:${target}>/${target}.bin"
        COMMAND "${ROMODULAR_ARM_SIZE}" "$<TARGET_FILE:${target}>" VERBATIM)
endfunction()
