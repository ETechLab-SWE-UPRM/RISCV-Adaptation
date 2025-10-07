#include <stdint.h>
#include "asm_bridge.h"

// Por ahora solamente hay suma, resta, y mac para floating point

int main(void) {
    for(;;){
        volatile float d = 5.65;
        volatile float a = 2.5;
        volatile float b = 3.5;

        volatile float c = d + a * b;
    }
}