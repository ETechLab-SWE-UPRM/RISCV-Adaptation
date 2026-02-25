transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

asim +access +r +m+PipelineTester  -L xil_defaultlib -L xpm -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.PipelineTester xil_defaultlib.glbl

do {PipelineTester.udo}

run 1000ns

endsim

quit -force
