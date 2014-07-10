onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/clk
add wave -noupdate -expand /testbench/sys_clks
add wave -noupdate /testbench/sys_rea
add wave -noupdate /testbench/du/ph_rea
add wave -noupdate -expand /testbench/du/xdr_st
add wave -noupdate -expand /testbench/du/xdr_dr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {414001 ps} 0} {{Cursor 2} {430001 ps} 0}
quietly wave cursor active 2
configure wave -namecolwidth 116
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
WaveRestoreZoom {411505 ps} {433265 ps}
