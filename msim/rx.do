onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /testbench/din
add wave -noupdate -format Logic /testbench/clk16
add wave -noupdate -format Logic /testbench/clk
add wave -noupdate -format Logic /testbench/rdy
add wave -noupdate -format Literal /testbench/du/rx_reg
add wave -noupdate -format Literal /testbench/dout
add wave -noupdate -format Literal -radix unsigned /testbench/du/rx_cntr
add wave -noupdate -format Literal -radix unsigned /testbench/du/rx_bcnt
add wave -noupdate -format Literal /testbench/du/rx_state
add wave -noupdate -format Literal -radix hexadecimal /testbench/du/rx_div
add wave -noupdate -format Logic /testbench/du/rx_win
add wave -noupdate -format Logic /testbench/du/rx_syn
add wave -noupdate -format Logic /testbench/du/rx_lvl
add wave -noupdate -format Logic /testbench/du/rx_syn
add wave -noupdate -format Logic /testbench/du/rx_end
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {514 ns} 0}
configure wave -namecolwidth 174
configure wave -valuecolwidth 76
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
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {5312 ns}
