onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/scopeio_e/video_b/video_e/video_clk
add wave -noupdate /testbench/scopeio_e/video_b/video_e/video_hzsync
add wave -noupdate /testbench/scopeio_e/video_b/video_e/video_vtsync
add wave -noupdate /testbench/scopeio_e/video_b/video_e/video_hzcntr
add wave -noupdate /testbench/scopeio_e/video_b/video_e/video_vtcntr
add wave -noupdate /testbench/scopeio_e/video_b/video_e/video_hzon
add wave -noupdate /testbench/scopeio_e/video_b/video_e/video_vton
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 0
configure wave -namecolwidth 460
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
WaveRestoreZoom {0 ns} {886 ns}
