onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /testbench/ddr_clk
add wave -noupdate -format Logic /testbench/ddr_rst
add wave -noupdate -format Logic /testbench/ddr_ras
add wave -noupdate -format Logic /testbench/ddr_cas
add wave -noupdate -format Logic /testbench/ddr_we
add wave -noupdate -format Literal -radix octal /testbench/du/line__58/step
add wave -noupdate -format Literal -radix hexadecimal /testbench/du/line__58/ac_timer
add wave -noupdate -format Logic /testbench/du/line__58/ac_rdy
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {55 ns} 0}
configure wave -namecolwidth 111
configure wave -valuecolwidth 40
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
WaveRestoreZoom {0 ns} {416 ns}
