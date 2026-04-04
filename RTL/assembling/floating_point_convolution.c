#include "asm_bridge.h"
#define MAX_LENGTH 2048
#define KERNEL_SIZE 64

float signal[MAX_LENGTH] = {
    #include "signal_data.inc"
};

float kernel[KERNEL_SIZE] = {
    #include "kernel_data.inc"
};

float result[MAX_LENGTH - KERNEL_SIZE + 1];
volatile int data_length = 1;
volatile int kernel_length = 1;
volatile int output_length = 1;

int main() {
    data_length = 1024;
    kernel_length = 3;
    output_length = data_length - kernel_length + 1; 

    convolution1D(signal, kernel, result, data_length, kernel_length, output_length);

    while (1) {
    }

    return 0;
}