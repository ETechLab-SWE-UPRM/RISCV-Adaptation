#include <stdint.h>
#include "asm_bridge.h"

int main(void) {
    for(;;){
        volatile int32_t x = 5;
        volatile float d = 5.65;
        volatile float a = 2.5;
        volatile float b = 3.5;

        volatile float c = a + b;
    }
}