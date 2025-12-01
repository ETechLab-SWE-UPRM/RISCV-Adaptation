#include <stdio.h>
#include <time.h>

int main() {
        volatile float signal[1024];
        volatile float kernel[3] = {1.0, 1.0, 1.0};
        volatile int result_length = 1024 - 3 + 1;
        volatile float result[result_length];
        
        for(int i = 0; i < 1024; i++){
            signal[i] = (float)(i + 1);
        }
        
        for(int i = 0; i < result_length; i++){
            float sum = 0.0f;
            for(int j = 0; j < 3; j++){
                sum += signal[i + j] * kernel[j];
            }
            result[i] = sum;
        }
    
    return 0;
}
