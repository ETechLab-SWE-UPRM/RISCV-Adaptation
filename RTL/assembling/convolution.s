
.section .text
.globl Convolution
.type Convolution, @function

# void Convolution(int *data, int *weights, int *output,
#                  int data_length, int weights_length, int output_length);
#
# RISC-V (RV32) ABI:
#   a0 = data
#   a1 = weights
#   a2 = output
#   a3 = data_length
#   a4 = weights_length
#   a5 = output_length

#addresses where the lengths are stored
.set uart_status, 0x100082A4
.set uart_receive, 0x100082A8
.set uart_send, 0x100082AC
.set data_addr, 0x100082B0
.set weights_addr, 0x100082B4
.set output_addr, 0x100082B8

Convolution:
    # Input length store
    lui t1, %hi(data_addr)
    sw a3, %lo(data_addr)(t1)

    li t1, 0 # i = 0

    # Weight length store
    lui t2, %hi(weights_addr)
    sw a4, %lo(weights_addr)(t2)

    # Output length store
    lui t2, %hi(output_addr)
    sw a5, %lo(output_addr)(t2)

    flw f0, 0(a0) # preload first data
    flw f1, 0(a1) # preload first weight

outer_loop:
    li t2, 0 # j = 0
    fmv.w.x f2, x0 # sum = 0 

inner_loop:
    # f2 used as accumulator, dual issue will use the registers specified on the instruction
    # any register can be changed in this instruction if you wish so.
    fmadd.s f2, f0, f1, f2 # sum += data[i + j] * weights[j]

    addi t2, t2, 1
    blt t2, a4, inner_loop

inner_loop_finished:
    # Store the result
    fsw f2, 0(a2)
    addi a2, a2, 4 # output address increment
    addi t1, t1, 1
    blt t1, a5, outer_loop

    li a0, 0
    ret

add_strife: # Helper function if you want to add strife between the loops (Default strife is 1)
    addi a0, a0, 4
    jal outer_loop

forever:
    jal forever
