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
volatile float data = 1.0f;
volatile int err = 1;

int main() {
    while (1) {
        write_blocked(0x12345678);
    } 
    return 0;
}
