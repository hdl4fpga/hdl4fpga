onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /testbench/clk
add wave -noupdate -format Logic /testbench/rdy
add wave -noupdate -format Literal -radix unsigned /testbench/ww
add wave -noupdate -format Literal -radix unsigned /testbench/cp
add wave -noupdate -format Literal -radix unsigned /testbench/du/fifo/deep
add wave -noupdate -format Literal -radix unsigned /testbench/du/fifo/ni
add wave -noupdate -format Analog-Step -height 256 -radix decimal /testbench/xi
add wave -noupdate -format Analog-Step -height 256 -radix decimal /testbench/xo
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1325 ns} 0}
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
WaveRestoreZoom {0 ns} {2372 ns}
