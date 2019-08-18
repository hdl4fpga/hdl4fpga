onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/axis_e/axis_dv
add wave -noupdate /testbench/axis_e/axis_sel
add wave -noupdate -radix hexadecimal /testbench/axis_e/axis_scale
add wave -noupdate -radix hexadecimal /testbench/axis_e/axis_base
add wave -noupdate -radix decimal /testbench/axis_e/ticks_b/scopeio_iterator_e/clk
add wave -noupdate -radix decimal /testbench/axis_e/ticks_b/scopeio_iterator_e/start
add wave -noupdate -radix decimal /testbench/axis_e/ticks_b/scopeio_iterator_e/stop
add wave -noupdate -radix decimal /testbench/axis_e/ticks_b/scopeio_iterator_e/step
add wave -noupdate -radix decimal /testbench/axis_e/ticks_b/scopeio_iterator_e/value
add wave -noupdate /testbench/axis_e/ticks_b/scopeio_iterator_e/ended
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {9979 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {10500 ns}
