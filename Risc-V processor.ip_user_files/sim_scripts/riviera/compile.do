transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

vlib work
vlib riviera/xpm
vlib riviera/xbip_utils_v3_0_14
vlib riviera/axi_utils_v2_0_10
vlib riviera/xbip_pipe_v3_0_10
vlib riviera/xbip_dsp48_wrapper_v3_0_6
vlib riviera/mult_gen_v12_0_22
vlib riviera/floating_point_v7_1_19
vlib riviera/xil_defaultlib

vmap xpm riviera/xpm
vmap xbip_utils_v3_0_14 riviera/xbip_utils_v3_0_14
vmap axi_utils_v2_0_10 riviera/axi_utils_v2_0_10
vmap xbip_pipe_v3_0_10 riviera/xbip_pipe_v3_0_10
vmap xbip_dsp48_wrapper_v3_0_6 riviera/xbip_dsp48_wrapper_v3_0_6
vmap mult_gen_v12_0_22 riviera/mult_gen_v12_0_22
vmap floating_point_v7_1_19 riviera/floating_point_v7_1_19
vmap xil_defaultlib riviera/xil_defaultlib

vlog -work xpm  -incr -l xpm -l xbip_utils_v3_0_14 -l axi_utils_v2_0_10 -l xbip_pipe_v3_0_10 -l xbip_dsp48_wrapper_v3_0_6 -l mult_gen_v12_0_22 -l floating_point_v7_1_19 -l xil_defaultlib \
"C:/Xilinx/Vivado/2024.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -93  -incr \
"C:/Xilinx/Vivado/2024.2/data/ip/xpm/xpm_VCOMP.vhd" \

vcom -work xbip_utils_v3_0_14 -93  -incr \
"../../ipstatic/hdl/xbip_utils_v3_0_vh_rfs.vhd" \

vcom -work axi_utils_v2_0_10 -93  -incr \
"../../ipstatic/hdl/axi_utils_v2_0_vh_rfs.vhd" \

vcom -work xbip_pipe_v3_0_10 -93  -incr \
"../../ipstatic/hdl/xbip_pipe_v3_0_vh_rfs.vhd" \

vcom -work xbip_dsp48_wrapper_v3_0_6 -93  -incr \
"../../ipstatic/hdl/xbip_dsp48_wrapper_v3_0_vh_rfs.vhd" \

vcom -work mult_gen_v12_0_22 -93  -incr \
"../../ipstatic/hdl/mult_gen_v12_0_vh_rfs.vhd" \

vcom -work floating_point_v7_1_19 -93  -incr \
"../../ipstatic/hdl/floating_point_v7_1_rfs.vhd" \

vlog -work floating_point_v7_1_19  -incr -v2k5 -l xpm -l xbip_utils_v3_0_14 -l axi_utils_v2_0_10 -l xbip_pipe_v3_0_10 -l xbip_dsp48_wrapper_v3_0_6 -l mult_gen_v12_0_22 -l floating_point_v7_1_19 -l xil_defaultlib \
"../../ipstatic/hdl/floating_point_v7_1_rfs.v" \

vlog -work xil_defaultlib  -incr -v2k5 -l xpm -l xbip_utils_v3_0_14 -l axi_utils_v2_0_10 -l xbip_pipe_v3_0_10 -l xbip_dsp48_wrapper_v3_0_6 -l mult_gen_v12_0_22 -l floating_point_v7_1_19 -l xil_defaultlib \
"../../../Risc-V processor.gen/sources_1/ip/floating_point_branching/sim/floating_point_branching.v" \
"../../../Risc-V processor.gen/sources_1/ip/floating_point_add_sub/sim/floating_point_add_sub.v" \

vlog -work xil_defaultlib  -incr -l xpm -l xbip_utils_v3_0_14 -l axi_utils_v2_0_10 -l xbip_pipe_v3_0_10 -l xbip_dsp48_wrapper_v3_0_6 -l mult_gen_v12_0_22 -l floating_point_v7_1_19 -l xil_defaultlib \
"../../../Risc-V processor.srcs/sources_1/new/PipelinedRISCV.sv" \
"../../../Risc-V processor.srcs/sources_1/new/fp_alu.sv" \
"../../../Risc-V processor.srcs/sim_1/new/fp_alu_testing.sv" \

vlog -work xil_defaultlib \
"glbl.v"

