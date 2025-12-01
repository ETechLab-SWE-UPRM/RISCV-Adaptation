vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xpm
vlib questa_lib/msim/microblaze_v11_0_14
vlib questa_lib/msim/microblaze_riscv_v1_0_3
vlib questa_lib/msim/xil_defaultlib
vlib questa_lib/msim/lmb_v10_v3_0_14
vlib questa_lib/msim/lmb_bram_if_cntlr_v4_0_25
vlib questa_lib/msim/blk_mem_gen_v8_4_9
vlib questa_lib/msim/lib_cdc_v1_0_3
vlib questa_lib/msim/proc_sys_reset_v5_0_16

vmap xpm questa_lib/msim/xpm
vmap microblaze_v11_0_14 questa_lib/msim/microblaze_v11_0_14
vmap microblaze_riscv_v1_0_3 questa_lib/msim/microblaze_riscv_v1_0_3
vmap xil_defaultlib questa_lib/msim/xil_defaultlib
vmap lmb_v10_v3_0_14 questa_lib/msim/lmb_v10_v3_0_14
vmap lmb_bram_if_cntlr_v4_0_25 questa_lib/msim/lmb_bram_if_cntlr_v4_0_25
vmap blk_mem_gen_v8_4_9 questa_lib/msim/blk_mem_gen_v8_4_9
vmap lib_cdc_v1_0_3 questa_lib/msim/lib_cdc_v1_0_3
vmap proc_sys_reset_v5_0_16 questa_lib/msim/proc_sys_reset_v5_0_16

vlog -work xpm  -incr -mfcu  -sv \
"C:/Xilinx/Vivado/2024.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm  -93  \
"C:/Xilinx/Vivado/2024.2/data/ip/xpm/xpm_VCOMP.vhd" \

vcom -work microblaze_v11_0_14  -93  \
"../../../Risc-V processor.gen/sources_1/bd/MB_CPU/ipshared/a243/hdl/microblaze_v11_0_vh_rfs.vhd" \

vcom -work microblaze_riscv_v1_0_3  -93  \
"../../../Risc-V processor.gen/sources_1/bd/MB_CPU/ipshared/f9dd/hdl/microblaze_riscv_v1_0_vh_rfs.vhd" \

vcom -work xil_defaultlib  -93  \
"../../bd/MB_CPU/ip/MB_CPU_microblaze_riscv_0_0/sim/MB_CPU_microblaze_riscv_0_0.vhd" \

vcom -work lmb_v10_v3_0_14  -93  \
"../../../Risc-V processor.gen/sources_1/bd/MB_CPU/ipshared/7495/hdl/lmb_v10_v3_0_vh_rfs.vhd" \

vcom -work xil_defaultlib  -93  \
"../../bd/MB_CPU/ip/MB_CPU_dlmb_v10_0/sim/MB_CPU_dlmb_v10_0.vhd" \
"../../bd/MB_CPU/ip/MB_CPU_ilmb_v10_0/sim/MB_CPU_ilmb_v10_0.vhd" \

vcom -work lmb_bram_if_cntlr_v4_0_25  -93  \
"../../../Risc-V processor.gen/sources_1/bd/MB_CPU/ipshared/73e9/hdl/lmb_bram_if_cntlr_v4_0_vh_rfs.vhd" \

vcom -work xil_defaultlib  -93  \
"../../bd/MB_CPU/ip/MB_CPU_dlmb_bram_if_cntlr_0/sim/MB_CPU_dlmb_bram_if_cntlr_0.vhd" \
"../../bd/MB_CPU/ip/MB_CPU_ilmb_bram_if_cntlr_0/sim/MB_CPU_ilmb_bram_if_cntlr_0.vhd" \

vlog -work blk_mem_gen_v8_4_9  -incr -mfcu  \
"../../../Risc-V processor.gen/sources_1/bd/MB_CPU/ipshared/5ec1/simulation/blk_mem_gen_v8_4.v" \

vlog -work xil_defaultlib  -incr -mfcu  \
"../../bd/MB_CPU/ip/MB_CPU_lmb_bram_0/sim/MB_CPU_lmb_bram_0.v" \

vcom -work lib_cdc_v1_0_3  -93  \
"../../../Risc-V processor.gen/sources_1/bd/MB_CPU/ipshared/2a4f/hdl/lib_cdc_v1_0_rfs.vhd" \

vcom -work proc_sys_reset_v5_0_16  -93  \
"../../../Risc-V processor.gen/sources_1/bd/MB_CPU/ipshared/0831/hdl/proc_sys_reset_v5_0_vh_rfs.vhd" \

vcom -work xil_defaultlib  -93  \
"../../bd/MB_CPU/ip/MB_CPU_rst_Clk_100M_0/sim/MB_CPU_rst_Clk_100M_0.vhd" \

vlog -work xil_defaultlib  -incr -mfcu  \
"../../bd/MB_CPU/sim/MB_CPU.v" \
"../../../Risc-V processor.gen/sources_1/bd/MB_CPU/hdl/MB_CPU_wrapper.v" \

vlog -work xil_defaultlib  -incr -mfcu  -sv \
"../../../Risc-V processor.srcs/sim_1/new/MB_tester.sv" \

vlog -work xil_defaultlib \
"glbl.v"

