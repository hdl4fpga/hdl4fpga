onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/ddr_timer_rst
add wave -noupdate /testbench/ddr_timer_clk
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/ddr_init_rst
add wave -noupdate /testbench/ddr_init_cke
add wave -noupdate /testbench/du/ddr_init_cfg
add wave -noupdate /testbench/dll_timer_rdy
add wave -noupdate /testbench/dll_timer_req
add wave -noupdate /testbench/ref_timer_rdy
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/ref_timer_req
add wave -noupdate /testbench/du/timers_e/q0
add wave -noupdate /testbench/du/timer_rdy
add wave -noupdate /testbench/du/line__86/o_tid
add wave -noupdate /testbench/du/timer_req
add wave -noupdate /testbench/du/timer_id
add wave -noupdate /testbench/du/timer_sel
add wave -noupdate /testbench/du/timers_e/timer_sel
add wave -noupdate -radix hexadecimal /testbench/du/timers_e/cntr_g(2)/cntr_p/data
add wave -noupdate -radix hexadecimal /testbench/du/timers_e/cntr_g(1)/cntr_p/data
add wave -noupdate -radix hexadecimal /testbench/du/timers_e/cntr_g(0)/cntr_p/data
add wave -noupdate /testbench/du/z(4)
add wave -noupdate /testbench/du/z(4)
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {801016547 ps} 0} {{Cursor 2} {700071643 ps} 0} {{Cursor 3} {799997110 ps} 0}
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
WaveRestoreZoom {799847851 ps} {801898667 ps}
