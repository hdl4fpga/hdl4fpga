onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/ddr_init_cke
add wave -noupdate /testbench/ddr_init_rst
add wave -noupdate /testbench/ddr_timer_clk
add wave -noupdate /testbench/ddr_timer_rst
add wave -noupdate /testbench/dll_timer_rdy
add wave -noupdate /testbench/dll_timer_req
add wave -noupdate /testbench/ref_timer_rdy
add wave -noupdate /testbench/ref_timer_req
add wave -noupdate /testbench/du/timers_e/q0
add wave -noupdate /testbench/du/timer_rdy
add wave -noupdate /testbench/du/timer_req
add wave -noupdate /testbench/du/timer_id
add wave -noupdate /testbench/du/line__88/next_tid
add wave -noupdate /testbench/du/line__88/o
add wave -noupdate /testbench/du/timer_sel
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {22498 ps} 1} {{Cursor 2} {6605 ps} 0}
quietly wave cursor active 2
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
WaveRestoreZoom {0 ps} {153810 ps}
