#include <stdint.h>
#include "asm_bridge.h"

int main(void) {
    for(;;){
        while(UART_read_status() == 0){
        // Wait for UART status to be ready
        }

        uint32_t received_data = UART_read();
        received_data = received_data + 1;
        UART_send(received_data);

    }
}