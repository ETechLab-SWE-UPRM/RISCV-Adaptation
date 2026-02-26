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

int main() {
    // int err = 0;
    float data = 0;

    while (1) {
        data = read_blocked_float();
        write_blocked_float(data);
    }
    return 0;
}
