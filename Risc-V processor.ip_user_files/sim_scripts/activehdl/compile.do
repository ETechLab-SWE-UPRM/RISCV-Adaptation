transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

vlib work
vlib activehdl/xpm
vlib activehdl/microblaze_v11_0_14
vlib activehdl/microblaze_riscv_v1_0_3
vlib activehdl/xil_defaultlib
vlib activehdl/lmb_v10_v3_0_14
vlib activehdl/lmb_bram_if_cntlr_v4_0_25
vlib activehdl/blk_mem_gen_v8_4_9
vlib activehdl/lib_cdc_v1_0_3
vlib activehdl/proc_sys_reset_v5_0_16

vmap xpm activehdl/xpm
vmap microblaze_v11_0_14 activehdl/microblaze_v11_0_14
vmap microblaze_riscv_v1_0_3 activehdl/microblaze_riscv_v1_0_3
vmap xil_defaultlib activehdl/xil_defaultlib
vmap lmb_v10_v3_0_14 activehdl/lmb_v10_v3_0_14
vmap lmb_bram_if_cntlr_v4_0_25 activehdl/lmb_bram_if_cntlr_v4_0_25
vmap blk_mem_gen_v8_4_9 activehdl/blk_mem_gen_v8_4_9
vmap lib_cdc_v1_0_3 activehdl/lib_cdc_v1_0_3
vmap proc_sys_reset_v5_0_16 activehdl/proc_sys_reset_v5_0_16

vlog -work xpm  -sv2k12 -l xpm -l microblaze_v11_0_14 -l microblaze_riscv_v1_0_3 -l xil_defaultlib -l lmb_v10_v3_0_14 -l lmb_bram_if_cntlr_v4_0_25 -l blk_mem_gen_v8_4_9 -l lib_cdc_v1_0_3 -l proc_sys_reset_v5_0_16 \
"C:/Xilinx/Vivado/2024.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -93  \
"C:/Xilinx/Vivado/2024.2/data/ip/xpm/xpm_VCOMP.vhd" \

vcom -work microblaze_v11_0_14 -93  \
"../../../Risc-V processor.gen/sources_1/bd/MB_CPU/ipshared/a243/hdl/microblaze_v11_0_vh_rfs.vhd" \

vcom -work microblaze_riscv_v1_0_3 -93  \
"../../../Risc-V processor.gen/sources_1/bd/MB_CPU/ipshared/f9dd/hdl/microblaze_riscv_v1_0_vh_rfs.vhd" \

vcom -work xil_defaultlib -93  \
"../../bd/MB_CPU/ip/MB_CPU_microblaze_riscv_0_0/sim/MB_CPU_microblaze_riscv_0_0.vhd" \

vcom -work lmb_v10_v3_0_14 -93  \
"../../../Risc-V processor.gen/sources_1/bd/MB_CPU/ipshared/7495/hdl/lmb_v10_v3_0_vh_rfs.vhd" \

vcom -work xil_defaultlib -93  \
"../../bd/MB_CPU/ip/MB_CPU_dlmb_v10_0/sim/MB_CPU_dlmb_v10_0.vhd" \
"../../bd/MB_CPU/ip/MB_CPU_ilmb_v10_0/sim/MB_CPU_ilmb_v10_0.vhd" \

vcom -work lmb_bram_if_cntlr_v4_0_25 -93  \
"../../../Risc-V processor.gen/sources_1/bd/MB_CPU/ipshared/73e9/hdl/lmb_bram_if_cntlr_v4_0_vh_rfs.vhd" \

vcom -work xil_defaultlib -93  \
"../../bd/MB_CPU/ip/MB_CPU_dlmb_bram_if_cntlr_0/sim/MB_CPU_dlmb_bram_if_cntlr_0.vhd" \
"../../bd/MB_CPU/ip/MB_CPU_ilmb_bram_if_cntlr_0/sim/MB_CPU_ilmb_bram_if_cntlr_0.vhd" \

vlog -work blk_mem_gen_v8_4_9  -v2k5 -l xpm -l microblaze_v11_0_14 -l microblaze_riscv_v1_0_3 -l xil_defaultlib -l lmb_v10_v3_0_14 -l lmb_bram_if_cntlr_v4_0_25 -l blk_mem_gen_v8_4_9 -l lib_cdc_v1_0_3 -l proc_sys_reset_v5_0_16 \
"../../../Risc-V processor.gen/sources_1/bd/MB_CPU/ipshared/5ec1/simulation/blk_mem_gen_v8_4.v" \

vlog -work xil_defaultlib  -v2k5 -l xpm -l microblaze_v11_0_14 -l microblaze_riscv_v1_0_3 -l xil_defaultlib -l lmb_v10_v3_0_14 -l lmb_bram_if_cntlr_v4_0_25 -l blk_mem_gen_v8_4_9 -l lib_cdc_v1_0_3 -l proc_sys_reset_v5_0_16 \
"../../bd/MB_CPU/ip/MB_CPU_lmb_bram_0/sim/MB_CPU_lmb_bram_0.v" \

vcom -work lib_cdc_v1_0_3 -93  \
"../../../Risc-V processor.gen/sources_1/bd/MB_CPU/ipshared/2a4f/hdl/lib_cdc_v1_0_rfs.vhd" \

vcom -work proc_sys_reset_v5_0_16 -93  \
"../../../Risc-V processor.gen/sources_1/bd/MB_CPU/ipshared/0831/hdl/proc_sys_reset_v5_0_vh_rfs.vhd" \

vcom -work xil_defaultlib -93  \
"../../bd/MB_CPU/ip/MB_CPU_rst_Clk_100M_0/sim/MB_CPU_rst_Clk_100M_0.vhd" \

vlog -work xil_defaultlib  -v2k5 -l xpm -l microblaze_v11_0_14 -l microblaze_riscv_v1_0_3 -l xil_defaultlib -l lmb_v10_v3_0_14 -l lmb_bram_if_cntlr_v4_0_25 -l blk_mem_gen_v8_4_9 -l lib_cdc_v1_0_3 -l proc_sys_reset_v5_0_16 \
"../../bd/MB_CPU/sim/MB_CPU.v" \
"../../../Risc-V processor.gen/sources_1/bd/MB_CPU/hdl/MB_CPU_wrapper.v" \

vlog -work xil_defaultlib  -sv2k12 -l xpm -l microblaze_v11_0_14 -l microblaze_riscv_v1_0_3 -l xil_defaultlib -l lmb_v10_v3_0_14 -l lmb_bram_if_cntlr_v4_0_25 -l blk_mem_gen_v8_4_9 -l lib_cdc_v1_0_3 -l proc_sys_reset_v5_0_16 \
"../../../Risc-V processor.srcs/sim_1/new/MB_tester.sv" \

vlog -work xil_defaultlib \
"glbl.v"

