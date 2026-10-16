#include <stdlib.h>
// Synthetic consumer: verifies that this support layer needs no product library.
volatile unsigned fixtureData = 42;
volatile unsigned fixtureBss;
volatile unsigned fixtureConstructor;
volatile unsigned fixtureResult;
struct Initialize { Initialize() { fixtureConstructor = 13; } } initialize;
int main() {
    void* allocation = malloc(64);
    const bool valid = fixtureData == 42 && fixtureBss == 0 &&
        fixtureConstructor == 13 && allocation != nullptr;
    free(allocation);
    fixtureResult = valid ? 1 : 2;
    return valid ? 0 : 1;
}
