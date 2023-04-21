onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/frm
add wave -noupdate /testbench/clk
add wave -noupdate /testbench/q
add wave -noupdate /testbench/pixel
add wave -noupdate /testbench/blue
add wave -noupdate /testbench/green
add wave -noupdate /testbench/red
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {35494 ps} 0}
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
WaveRestoreZoom {0 ps} {105 ns}
