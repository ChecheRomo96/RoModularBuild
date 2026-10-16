#include <avr/io.h>
#include <avr/interrupt.h>
#include <avr/sleep.h>
int main() {
    UBRR0 = F_CPU / 16 / 9600 - 1;
    UCSR0B = (1 << TXEN0);
    UCSR0C = (1 << UCSZ01) | (1 << UCSZ00);
    const char message[] = "AVR board fixture\n";
    for (const char* p = message; *p; ++p) {
        while (!(UCSR0A & (1 << UDRE0))) {}
        UDR0 = *p;
    }
    while (!(UCSR0A & (1 << TXC0))) {}
    cli();
    set_sleep_mode(SLEEP_MODE_PWR_DOWN);
    sleep_enable();
    for (;;) { sleep_cpu(); }
}
