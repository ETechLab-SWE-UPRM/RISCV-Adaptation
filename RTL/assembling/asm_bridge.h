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
    #define timer_reg (* (volatile int *) (UART_address + 0x1Cu))
    #define SPI_status_reg (* (volatile int *) (UART_address + 0x20u))
    #define SPI_receive_reg (* (volatile int *) (UART_address + 0x24u))
    #define SPI_send_reg (* (volatile int *) (UART_address + 0x28u))

    // UART masking
    #define UART_RX_MASK 0x1
    #define UART_TX_MASK 0x2

    // SPI masking
    #define SPI_TX_FIFO_EMPTY_MASK 0x1
    #define SPI_TX_FIFO_FULL_MASK 0x2
    #define SPI_RX_FIFO_EMPTY_MASK 0x4
    #define SPI_RX_FIFO_FULL_MASK 0x8

    // CPU specs
    #define CPU_Hz 50000000u // 50 MHz
    #define UART_Baudrate 115200u
    #define SPI_rate 32000000u // 32 MHz
    #define BITS_PER_WORD_ON_WIRE 40u // 1 start, 8 data, 1 stop (4 bytes)
    #define UART_Clocks_per_word (CPU_Hz / UART_Baudrate ) * 4 // 4 bytes -> 1 word

    // Hex representation of ascii characters for UART
    #define SIGN 0x5349474E
    #define KERN 0x4B45524E
    #define DATAERROR 0x44455252
    #define WEIGHTSERROR 0x57455252
    #define START 0x53545254
    #define DONE 0x444F4E45

    int Convolution(float *data, float *weights, float *output,
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

    static inline int read_timer(void) {
        return timer_reg;
    }

    static inline int SPI_read_status(void) {
        return SPI_status_reg;
    }

    static inline int SPI_read(void) {
        return SPI_receive_reg;
    }

    static inline void SPI_send(int data) {
        SPI_send_reg = data;
    }

    static inline int UART_read_blocked(void) {
        while ((UART_read_status() & UART_RX_MASK) == 0) {
            // wait
        }
        return UART_read();
    }

    static inline int SPI_read_blocked(void) {
        while ((SPI_read_status() & SPI_RX_FIFO_EMPTY_MASK) == 1) {
            // wait until spi not empty
        }
        return SPI_read();
    }

    static inline void UART_write_blocked(int data) {
        while ((UART_read_status() & UART_TX_MASK) == 0) {
            // wait
        }
        UART_send(data);
    }

    static inline void SPI_write_blocked(int data) {
        while ((SPI_read_status() & SPI_TX_FIFO_FULL_MASK) == 1) {
            // wait until spi not full
        }
        SPI_send(data);
    }

    static inline float UART_read_float(void) {
        int temp = UART_receive;
        float data;
        memcpy(&data, &temp, sizeof(float));
        return data;
    }

    static inline float SPI_read_float(void) {
        int temp = SPI_receive_reg;
        float data;
        memcpy(&data, &temp, sizeof(float));
        return data;
    }

    static inline void UART_send_float(float data) {
        int temp;
        memcpy(&temp, &data, sizeof(float));
        UART_transmit = temp;
    }

    static inline void SPI_send_float(float data) {
        int temp;
        memcpy(&temp, &data, sizeof(float));
        SPI_send_reg = temp;
    }

    static inline void write_blocked_float(float data) {
        while ((UART_read_status() & UART_TX_MASK) == 0) {
            // wait
        }
        UART_send_float(data);
    }

    static inline float read_blocked_float(void) {
        while ((UART_read_status() & UART_RX_MASK) == 0) {
            // wait
        }
        return UART_read_float();    
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
    static inline int convolution1D(float *data, float *weights, float *output, int data_length, int weights_length, int output_length) {
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