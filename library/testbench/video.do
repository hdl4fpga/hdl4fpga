onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/video_e/video_clk
add wave -noupdate /testbench/video_e/video_hzsync
add wave -noupdate /testbench/video_e/video_vtsync
add wave -noupdate /testbench/video_e/video_hzon
add wave -noupdate /testbench/video_e/video_vton
add wave -noupdate -radix unsigned /testbench/video_e/video_hzcntr
add wave -noupdate -radix unsigned /testbench/video_e/video_vtcntr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {7318508 ns} 0}
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
WaveRestoreZoom {7277444 ns} {7359492 ns}
