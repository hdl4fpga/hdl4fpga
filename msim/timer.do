onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/du/n
add wave -noupdate -color {Orange Red} /testbench/du/rdy
add wave -noupdate /testbench/du/data
add wave -noupdate /testbench/du/clk
add wave -noupdate /testbench/du/rdy
add wave -noupdate /testbench/du/req
add wave -noupdate /testbench/du/size
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {628567 ps} 0} {{Cursor 3} {44905 ps} 0} {{Cursor 4} {1213675 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 297
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
WaveRestoreZoom {203 ns} {1135343 ps}
