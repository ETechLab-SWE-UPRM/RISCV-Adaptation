#include "asm_bridge.h"

volatile float signal[1024];
volatile float kernel[3] = {1.0, 1.0, 1.0};
volatile float result[1022];
volatile int done = 1;

int main() {

    for(int i = 0; i < 1024; i++){
        signal[i] = (float)(i + 1);
    }
    
    done = 0;

    convolution1D((int *)signal, (int *)kernel, (int *)result, 1024, 3, 1022);
    
    done = 1; 

    while(1){
    }

    return 0;
}
