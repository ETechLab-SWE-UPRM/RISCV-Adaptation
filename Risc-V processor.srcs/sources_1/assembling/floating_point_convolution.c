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

int read_blocked() {
    while(UART_read_status() == 0) {
    }
    return UART_read();
}

int main() {
    while (1) {
        data = read_blocked();
        UART_send(data);
    }

    return 0;
}
