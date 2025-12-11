#include <stdio.h>
#include <time.h>

volatile int done = 1;
volatile float signal[1024];
volatile float kernel[3] = {1.0, 1.0, 1.0};
volatile float result[1022];

int main() {
    for(int i = 0; i < 1024; i++){
        signal[i] = (float)(i + 1);
    }

    done = 0;

    for(int i = 0; i < 1022; i++){
        float sum = 0.0f;
        for(int j = 0; j < 3; j++){
            sum += signal[i + j] * kernel[j];
        }
        result[i] = sum;
    }
    
    done = 1;   
    while(1){
    }

    return 0;
}
