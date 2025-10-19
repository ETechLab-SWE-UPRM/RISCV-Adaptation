#include <stdint.h>
#include "asm_bridge.h"

// Por ahora solamente hay suma, resta, y mac para floating point
volatile int data[1024];
volatile int weights[3] = {1, 1, 1};
volatile int output[1022];
volatile int32_t tester = 5; // 0x00000005
volatile float a = 3.5; // 0x40600000
volatile float b = 2.0; // 0x40000000
volatile float c = 4.0; // 0x40800000

int main(void) {
    for(;;){
        for(int i = 0; i < 1024; i ++){
            data[i] = i + 1;
        }
    
        volatile float result = a * b + c;

    }
}