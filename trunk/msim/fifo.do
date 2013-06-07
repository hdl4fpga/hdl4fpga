onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /testbench/clk
add wave -noupdate -format Logic /testbench/seek
add wave -noupdate -format Literal /testbench/deep
add wave -noupdate -format Analog-Step -height 256 -radix unsigned /testbench/xi
add wave -noupdate -format Analog-Step -height 256 -radix decimal /testbench/xo
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1897 ns} 0}
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
WaveRestoreZoom {1508 ns} {2500 ns}
