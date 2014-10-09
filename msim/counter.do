onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/du/clk
add wave -noupdate /testbench/du/load
add wave -noupdate /testbench/du/cntr_g(0)/cntr
add wave -noupdate /testbench/du/cntr_g(1)/cntr
add wave -noupdate /testbench/du/cntr_g(2)/cntr
add wave -noupdate /testbench/du/q
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 fs} 0}
quietly wave cursor active 0
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
configure wave -timelineunits ps
update
WaveRestoreZoom {76302 ps} {1048616 ps}
