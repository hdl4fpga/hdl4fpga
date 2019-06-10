onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/video_e/video_clk
add wave -noupdate /testbench/video_e/video_hzsync
add wave -noupdate /testbench/video_e/video_vtsync
add wave -noupdate /testbench/video_e/video_hzon
add wave -noupdate /testbench/video_e/video_vton
add wave -noupdate -radix unsigned /testbench/video_e/video_hzcntr
add wave -noupdate -radix unsigned /testbench/video_e/video_vtcntr
add wave -noupdate /testbench/video_e/hz_div
add wave -noupdate /testbench/video_e/vt_div
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/box_yon
add wave -noupdate /testbench/box_xon
add wave -noupdate /testbench/box_divx
add wave -noupdate /testbench/box_divy
add wave -noupdate /testbench/box_sidex
add wave -noupdate /testbench/box_sidey
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {6947299 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 238
configure wave -valuecolwidth 120
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
WaveRestoreZoom {37506250 ns} {40131250 ns}
