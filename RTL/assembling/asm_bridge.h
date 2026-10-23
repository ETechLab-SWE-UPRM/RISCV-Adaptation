#ifndef X_CAWT_BRIDGE
#define X_CAWT_BRIDGE
#include <stdint.h>
#include <string.h>

    #define BRAMSIZE (12000*4)

    // MM addresses
    #define UART_address 0x10000000u + BRAMSIZE
    #define UART_status (* (volatile int *) (UART_address + 0x04u))
    #define UART_receive (* (volatile int *) (UART_status + 0x04u))
    #define UART_transmit (* (volatile int *) (UART_receive + 0x04u))
    #define Conv_offset_reg (* (volatile int *) (UART_transmit + 0x04u))
    #define Conv_weights_reg (* (volatile int *) (Conv_offset_reg + 0x04u))
    #define Conv_output_reg (* (volatile int *) (Conv_weights_reg + 0x04u))
    #define timer_reg (* (volatile int *) (Conv_output_reg + 0x04u))
    #define SPI_status_reg (* (volatile int *) (timer_reg + 0x04u))
    #define SPI_receive_reg (* (volatile int *) (SPI_status_reg + 0x04u))
    #define SPI_send_reg (* (volatile int *) (SPI_receive_reg + 0x04u))
    #define Conv_weights_channels_reg (* (volatile int *) (SPI_send_reg + 0x04u))

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

    // Offsets for next address calculation at end of channel
    #define JUMP6 0x18
    #define JUMP16 0x40
    #define JUMP32 0x80
    #define NOJUMP 0x4

    int vector_convolution_main(int *data, int *weights, int *output,
                      int data_length, int weights_length, int output_length);

    int flat_convolution(float *data, float *weights, float *output,
                        int weights_length, int output_length,
                        int output_channels, int bias, int stride);

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
        while ((SPI_read_status() & SPI_RX_FIFO_EMPTY_MASK) != 0) {
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
        while ((SPI_read_status() & SPI_TX_FIFO_FULL_MASK) != 0) {
            // wait until spi not full
        }
        SPI_send(data);
    }

    static inline float UART_read_float(void) {
        int temp = UART_receive;
        float data;
        __asm__ ("fmv.w.x %0, %1": "=f" (data): "r"  (temp));
        return data;
    }

    static inline float SPI_read_float(void) {
        int temp = SPI_receive_reg;
        float data;
        __asm__ ("fmv.w.x %0, %1": "=f" (data): "r"  (temp));
        return data;
    }

    static inline void UART_send_float(float data) {
        int temp;
        __asm__ ("fmv.x.w %0, %1": "=r" (temp): "f"  (data));
        UART_transmit = temp;
    }

    static inline void SPI_send_float(float data) {
        int temp;
        __asm__ ("fmv.x.w %0, %1": "=r" (temp): "f"  (data));
        SPI_send_reg = temp;
    }

    static inline void UART_write_blocked_float(float data) {
        while ((UART_read_status() & UART_TX_MASK) == 0) {
            // wait
        }
        UART_send_float(data);
    }

    static inline void SPI_write_blocked_float(float data) {
        while ((SPI_read_status() & SPI_TX_FIFO_FULL_MASK) != 0) {
            // wait until spi not full
        }
        SPI_send_float(data);
    }

    static inline float UART_read_blocked_float(void) {
        while ((UART_read_status() & UART_RX_MASK) == 0) {
            // wait
        }
        return UART_read_float();    
    }

    static inline float SPI_read_blocked_float(void) {
        while ((SPI_read_status() & SPI_RX_FIFO_EMPTY_MASK) != 0){
            // wait until spi not empty
        }
        return SPI_read_float();
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

    /*
        Floating Point convolution function with inline assembly implementation.
        This supports multi-channel 1D convolutions.

        @param data pointer to the input data array
        @param weights pointer to the weights array
        @param output pointer to the output array
        @param data_length length of the input data array -> length * depth 
        @param weights_length length of the weights array
        @param output_length length of the output array
        @param output_channels number of output channels
    */
    static inline int convolution1D(float *data, float *weights, float *output, int weights_length, int output_length,
                                                int output_channels, int bias, int stride) {
        return flat_convolution(data, weights, output, weights_length, output_length, output_channels, bias, stride);
    }

#endif