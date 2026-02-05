#include "asm_bridge.h"
#define MAX_LENGTH 2048
#define KERNEL_SIZE 64

int signal[MAX_LENGTH];
int kernel[KERNEL_SIZE];
int result[MAX_LENGTH - KERNEL_SIZE + 1];
volatile int data_length = 1;
volatile int kernel_length = 1;
volatile int output_length = 1;
volatile int done = 1;
volatile int data = 1;

int main() {
    while (1) {
        for (int i = 0; i < 1024; i++) {
            signal[i] = i + 1;
        }

        data_length = 1024;

        for (int i = 0; i < 3; i++) {
            kernel[i] = 1;
        }

        kernel_length = 3;

        output_length = data_length - kernel_length + 1;

        done = 0;

        vector_convolution(signal, kernel, result, data_length, kernel_length, output_length);

        done = 1;
    }
    return 0;
}
