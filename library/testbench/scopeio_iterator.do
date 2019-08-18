onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /testbench/clk
add wave -noupdate -radix decimal /testbench/value
add wave -noupdate -radix hexadecimal /testbench/init
add wave -noupdate -radix hexadecimal /testbench/ena
add wave -noupdate -radix decimal /testbench/start
add wave -noupdate -radix decimal /testbench/stop
add wave -noupdate -radix decimal /testbench/step
add wave -noupdate -radix hexadecimal /testbench/ended
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {140 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 295
configure wave -valuecolwidth 300
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
WaveRestoreZoom {0 ns} {525 ns}
