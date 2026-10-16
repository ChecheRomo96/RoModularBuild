    .syntax unified
    .cpu cortex-m0plus
    .thumb
    .section .isr_vector,"a",%progbits
    .global RoModularVectorTable
RoModularVectorTable:
    .word _estack
    .word Reset_Handler
    .rept 14
    .word Default_Handler
    .endr
    .rept 32
    .word Default_Handler
    .endr
    .section .text.Reset_Handler,"ax",%progbits
    .global Reset_Handler
    .thumb_func
Reset_Handler:
    cpsid i
    bl romodular_reset_handler
1:  b 1b
    .section .text.Default_Handler,"ax",%progbits
    .thumb_func
Default_Handler:
    bl romodular_fault_handler
2:  b 2b
    .section .note.GNU-stack,"",%progbits
