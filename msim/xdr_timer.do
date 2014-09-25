onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/sys_clk
add wave -noupdate /testbench/sys_req
add wave -noupdate /testbench/sys_rdy
add wave -noupdate /testbench/timer_sel
add wave -noupdate /testbench/timer_data
add wave -noupdate -expand /testbench/du/timer_e/csize
add wave -noupdate /testbench/du/timer_size
add wave -noupdate /testbench/du/timer_e/data
add wave -noupdate /testbench/du/timer_e/cntr_g(0)/cntr
add wave -noupdate /testbench/du/timer_e/cntr_g(1)/cntr
add wave -noupdate /testbench/du/timer_e/cntr_g(2)/cntr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {29212 ps} 0}
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
WaveRestoreZoom {0 ps} {420 ns}
