onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/du_e/clk
add wave -noupdate /testbench/du_e/ena
add wave -noupdate /testbench/du_e/req
add wave -noupdate /testbench/du_e/rdy
add wave -noupdate /testbench/du_e/bin
add wave -noupdate /testbench/du_e/ini
add wave -noupdate -radix hexadecimal /testbench/du_e/bcd
add wave -noupdate /testbench/du_e/load
add wave -noupdate /testbench/du_e/feed
add wave -noupdate /testbench/du_e/bin_slice
add wave -noupdate /testbench/du_e/cntr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {49424 ps} 0}
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
WaveRestoreZoom {36244 ps} {51994 ps}
