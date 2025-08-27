#ifndef X_CAWT_BRIDGE
#define X_CAWT_BRIDGE
#include <stdint.h>

    // MM addresses
    #define UART_address 0x100082A0u
    #define UART_status (* (volatile uint32_t *) (UART_address + 0x04u))
    #define UART_receive (* (volatile uint32_t *) (UART_address + 0x08u))
    #define UART_transmit (* (volatile uint32_t *) (UART_address + 0x0Cu))

    static inline uint32_t UART_read_status(void) {
        return UART_status;
    }
    
    static inline uint32_t UART_read(void) {
        return UART_receive;
    }

    static inline void UART_send(uint32_t data) {
        UART_transmit = data;
    }

    static inline uint32_t vmac(uint32_t acc, uint32_t a, uint32_t b){
        asm volatile (".insn r 0x5B, 0x00, 0x01, %0, %1, %2"
                    : "+r"(acc) : "r"(a), "r"(b));
        return acc;
    }

    static inline uint32_t vadd(uint32_t a, uint32_t b){
        uint32_t rd;
        asm volatile (".insn r 0x5B, 0x00, 0x00, %0, %1, %2"
                    : "=r"(rd) : "r"(a), "r"(b));
        return rd;
    }

    static inline uint32_t vload(const void *base, int32_t offset){
        uint32_t rd; 
        asm volatile (".insn i 0x0B, 0x02, %0, %1, %2"
                    : "=r"(rd) : "r"(base), "i"(offset));
        return rd;
    }

    static inline uint32_t vsload(const void *base, int32_t offset){
        uint32_t rd; 
        asm volatile (".insn i 0x0B, 0x06, %0, %1, %2"
                    : "=r"(rd) : "r"(base), "i"(offset));
        return rd;
    }

    static inline uint32_t vslli(uint32_t a, int32_t b){
        uint32_t rd; 
        asm volatile (".insn i 0x0B, 0x01, %0, %1, %2"
                    : "=r"(rd) : "r"(a), "i"(b));
        return rd;
    }

    static inline void vstore(uint32_t value, const void *base, int32_t offset){
        asm volatile (".insn i 0x2B, 0x02, %0, %1, %2" : // no output
                    : "r"(value), "r"(base), "i"(offset) : "memory");
    }

    static inline uint32_t vcaddi(uint32_t a, int32_t b){
        uint32_t rd; 
        asm volatile (".insn i 0x0B, 0x03, %0, %1, %2"
                    : "=r"(rd) : "r"(a), "i"(b));
        return rd;
    }
    
    static inline uint32_t vauipc(uint32_t imm20){
        uint32_t rd; 
        asm volatile (".insn u 0x7B, %0, %1"
                    : "=r"(rd) : "i"(imm20));
        return rd;
    }

    static inline uint32_t mac(uint32_t acc, int32_t a, int32_t b){
        asm volatile (".insn r 0x33, 0x00, 0x01, %0, %1, %2"
                    : "+r"(acc) : "r"(a), "r"(b));
        return acc;
    }

#endif