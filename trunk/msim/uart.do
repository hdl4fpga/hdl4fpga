onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /testbench/clk16
add wave -noupdate -format Logic /testbench/clk
add wave -noupdate -format Logic /testbench/du/clk_div(0)
add wave -noupdate -format Literal /testbench/reg
add wave -noupdate -format Literal /testbench/data
add wave -noupdate -format Logic /testbench/dout
add wave -noupdate -format Logic /testbench/din
add wave -noupdate -format Literal /testbench/du/tx/tx_state
add wave -noupdate -format Literal /testbench/du/rx/rx_state
add wave -noupdate -format Logic /testbench/rx_rdy
add wave -noupdate -format Logic /testbench/rx_ack
add wave -noupdate -format Logic /testbench/tx_rdy
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {7180 ns} 0}
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
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {12703 ns}
