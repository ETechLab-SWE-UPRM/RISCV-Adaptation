transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

asim +access +r +m+PipelineTester  -L xil_defaultlib -L xpm -L blk_mem_gen_v8_4_9 -L xbip_dsp48_wrapper_v3_0_6 -L xbip_utils_v3_0_14 -L xbip_pipe_v3_0_10 -L dsp_macro_v1_0_7 -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.PipelineTester xil_defaultlib.glbl

do {PipelineTester.udo}

run 1000ns

endsim

quit -force
