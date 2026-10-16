// Optional bare AVR C++ allocation glue. Do not enable with a runtime/core
// that already defines these operators. The AVR toolchain uses -fcheck-new.
#include <stddef.h>
#include <stdlib.h>
void* operator new(size_t size) { return malloc(size); }
void* operator new[](size_t size) { return malloc(size); }
void operator delete(void* pointer) noexcept { free(pointer); }
void operator delete[](void* pointer) noexcept { free(pointer); }
void operator delete(void* pointer, size_t) noexcept { free(pointer); }
void operator delete[](void* pointer, size_t) noexcept { free(pointer); }
