onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/clk
add wave -noupdate -expand /testbench/sys_clks
add wave -noupdate /testbench/sys_rea
add wave -noupdate -expand /testbench/du/xdr_st
add wave -noupdate /testbench/du/wpho
add wave -noupdate /testbench/du/xdr_rwn
add wave -noupdate /testbench/du/WID_LAT
add wave -noupdate /testbench/du/DQSX_LAT
add wave -noupdate /testbench/du/STRX_LAT
add wave -noupdate -expand /testbench/du/STRL_TAB
add wave -noupdate /testbench/du/CL_COD
add wave -noupdate /testbench/du/sys_cl
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {397926 ps} 0} {{Cursor 2} {429915 ps} 0}
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
WaveRestoreZoom {373792 ps} {548443 ps}
