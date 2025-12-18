#ifndef X_CAWT_BRIDGE
#define X_CAWT_BRIDGE
#include <stdint.h>
#include <string.h>

    // MM addresses
    #define UART_address 0x100082A0u
    #define UART_status (* (volatile int *) (UART_address + 0x04u))
    #define UART_receive (* (volatile int *) (UART_address + 0x08u))
    #define UART_transmit (* (volatile int *) (UART_address + 0x0Cu))
    #define Conv_data_reg (* (volatile int *) (UART_address + 0x10u))
    #define Conv_weights_reg (* (volatile int *) (UART_address + 0x14u))
    #define Conv_output_reg (* (volatile int *) (UART_address + 0x18u))

    int Convolution(int *data, int *weights, int *output,
                      int data_length, int weights_length, int output_length);

    static inline int UART_read_status(void) {
        return UART_status;
    }

    static inline int UART_read(void) {
        return UART_receive;
    }

    static inline void UART_send(int data) {
        UART_transmit = data;
    }

    static inline float UART_read_float(void) {
        volatile int temp = UART_receive;
        volatile float data;
        memcpy(&data, &temp, sizeof data);
        return data;
    }

    static inline void UART_send_float(float data) {
        volatile int temp;
        memcpy(&temp, &data, sizeof data);
        UART_transmit = temp;
    }

    static inline void setup_data_conv(int *data) {
        Conv_data_reg = (int) data;
    }

    static inline void setup_weights_conv(int *weights) {
        Conv_weights_reg = (int) weights;
    }

    static inline void setup_output_conv(int *output) {
        Conv_output_reg = (int) output;
    }

    /*
        Convolution function with inline assembly implementation.

        @param data: pointer to the input data array
        @param weights: pointer to the weights array
        @param output: pointer to the output array
        @param data_length: length of the input data array
        @param weights_length: length of the weights array
        @param output_length: length of the output array
    */
    static inline int convolution1D(int *data, int *weights, int *output, int data_length, int weights_length, int output_length) {
        return Convolution(data, weights, output, data_length, weights_length, output_length);
    }

#endif