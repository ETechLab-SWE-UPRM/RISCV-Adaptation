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
volatile int kernel_length = 18; // length * depth: 3 * 6
volatile int output_length = 20;
volatile int bias = 0x41800000; // 16.0f
volatile int channels = 2;

int main() {
    convolution1D(signal, kernel, result, kernel_length, output_length, channels, bias);

    for(int i = 0; i < output_length; i++){
        SPI_write_blocked_float(result[i]);
    }

    return 0;
}