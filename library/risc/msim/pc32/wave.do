onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic -label rst /testbench/rsts
add wave -noupdate -format Logic -label clk /testbench/clks
add wave -color yellow -noupdate -format Literal -label q -radix hexadecimal /testbench/qDelayS
TreeUpdate [SetDefaultTree]
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
update
WaveRestoreZoom {0 ns} {1 us}
run 400 ns
