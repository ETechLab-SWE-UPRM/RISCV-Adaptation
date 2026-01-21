#include <stdio.h>
#include <time.h>

volatile int done = 1;
volatile int signal[1024];
volatile int kernel[3] = {1, 1, 1};
volatile int result[1022];

int main() {
    for(int i = 0; i < 1024; i++){
        signal[i] = (i + 1);
    }

    done = 0;

    for(int i = 0; i < 1022; i++){
        int sum = 0;
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
