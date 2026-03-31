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
    int err = 0;
    float data = 0;

    while (1) {
        data_length = 0; 
        err = 0;

        while (1) {
            data = read_blocked_float();
            if (data == -1.0) {
                break;
            } else if (data_length >= MAX_LENGTH) {
                err = 1;
                break;
            }

            signal[data_length] = data;
            data_length += 1;
        }

        if (err) {
            write_blocked(DATAERROR);
            continue; // restart loop
        }

        write_blocked(SIGN);
      
        for (int i = 0; i < data_length; i++){
            write_blocked_float(signal[i]);
        }
    }

    return 0;
}
