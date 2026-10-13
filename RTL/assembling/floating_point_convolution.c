#include "asm_bridge.h"
#define MAX_LENGTH 2048
#define KERNEL_SIZE 64

float signal[MAX_LENGTH];
float kernel[KERNEL_SIZE] = {
    #include "kernel_data.inc"
};

float result[MAX_LENGTH - KERNEL_SIZE + 1];
volatile int data_length = 1024;
volatile int kernel_length = 11;
volatile int output_length;

int main() {
    output_length = data_length - kernel_length + 1;

    while (1) {
        for (int i = 0; i < data_length; i++) {
            float value = SPI_read_blocked_float();
            if (value == -1.0f) {
                // Handle error or end of data
                break;
            }
            signal[i] = value;
        }

        convolution1D(signal, kernel, result, data_length, kernel_length, output_length);

        for (int i = 0; i < output_length; i++) {
            SPI_write_blocked_float(result[i]);
        }

        SPI_write_blocked_float(-1.0f);
    }

    return 0;
}