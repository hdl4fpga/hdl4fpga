onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/du_e/src_clk
add wave -noupdate /testbench/du_e/src_frm
add wave -noupdate /testbench/du_e/src_data
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/shf
add wave -noupdate /testbench/du_e/rgtr
add wave -noupdate /testbench/du_e/shfd
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/dst_clk
add wave -noupdate /testbench/du_e/dst_data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {560000 ps} 0}
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
WaveRestoreZoom {0 ps} {1050 ns}
