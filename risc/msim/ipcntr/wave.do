onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic -label rst /testbench/rsts
add wave -noupdate -format Logic -label clk /testbench/clks
add wave -color white -divider "Counter"
add wave -color yellow -noupdate -format Literal -label qHigh -radix hexadecimal /testbench/qHighS
add wave -color red    -noupdate -format Literal -label qLow -radix hexadecimal /testbench/qLowS
add wave -color white -divider "Control signals"
add wave -color yellow -divider "High"
add wave -color yellow -noupdate -format Unsigned -label selLow -radix hexadecimal /testbench/selLowS
add wave -color yellow -noupdate -format Logic -label cout -radix hexadecimal /testbench/coutS
add wave -color red -divider "Low"
add wave -color red -noupdate -format Unsigned -label selHigh -radix hexadecimal /testbench/selHighS
add wave -color red -noupdate -format Logic -label enaHigh -radix hexadecimal /testbench/enaHighS
add wave -color red -noupdate -format Logic -label enaSelHigh -radix hexadecimal /testbench/enaSelHighS
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
