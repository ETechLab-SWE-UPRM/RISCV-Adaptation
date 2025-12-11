onbreak {quit -f}
onerror {quit -f}

vsim -voptargs="+acc"  -L xil_defaultlib -L xpm -L xbip_dsp48_wrapper_v3_0_6 -L xbip_utils_v3_0_14 -L xbip_pipe_v3_0_10 -L dsp_macro_v1_0_7 -L blk_mem_gen_v8_4_9 -L axi_utils_v2_0_10 -L mult_gen_v12_0_22 -L floating_point_v7_1_19 -L unisims_ver -L unimacro_ver -L secureip -lib xil_defaultlib xil_defaultlib.PipelineTester xil_defaultlib.glbl

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure
view signals

do {PipelineTester.udo}

run 1000ns

quit -force
