vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xpm
vlib questa_lib/msim/xbip_utils_v3_0_14
vlib questa_lib/msim/axi_utils_v2_0_10
vlib questa_lib/msim/xbip_pipe_v3_0_10
vlib questa_lib/msim/xbip_dsp48_wrapper_v3_0_6
vlib questa_lib/msim/mult_gen_v12_0_22
vlib questa_lib/msim/floating_point_v7_1_19
vlib questa_lib/msim/xil_defaultlib

vmap xpm questa_lib/msim/xpm
vmap xbip_utils_v3_0_14 questa_lib/msim/xbip_utils_v3_0_14
vmap axi_utils_v2_0_10 questa_lib/msim/axi_utils_v2_0_10
vmap xbip_pipe_v3_0_10 questa_lib/msim/xbip_pipe_v3_0_10
vmap xbip_dsp48_wrapper_v3_0_6 questa_lib/msim/xbip_dsp48_wrapper_v3_0_6
vmap mult_gen_v12_0_22 questa_lib/msim/mult_gen_v12_0_22
vmap floating_point_v7_1_19 questa_lib/msim/floating_point_v7_1_19
vmap xil_defaultlib questa_lib/msim/xil_defaultlib

vlog -work xpm  -incr -mfcu  -sv \
"C:/Xilinx/Vivado/2024.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm  -93  \
"C:/Xilinx/Vivado/2024.2/data/ip/xpm/xpm_VCOMP.vhd" \

vcom -work xbip_utils_v3_0_14  -93  \
"../../ipstatic/hdl/xbip_utils_v3_0_vh_rfs.vhd" \

vcom -work axi_utils_v2_0_10  -93  \
"../../ipstatic/hdl/axi_utils_v2_0_vh_rfs.vhd" \

vcom -work xbip_pipe_v3_0_10  -93  \
"../../ipstatic/hdl/xbip_pipe_v3_0_vh_rfs.vhd" \

vcom -work xbip_dsp48_wrapper_v3_0_6  -93  \
"../../ipstatic/hdl/xbip_dsp48_wrapper_v3_0_vh_rfs.vhd" \

vcom -work mult_gen_v12_0_22  -93  \
"../../ipstatic/hdl/mult_gen_v12_0_vh_rfs.vhd" \

vcom -work floating_point_v7_1_19  -93  \
"../../ipstatic/hdl/floating_point_v7_1_rfs.vhd" \

vlog -work floating_point_v7_1_19  -incr -mfcu  \
"../../ipstatic/hdl/floating_point_v7_1_rfs.v" \

vlog -work xil_defaultlib  -incr -mfcu  \
"../../../Risc-V processor.gen/sources_1/ip/floating_point_branching/sim/floating_point_branching.v" \
"../../../Risc-V processor.gen/sources_1/ip/floating_point_add_sub/sim/floating_point_add_sub.v" \

vlog -work xil_defaultlib  -incr -mfcu  -sv \
"../../../Risc-V processor.srcs/sources_1/new/PipelinedRISCV.sv" \
"../../../Risc-V processor.srcs/sources_1/new/fp_alu.sv" \
"../../../Risc-V processor.srcs/sim_1/new/fp_alu_testing.sv" \

vlog -work xil_defaultlib \
"glbl.v"

