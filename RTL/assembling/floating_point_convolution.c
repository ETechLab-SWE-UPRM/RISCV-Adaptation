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
volatile int data_length = 1024;
volatile int kernel_length = 3;
volatile int output_length = 1022;

int main() {
    while (1) {
        int data = read_blocked();

        if (data != -1) {
            continue; // wait for correct start signal (-1)
        }

        int start = read_timer(); // Log time before convolution

        convolution1D(signal, kernel, result, data_length, kernel_length, output_length);

        int end = read_timer(); // Log time after convolution
        int elapsed = end - start; // Calculate elapsed time

        write_blocked(elapsed); // Send elapsed time back through UART

        for (int i = 0; i < output_length; i++) {
            write_blocked_float(result[i]);
        }
    }

    return 0;
}