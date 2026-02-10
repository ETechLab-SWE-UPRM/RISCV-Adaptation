#include "asm_bridge.h"
#define MAX_LENGTH 2048
#define KERNEL_SIZE 64

float signal[MAX_LENGTH];
float kernel[KERNEL_SIZE];
float result[MAX_LENGTH - KERNEL_SIZE + 1];
volatile int data_length = 1;
volatile int kernel_length = 1;
volatile int output_length = 1;
volatile int done = 1;
volatile int data = 1;

int main() {
    while (1) {
        int add_result = 0;
        for (int i = 0; i < 1024; i++) {
            add_result = i + 1;
            signal[i] = (float) add_result;
        }

        data_length = 1024;

        for (int i = 0; i < 3; i++) {
            kernel[i] = 1.0f;
        }

        kernel_length = 3;

        output_length = data_length - kernel_length + 1;

        done = 0;

        convolution1D(signal, kernel, result, data_length, kernel_length, output_length);

        done = 1;
    }
    return 0;
}
