#include <stdint.h>
#include <stddef.h>
#include <errno.h>
#include <sys/stat.h>

extern "C" {
extern unsigned char __heap_start;
extern unsigned char __heap_end;
void* __dso_handle = nullptr;
void romodular_fault_handler() __attribute__((noreturn));
int main();
extern uint32_t _sidata, _sdata, _edata, _sbss, _ebss;
typedef void (*Initializer)();
extern Initializer __init_array_start[], __init_array_end[];

// A consumer can override this hook to record application-specific fault data.
__attribute__((weak, noreturn)) void romodular_fault_handler() {
    for (;;) __asm volatile("nop");
}

__attribute__((noreturn)) void romodular_reset_handler() {
    uint32_t* source = &_sidata;
    for (uint32_t* p = &_sdata; p < &_edata; ++p) *p = *source++;
    for (uint32_t* p = &_sbss; p < &_ebss; ++p) *p = 0;
    for (Initializer* p = __init_array_start; p < __init_array_end; ++p) (*p)();
    (void)main();
    // Keep SWD accessible after the programming session detaches: no WFI.
    for (;;) __asm volatile("nop");
}

// No UART or semihosting: tests report through SRAM, so file I/O is unsupported.
int _write(int, const void*, size_t) { errno = ENOSYS; return -1; }
int _read(int, void*, size_t) { errno = ENOSYS; return -1; }
int _close(int) { errno = EBADF; return -1; }
int _lseek(int, int, int) { errno = ESPIPE; return -1; }
int _fstat(int, struct stat*) { errno = EBADF; return -1; }
int _isatty(int) { return 0; }
int _getpid() { return 1; }
int _kill(int, int) { errno = ENOSYS; return -1; }
void _exit(int) { romodular_fault_handler(); }

// Bounded newlib heap; firmware runs with interrupts disabled.
void* _sbrk(ptrdiff_t increment) {
    static uintptr_t cursor = reinterpret_cast<uintptr_t>(&__heap_start);
    const uintptr_t end = reinterpret_cast<uintptr_t>(&__heap_end);
    if (increment < 0 || static_cast<uintptr_t>(increment) > end - cursor) {
        errno = ENOMEM;
        return reinterpret_cast<void*>(static_cast<uintptr_t>(-1));
    }
    const uintptr_t previous = cursor;
    cursor += static_cast<uintptr_t>(increment);
    return reinterpret_cast<void*>(previous);
}
}
