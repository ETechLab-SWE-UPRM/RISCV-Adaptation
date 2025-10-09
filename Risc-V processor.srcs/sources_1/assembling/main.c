#include <stdint.h>
#include "asm_bridge.h"

// Por ahora solamente hay suma, resta, y mac para floating point

int main(void) {
    for(;;){
        volatile float a = 2.5;
        volatile float b = 5.65;
        volatile float c = 3.5;

        volatile float d = c + a * b;
        volatile float e = d + c * a;
        volatile float f = e + d * c;
    }
}