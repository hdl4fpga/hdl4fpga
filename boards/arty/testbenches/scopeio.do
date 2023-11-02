onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/du_e/input_clk
add wave -noupdate /testbench/du_e/input_lck
add wave -noupdate /testbench/du_e/xadcctlr_b/drdy
add wave -noupdate /testbench/du_e/xadcctlr_b/eoc
add wave -noupdate /testbench/du_e/xadcctlr_b/di
add wave -noupdate /testbench/du_e/xadcctlr_b/dwe
add wave -noupdate /testbench/du_e/xadcctlr_b/den
add wave -noupdate /testbench/du_e/xadcctlr_b/daddr
add wave -noupdate /testbench/du_e/xadcctlr_b/channel
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {8351801 ps} 0} {{Cursor 2} {8361281 ps} 0}
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
configure wave -timelineunits us
update
WaveRestoreZoom {8269946 ps} {8434010 ps}
