transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

asim +access +r +m+pll_clk_gen  -L xil_defaultlib -L xpm -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.pll_clk_gen xil_defaultlib.glbl

do {pll_clk_gen.udo}

run 1000ns

endsim

quit -force
