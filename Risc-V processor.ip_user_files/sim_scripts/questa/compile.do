vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xilinx_vip
vlib questa_lib/msim/xpm
vlib questa_lib/msim/xbip_dsp48_wrapper_v3_0_6
vlib questa_lib/msim/xbip_utils_v3_0_14
vlib questa_lib/msim/xbip_pipe_v3_0_10
vlib questa_lib/msim/dsp_macro_v1_0_7
vlib questa_lib/msim/xil_defaultlib
vlib questa_lib/msim/blk_mem_gen_v8_4_9
vlib questa_lib/msim/axi_utils_v2_0_10
vlib questa_lib/msim/mult_gen_v12_0_22
vlib questa_lib/msim/floating_point_v7_1_19

vmap xilinx_vip questa_lib/msim/xilinx_vip
vmap xpm questa_lib/msim/xpm
vmap xbip_dsp48_wrapper_v3_0_6 questa_lib/msim/xbip_dsp48_wrapper_v3_0_6
vmap xbip_utils_v3_0_14 questa_lib/msim/xbip_utils_v3_0_14
vmap xbip_pipe_v3_0_10 questa_lib/msim/xbip_pipe_v3_0_10
vmap dsp_macro_v1_0_7 questa_lib/msim/dsp_macro_v1_0_7
vmap xil_defaultlib questa_lib/msim/xil_defaultlib
vmap blk_mem_gen_v8_4_9 questa_lib/msim/blk_mem_gen_v8_4_9
vmap axi_utils_v2_0_10 questa_lib/msim/axi_utils_v2_0_10
vmap mult_gen_v12_0_22 questa_lib/msim/mult_gen_v12_0_22
vmap floating_point_v7_1_19 questa_lib/msim/floating_point_v7_1_19

vlog -work xilinx_vip  -incr -mfcu  -sv -L axi_vip_v1_1_19 -L smartconnect_v1_0 -L xilinx_vip "+incdir+C:/Xilinx/Vivado/2024.2/data/xilinx_vip/include" \
"C:/Xilinx/Vivado/2024.2/data/xilinx_vip/hdl/axi4stream_vip_axi4streampc.sv" \
"C:/Xilinx/Vivado/2024.2/data/xilinx_vip/hdl/axi_vip_axi4pc.sv" \
"C:/Xilinx/Vivado/2024.2/data/xilinx_vip/hdl/xil_common_vip_pkg.sv" \
"C:/Xilinx/Vivado/2024.2/data/xilinx_vip/hdl/axi4stream_vip_pkg.sv" \
"C:/Xilinx/Vivado/2024.2/data/xilinx_vip/hdl/axi_vip_pkg.sv" \
"C:/Xilinx/Vivado/2024.2/data/xilinx_vip/hdl/axi4stream_vip_if.sv" \
"C:/Xilinx/Vivado/2024.2/data/xilinx_vip/hdl/axi_vip_if.sv" \
"C:/Xilinx/Vivado/2024.2/data/xilinx_vip/hdl/clk_vip_if.sv" \
"C:/Xilinx/Vivado/2024.2/data/xilinx_vip/hdl/rst_vip_if.sv" \

vlog -work xpm  -incr -mfcu  -sv -L axi_vip_v1_1_19 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../Risc-V processor.gen/sources_1/bd/MB_CPU/ipshared/f0b6/hdl/verilog" "+incdir+../../../Risc-V processor.gen/sources_1/bd/MB_CPU/ipshared/0127/hdl/verilog" "+incdir+../../../Risc-V processor.gen/sources_1/bd/MB_CPU/ipshared/ec67/hdl" "+incdir+C:/Xilinx/Vivado/2024.2/data/xilinx_vip/include" \
"C:/Xilinx/Vivado/2024.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm  -93  \
"C:/Xilinx/Vivado/2024.2/data/ip/xpm/xpm_VCOMP.vhd" \

vcom -work xbip_dsp48_wrapper_v3_0_6  -93  \
"../../ipstatic/hdl/xbip_dsp48_wrapper_v3_0_vh_rfs.vhd" \

vcom -work xbip_utils_v3_0_14  -93  \
"../../ipstatic/hdl/xbip_utils_v3_0_vh_rfs.vhd" \

vcom -work xbip_pipe_v3_0_10  -93  \
"../../ipstatic/hdl/xbip_pipe_v3_0_vh_rfs.vhd" \

vcom -work dsp_macro_v1_0_7  -93  \
"../../ipstatic/hdl/dsp_macro_v1_0_rfs.vhd" \

vcom -work xil_defaultlib  -93  \
"../../../Risc-V processor.gen/sources_1/ip/MAC_dsp/sim/MAC_dsp.vhd" \

vlog -work blk_mem_gen_v8_4_9  -incr -mfcu  "+incdir+../../../Risc-V processor.gen/sources_1/bd/MB_CPU/ipshared/f0b6/hdl/verilog" "+incdir+../../../Risc-V processor.gen/sources_1/bd/MB_CPU/ipshared/0127/hdl/verilog" "+incdir+../../../Risc-V processor.gen/sources_1/bd/MB_CPU/ipshared/ec67/hdl" "+incdir+C:/Xilinx/Vivado/2024.2/data/xilinx_vip/include" \
"../../ipstatic/simulation/blk_mem_gen_v8_4.v" \

vlog -work xil_defaultlib  -incr -mfcu  "+incdir+../../../Risc-V processor.gen/sources_1/bd/MB_CPU/ipshared/f0b6/hdl/verilog" "+incdir+../../../Risc-V processor.gen/sources_1/bd/MB_CPU/ipshared/0127/hdl/verilog" "+incdir+../../../Risc-V processor.gen/sources_1/bd/MB_CPU/ipshared/ec67/hdl" "+incdir+C:/Xilinx/Vivado/2024.2/data/xilinx_vip/include" \
"../../../Risc-V processor.gen/sources_1/ip/blk_mem_gen_0_1/sim/blk_mem_gen_0.v" \

vcom -work axi_utils_v2_0_10  -93  \
"../../ipstatic/hdl/axi_utils_v2_0_vh_rfs.vhd" \

vcom -work mult_gen_v12_0_22  -93  \
"../../ipstatic/hdl/mult_gen_v12_0_vh_rfs.vhd" \

vcom -work floating_point_v7_1_19  -93  \
"../../ipstatic/hdl/floating_point_v7_1_rfs.vhd" \

vlog -work floating_point_v7_1_19  -incr -mfcu  "+incdir+../../../Risc-V processor.gen/sources_1/bd/MB_CPU/ipshared/f0b6/hdl/verilog" "+incdir+../../../Risc-V processor.gen/sources_1/bd/MB_CPU/ipshared/0127/hdl/verilog" "+incdir+../../../Risc-V processor.gen/sources_1/bd/MB_CPU/ipshared/ec67/hdl" "+incdir+C:/Xilinx/Vivado/2024.2/data/xilinx_vip/include" \
"../../ipstatic/hdl/floating_point_v7_1_rfs.v" \

vlog -work xil_defaultlib  -incr -mfcu  "+incdir+../../../Risc-V processor.gen/sources_1/bd/MB_CPU/ipshared/f0b6/hdl/verilog" "+incdir+../../../Risc-V processor.gen/sources_1/bd/MB_CPU/ipshared/0127/hdl/verilog" "+incdir+../../../Risc-V processor.gen/sources_1/bd/MB_CPU/ipshared/ec67/hdl" "+incdir+C:/Xilinx/Vivado/2024.2/data/xilinx_vip/include" \
"../../../Risc-V processor.gen/sources_1/ip/floating_point_add_sub/sim/floating_point_add_sub.v" \
"../../../Risc-V processor.gen/sources_1/ip/floating_point_multiplier/sim/floating_point_multiplier.v" \
"../../../Risc-V processor.gen/sources_1/ip/floating_point_branching/sim/floating_point_branching.v" \
"../../../Risc-V processor.gen/sources_1/ip/int_to_float_ip/sim/int_to_float_ip.v" \
"../../../Risc-V processor.gen/sources_1/ip/Instruction_Memory/sim/Instruction_Memory.v" \
"../../../Risc-V processor.srcs/sources_1/new/baud_rate_generator.v" \
"../../../Risc-V processor.srcs/sources_1/new/fifo.v" \
"../../../Risc-V processor.srcs/sources_1/new/uart_receiver.v" \
"../../../Risc-V processor.srcs/sources_1/new/uart_top.v" \
"../../../Risc-V processor.srcs/sources_1/new/uart_transmitter.v" \

vlog -work xil_defaultlib  -incr -mfcu  -sv -L axi_vip_v1_1_19 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../Risc-V processor.gen/sources_1/bd/MB_CPU/ipshared/f0b6/hdl/verilog" "+incdir+../../../Risc-V processor.gen/sources_1/bd/MB_CPU/ipshared/0127/hdl/verilog" "+incdir+../../../Risc-V processor.gen/sources_1/bd/MB_CPU/ipshared/ec67/hdl" "+incdir+C:/Xilinx/Vivado/2024.2/data/xilinx_vip/include" \
"../../../Risc-V processor.srcs/sources_1/new/ALU.sv" \
"../../../Risc-V processor.srcs/sources_1/new/ALU_Control.sv" \
"../../../Risc-V processor.srcs/sources_1/new/Control.sv" \
"../../../Risc-V processor.srcs/sources_1/new/Data_memory.sv" \
"../../../Risc-V processor.srcs/sources_1/new/PipelinedRISCV.sv" \
"../../../Risc-V processor.srcs/sources_1/new/EX_MEM_reg.sv" \
"../../../Risc-V processor.srcs/sources_1/new/ID_EX_reg.sv" \
"../../../Risc-V processor.srcs/sources_1/new/IF_ID_reg.sv" \
"../../../Risc-V processor.srcs/sources_1/new/Imm_gen.sv" \
"../../../Risc-V processor.srcs/sources_1/new/InstructionMemory.sv" \
"../../../Risc-V processor.srcs/sources_1/new/MEM_WB_reg.sv" \
"../../../Risc-V processor.srcs/sources_1/new/ProgramCounter.sv" \
"../../../Risc-V processor.srcs/sources_1/new/Registers.sv" \
"../../../Risc-V processor.srcs/sources_1/new/branch.sv" \
"../../../Risc-V processor.srcs/sources_1/new/forwarding_unit.sv" \
"../../../Risc-V processor.srcs/sources_1/new/fp_alu.sv" \
"../../../Risc-V processor.srcs/sources_1/new/fp_alu_control.sv" \
"../../../Risc-V processor.srcs/sources_1/new/fp_control.sv" \
"../../../Risc-V processor.srcs/sources_1/new/fp_forward.sv" \
"../../../Risc-V processor.srcs/sources_1/new/fp_hazard.sv" \
"../../../Risc-V processor.srcs/sources_1/new/fp_registers.sv" \
"../../../Risc-V processor.srcs/sources_1/new/hazard_detection.sv" \
"../../../Risc-V processor.srcs/sources_1/new/vector_ALU.sv" \
"../../../Risc-V processor.srcs/sources_1/new/vector_registers.sv" \
"../../../Risc-V processor.srcs/sim_1/new/PipelineTester.sv" \

vlog -work xil_defaultlib \
"glbl.v"

