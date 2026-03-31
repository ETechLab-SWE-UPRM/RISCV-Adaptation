#include "asm_bridge.h"
#define MAX_LENGTH 2048
#define KERNEL_SIZE 64

volatile int done = 0;
volatile float signal[MAX_LENGTH];


int main() {    
    for(int i = 0; i < 10; i++) {
        signal[i] = 1.5f;
    } 
    
    while (1) {
        for(int i = 0; i < 10; i++) {
            write_blocked_float(signal[i]);
        }
    }

    return 0;
}
