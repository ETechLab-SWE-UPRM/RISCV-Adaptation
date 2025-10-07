#ifndef X_CAWT_BRIDGE
#define X_CAWT_BRIDGE
#include <stdint.h>

    // MM addresses
    #define UART_address 0x100082A0u
    #define UART_status (* (volatile int32_t *) (UART_address + 0x04u))
    #define UART_receive (* (volatile int32_t *) (UART_address + 0x08u))
    #define UART_transmit (* (volatile int32_t *) (UART_address + 0x0Cu))

    static inline int32_t UART_read_status(void) {
        return UART_status;
    }
    
    static inline int32_t UART_read(void) {
        return UART_receive;
    }

    static inline void UART_send(int32_t data) {
        UART_transmit = data;
    }

    static inline int32_t vmac(int32_t acc, int32_t a, int32_t b){
        asm volatile (".insn r 0x5B, 0x00, 0x01, %0, %1, %2"
                    : "+r"(acc) : "r"(a), "r"(b));
        return acc;
    }

    static inline int32_t vadd(int32_t a, int32_t b){
        int32_t rd;
        asm volatile (".insn r 0x5B, 0x00, 0x00, %0, %1, %2"
                    : "=r"(rd) : "r"(a), "r"(b));
        return rd;
    }

    static inline int32_t vload(const void *base, int32_t offset){
        int32_t rd; 
        asm volatile (".insn i 0x0B, 0x02, %0, %1, %2"
                    : "=r"(rd) : "r"(base), "i"(offset));
        return rd;
    }

    static inline int32_t vsload(const void *base, int32_t offset){
        int32_t rd; 
        asm volatile (".insn i 0x0B, 0x06, %0, %1, %2"
                    : "=r"(rd) : "r"(base), "i"(offset));
        return rd;
    }

    static inline int32_t vslli(int32_t a, int32_t b){
        int32_t rd; 
        asm volatile (".insn i 0x0B, 0x01, %0, %1, %2"
                    : "=r"(rd) : "r"(a), "i"(b));
        return rd;
    }

    static inline void vstore(int32_t value, const void *base, int32_t offset){
        asm volatile (".insn i 0x2B, 0x02, %0, %1, %2" : // no output
                    : "r"(value), "r"(base), "i"(offset) : "memory");
    }

    static inline int32_t vcaddi(int32_t a, int32_t b){
        int32_t rd;
        asm volatile (".insn i 0x0B, 0x03, %0, %1, %2"
                    : "=r"(rd) : "r"(a), "i"(b));
        return rd;
    }
    
    static inline int32_t vauipc(int32_t imm20){
        int32_t rd; 
        asm volatile (".insn u 0x7B, %0, %1"
                    : "=r"(rd) : "i"(imm20));
        return rd;
    }

    static inline int32_t mac(int32_t acc, int32_t a, int32_t b){
        asm volatile (".insn r 0x33, 0x00, 0x01, %0, %1, %2"
                    : "+r"(acc) : "r"(a), "r"(b));
        return acc;
    }

#endif