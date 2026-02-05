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
    #define CPU_Hz 100000000u // 100 MHz
    #define UART_Baudrate 115200u
    #define BITS_PER_WORD_ON_WIRE 40u // 1 start, 8 data, 1 stop (4 bytes)
    #define UART_Clocks_per_bit 34723 // CPU_Hz / UART_Baudrate

    int Convolution(int *data, int *weights, int *output,
                      int data_length, int weights_length, int output_length);

    int vector_convolution_main(int *data, int *weights, int *output,
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

    static inline int read_blocked(void) {
        while (UART_read_status() == 0) {
            // wait
        }
        return UART_read();
    }

    static inline void busy(int cycles) {
        volatile int count = cycles;
        while (count > 0) {
            count--;
        }
    }

    static inline void write_blocked(int data) {
        UART_send(data);
        busy(UART_Clocks_per_bit);
    }

    static inline float UART_read_float(void) {
        int temp = UART_receive;
        float data;
        memcpy(&data, &temp, sizeof(float));
        return data;
    }

    static inline void UART_send_float(float data) {
        int temp;
        memcpy(&temp, &data, sizeof(float));
        UART_transmit = temp;
    }

    /*
        Floating Point convolution function with inline assembly implementation.

        @param data pointer to the input data array
        @param weights pointer to the weights array
        @param output pointer to the output array
        @param data_length length of the input data array
        @param weights_length length of the weights array
        @param output_length length of the output array
    */
    static inline int convolution1D(int *data, int *weights, int *output, int data_length, int weights_length, int output_length) {
        return Convolution(data, weights, output, data_length, weights_length, output_length);
    }

    /*
        Vector Integer convolution function with inline assembly implementation.

        @param data pointer to the input data array
        @param weights pointer to the weights array
        @param output pointer to the output array
        @param data_length length of the input data array
        @param weights_length length of the weights array
        @param output_length length of the output array
    */
    static inline int vector_convolution(int* data, int *weights, int *output, int data_length, int weights_length, int output_length) {
        return vector_convolution_main(data, weights, output, data_length, weights_length, output_length);
    }
#endif