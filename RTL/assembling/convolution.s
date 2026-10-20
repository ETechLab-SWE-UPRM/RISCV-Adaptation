
.section .text
.globl flat_convolution
.type flat_convolution, @function

# int flat_convolution(int *data, int *weights, int *output,
#                  int data_length, int weights_length, int output_length,
#                  int weights_depth, int weights_channels);
#
# RISC-V (RV32) ABI:
#   a0 = data : input array
#   a1 = weights : kernel array
#   a2 = output : result array
#   a3 = weights_length : kernel length * width
#   a4 = output_length
#   a5 = weigths_channels: output channels
#   a6 = bias
#   a7 = stride: For address calculation

# addresses where the lengths, channels, and offset are stored
.set offset_addr, 0x100082B0
.set weights_addr, 0x100082B4
.set weights_channels, 0x100082CC

flat_convolution:
    li t1, 0 # i = 0

    # Weight length store
    lui t2, %hi(weights_addr)
    sw a3, %lo(weights_addr)(t2)

    lui t2, %hi(weights_channels)
    sw a5, %lo(weights_channels)(t2)

    lui t2, %hi(offset_addr)
    sw a7, %lo(offset_addr)(t2)

    flw f0, 0(a0) # preload first data
    flw f1, 0(a1) # preload first weight

    # Add branch to add_stride here if you want to do so

outer_loop:
    li t0, 0

channel_loop:
    li t2, 0 # j = 0

    fmv.w.x f2, a6 # bias should be the bits of the floating point value (ex: 16 -> 0x41800000)

inner_loop:
    # f2 used as accumulator, dual issue will use the registers specified on the instruction
    # any register can be changed in this instruction if you wish so.
    fmadd.s f2, f0, f1, f2 # sum += data[i + j] * weights[j]

    addi t2, t2, 1
    blt t2, a3, inner_loop # finished kernel? 

inner_loop_finished:
    # Store the result
    fsw f2, 0(a2)
    addi a2, a2, 4 # output address increment
    addi t0, t0, 1 # Finished an output channel
    blt t0, a5, channel_loop # finished channel? 

    addi t1, t1, 1 # Advance output-position counter
    blt t1, a4, outer_loop # finished outputs? change branch to add_stride if you wish to do so

    li a0, 0
    ret

add_stride: # Helper function if you want to add stride between the loops (Default stride is 1)
    addi a0, a0, 4
    jal outer_loop

forever:
    jal forever
