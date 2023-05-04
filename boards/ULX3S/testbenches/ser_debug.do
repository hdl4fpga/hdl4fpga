onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/du_e/clk_25mhz
add wave -noupdate /testbench/du_e/videoio_clk
add wave -noupdate /testbench/du_e/video_clk
add wave -noupdate /testbench/du_e/video_shift_clk
add wave -noupdate /testbench/du_e/video_lck
add wave -noupdate /testbench/du_e/video_hzsync
add wave -noupdate /testbench/du_e/video_vtsync
add wave -noupdate -divider {New Divider}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {15866637500 ps} 0} {{Cursor 2} {537500 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 228
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
WaveRestoreZoom {0 ps} {26758620690 ps}
