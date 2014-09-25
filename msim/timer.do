onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -color {Orange Red} /testbench/du/rdy
add wave -noupdate /testbench/du/data
add wave -noupdate /testbench/du/clk
add wave -noupdate /testbench/du/rdy
add wave -noupdate /testbench/du/req
add wave -noupdate /testbench/du/csize
add wave -noupdate /testbench/du/stage_size
add wave -noupdate /testbench/du/cy
add wave -noupdate /testbench/du/cntr_g(0)/cntr
add wave -noupdate /testbench/du/cntr_g(1)/cntr
add wave -noupdate /testbench/du/cntr_g(2)/cntr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {499999 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 109
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
WaveRestoreZoom {3999999 ps} {4000002 ps}
