onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/rst
add wave -noupdate /testbench/i2c_sda
add wave -noupdate /testbench/i2c_scl
add wave -noupdate /testbench/du/sda_fall
add wave -noupdate /testbench/du/sda_rise
add wave -noupdate /testbench/du/start
add wave -noupdate /testbench/du/seq_p/cntr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {108 ns} 0}
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
configure wave -gridperiod 2
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {208 ns}
