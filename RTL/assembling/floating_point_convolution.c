#include "asm_bridge.h"
#define MAX_LENGTH 2048
#define KERNEL_SIZE 64

int signal[MAX_LENGTH] = {
    #include "signal_data.inc"
};

int kernel[KERNEL_SIZE] = {
    #include "kernel_data.inc"
};

int result[MAX_LENGTH - KERNEL_SIZE + 1];
volatile int data_length = 1024;
volatile int kernel_length = 11;
volatile int output_length;

int main() {
    while (1) {
        int data = SPI_read_blocked();

        if (data != -1) {
            continue; // wait for correct start signal (-1)
        }

        int value = SPI_read_blocked();

        value += 1;

        SPI_write_blocked(value);

    }

    return 0;
}