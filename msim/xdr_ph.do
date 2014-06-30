onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand /testbench/du/clks
add wave -noupdate -expand /testbench/du/phi
add wave -noupdate -expand /testbench/du/ph_qo
add wave -noupdate /testbench/du/ph_qo(15)
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {897496 ps} 0} {{Cursor 2} {959746 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 83
configure wave -valuecolwidth 38
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
WaveRestoreZoom {0 ps} {132452 ps}
