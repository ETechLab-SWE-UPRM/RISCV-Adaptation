#include "xparameters.h"
#include "xuartlite.h"

#define UARTLITE_ADDRESS XPAR_XUARTLITE_0_BASEADDR

XUartLite UartLite;

int main() {
    u8 recvBuffer[4];
    int received = 0;

    // Initialize UART Lite
    XUartLite_Initialize(&UartLite, UARTLITE_ADDRESS);

    while (1) {
        // Receive until we have 4 bytes
        while (received < 4) {
            int count = XUartLite_Recv(&UartLite, &recvBuffer[received], 4 - received);
            received += count;
        }

        // Send the 4 bytes back
        XUartLite_Send(&UartLite, recvBuffer, 4);

        // Wait until transmit FIFO is empty
        while (XUartLite_IsSending(&UartLite));

        // Reset counter for next packet
        received = 0;
    }

    return 0;
}
