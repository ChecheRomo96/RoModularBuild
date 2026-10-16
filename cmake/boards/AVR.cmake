include_guard(GLOBAL)

# avr-libc supplies startup and the MCU linker script selected by -mmcu.
function(romodular_configure_avr target)
    cmake_parse_arguments(PARSE_ARGV 1 AVR "MALLOC_NEW" "" "")
    if(AVR_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "Unknown AVR firmware options: ${AVR_UNPARSED_ARGUMENTS}")
    endif()
    if(NOT TARGET "${target}" OR NOT CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR
       NOT ROMODULAR_AVR_MCU OR NOT CMAKE_SYSTEM_PROCESSOR MATCHES "^avr")
        message(FATAL_ERROR "romodular_configure_avr requires an AVR GNU executable")
    endif()
    get_target_property(kind "${target}" TYPE)
    if(NOT kind STREQUAL "EXECUTABLE")
        message(FATAL_ERROR "AVR firmware target must be an executable")
    endif()
    find_program(ROMODULAR_AVR_OBJCOPY "${ROMODULAR_AVR_TOOLCHAIN_PREFIX}-objcopy"
        HINTS "${ROMODULAR_AVR_TOOLCHAIN_ROOT}/bin" REQUIRED)
    find_program(ROMODULAR_AVR_SIZE "${ROMODULAR_AVR_TOOLCHAIN_PREFIX}-size"
        HINTS "${ROMODULAR_AVR_TOOLCHAIN_ROOT}/bin" REQUIRED)
    set_target_properties("${target}" PROPERTIES SUFFIX ".elf")
    if(AVR_MALLOC_NEW)
        target_sources("${target}" PRIVATE "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/avr/malloc-new.cpp")
    endif()
    target_link_options("${target}" PRIVATE
        "-Wl,-Map,$<TARGET_FILE_DIR:${target}>/${target}.map")
    add_custom_command(TARGET "${target}" POST_BUILD
        COMMAND "${ROMODULAR_AVR_OBJCOPY}" -O ihex -R .eeprom
            "$<TARGET_FILE:${target}>" "$<TARGET_FILE_DIR:${target}>/${target}.hex"
        COMMAND "${ROMODULAR_AVR_SIZE}" "$<TARGET_FILE:${target}>"
        VERBATIM)
endfunction()
