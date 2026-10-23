#include "asm_bridge.h"
#define MAX_LENGTH 800
#define KERNEL_SIZE 300
#define KERNEL2_SIZE 1536
#define KERNEL3_SIZE 2048

float signal[MAX_LENGTH] = {
    #include "signal_data.inc"
};

float kernel[KERNEL_SIZE] = {
    #include "kernel_data.inc"
};

float kernel2[KERNEL2_SIZE] = {
    #include "kernel_data2.inc"
};

float kernel3[KERNEL3_SIZE] = {
    #include "kernel_data3.inc"
};

float result[(50-3+1) * 16]; // 768
float result2[(48-3+1) * 32]; // 1472 second result
float result3[46*64];
volatile int input_length = 300; // highest possible address (50 * 6)
volatile int kernel_length = 18; // length * depth
volatile int output_length = 48; // per channel
volatile int bias = 0x41800000; // 16.0f
volatile int channels = 16;
volatile int addr = 294; // keep track of where input data should update
volatile int results = 1472; // (48 - 3 + 1) * 32

int main() {
        convolution1D(signal, kernel, result, kernel_length, output_length, channels, bias, JUMP6);

        kernel_length = 48; // 3 * 16
        output_length = 46; // (48-3+1)
        channels = 32;
        bias = 0x42000000; // 32

        convolution1D(result, kernel2, result2, kernel_length, output_length, channels, bias, JUMP16);

        kernel_length = 32; // 1 * 32
        output_length = 46; // (46-1+1)
        channels = 64;
        bias = 0x42800000; // 64

        convolution1D(result2, kernel2, result3, kernel_length, output_length, channels, bias, JUMP32);

    return 0;
}