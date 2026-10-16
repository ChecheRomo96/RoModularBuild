#ifndef ROMODULAR_AVR_FIXTURE_PORTABLE_H
#define ROMODULAR_AVR_FIXTURE_PORTABLE_H
namespace portable {
template <typename T> constexpr T identity(T value) { return value; }
}
#endif
