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
        kernel_length = 0;
        output_length = 0;
        err = 0;

        while (1) {
            data = read_blocked_float();
            if (data == -1.0) {
                break;
            } else if (data_length >= MAX_LENGTH) {
                err = 1;
                // Keep receiving data as to not start another cycle in between data dumps
                continue;
            }
            signal[data_length] = data;
            data_length++;
        }

        if (err) {
            write_blocked(DATAERROR);
            write_blocked(DONE);
            continue; // restart loop
        }

        while (1) {
            data = read_blocked_float();
            if (data == -1.0) {
                break;
            } else if (data_length >= KERNEL_SIZE) {
                err = 1;
                // Keep receiving data as to not start another cycle in between data dumps
                continue;
            }
            kernel[kernel_length] = data;
            kernel_length++;
        }

        if (err) {
            write_blocked(WEIGHTSERROR);
            write_blocked(DONE);
            continue; // restart loop
        }

        output_length = data_length - kernel_length + 1;

        convolution1D(signal, kernel, result, data_length, kernel_length, output_length);

        for (int i = 0; i < output_length; i++) {
            write_blocked_float(result[i]);
        }

        write_blocked(DONE); // DONE
    }
    return 0;
}
