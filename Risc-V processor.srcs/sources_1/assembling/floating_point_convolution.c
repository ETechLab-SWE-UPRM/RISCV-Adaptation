#include "asm_bridge.h"

int signal[1024];
int kernel[3] = {1, 1, 1};
int result[1022];
volatile int done = 1;

int main() {
    for (int i = 0; i < 1024; i++) {
        signal[i] = i + 1;
    }

    done = 0;
    
    vector_convolution(signal, kernel, result, 1024, 3, 1022);

    done = 1; 

    while(1){
    }

    return 0;
}
