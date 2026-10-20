#include "asm_bridge.h"
#define MAX_LENGTH 2048
#define KERNEL_SIZE 300

float signal[MAX_LENGTH] = {
    #include "signal_data.inc"
};

float kernel[KERNEL_SIZE] = {
    #include "kernel_data.inc"
};

float result[MAX_LENGTH - KERNEL_SIZE + 1];
volatile int input_length = 300; // highest possible address (50 * 6)
volatile int kernel_length = 18; // length * depth: 3 * 6
volatile int output_length = 48; // per channel
volatile int bias = 0x41800000; // 16.0f
volatile int channels = 16;
volatile int addr = 294; // keep track of where input data should update
volatile int results = 768; // (50 - 3 + 1) * 16

int main() {
    while (1){
        if (addr == input_length){
            addr = 0;
        }

        for(int i = 0; i < 6; i++){
            float value = SPI_read_blocked_float();
            signal[addr] = value;
            addr++;
        }

        convolution1D(signal, kernel, result, kernel_length, output_length, channels, bias, JUMP6);

        for(int i = 0; i < results; i++){
            SPI_write_blocked_float(result[i]);
        }

        SPI_write_blocked_float(-1.0f);
    }
    return 0;
}