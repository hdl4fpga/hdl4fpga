onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/du/n
add wave -noupdate -expand /testbench/du/q0
add wave -noupdate /testbench/du/rdy
add wave -noupdate /testbench/du/timer_clk
add wave -noupdate /testbench/du/timer_data
add wave -noupdate /testbench/du/timer_len
add wave -noupdate /testbench/du/timer_rdy
add wave -noupdate /testbench/du/timer_req
add wave -noupdate /testbench/du/timer_sel
add wave -noupdate /testbench/du/cntr_g(1)/line__30/ena
add wave -noupdate -radix hexadecimal /testbench/du/cntr_g(1)/line__30/cntr
add wave -noupdate /testbench/du/cntr_g(0)/line__30/ena
add wave -noupdate -radix hexadecimal /testbench/du/cntr_g(0)/line__30/cntr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {70652 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 192
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
WaveRestoreZoom {800750 ps} {1115750 ps}
