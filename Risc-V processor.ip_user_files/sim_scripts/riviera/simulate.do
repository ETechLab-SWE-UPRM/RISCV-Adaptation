transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

asim +access +r +m+MB_tester  -L xil_defaultlib -L xpm -L microblaze_v11_0_14 -L microblaze_riscv_v1_0_3 -L lmb_v10_v3_0_14 -L lmb_bram_if_cntlr_v4_0_25 -L blk_mem_gen_v8_4_9 -L lib_cdc_v1_0_3 -L proc_sys_reset_v5_0_16 -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.MB_tester xil_defaultlib.glbl

do {MB_tester.udo}

run 1000ns

endsim

quit -force
