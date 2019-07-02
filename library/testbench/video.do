onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/scopeio_e/video_b/video_e/video_clk
add wave -noupdate /testbench/scopeio_e/video_b/video_e/hz_div
add wave -noupdate /testbench/scopeio_e/video_b/video_e/vt_div
add wave -noupdate -radix unsigned /testbench/scopeio_e/video_b/video_e/video_hzsync
add wave -noupdate -radix unsigned /testbench/scopeio_e/video_b/video_e/video_vtsync
add wave -noupdate -radix unsigned /testbench/scopeio_e/video_b/video_e/video_hzcntr
add wave -noupdate -radix unsigned /testbench/scopeio_e/video_b/video_e/video_vtcntr
add wave -noupdate /testbench/scopeio_e/video_b/video_e/video_hzon
add wave -noupdate /testbench/scopeio_e/video_b/video_e/video_vton
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/scopeio_e/video_b/layout_b/mainlayout_e/x_edges
add wave -noupdate /testbench/scopeio_e/video_b/layout_b/mainlayout_e/y_edges
add wave -noupdate /testbench/scopeio_e/video_b/layout_b/mainlayout_e/video_clk
add wave -noupdate /testbench/scopeio_e/video_b/layout_b/mainlayout_e/video_yon
add wave -noupdate -radix unsigned /testbench/scopeio_e/video_b/layout_b/mainlayout_e/video_x
add wave -noupdate -radix unsigned /testbench/scopeio_e/video_b/layout_b/mainlayout_e/video_y
add wave -noupdate /testbench/scopeio_e/video_b/layout_b/mainlayout_e/x_edge
add wave -noupdate /testbench/scopeio_e/video_b/layout_b/mainlayout_e/video_xon
add wave -noupdate /testbench/scopeio_e/video_b/layout_b/mainlayout_e/x_div
add wave -noupdate /testbench/scopeio_e/video_b/layout_b/mainlayout_e/box_eox
add wave -noupdate /testbench/scopeio_e/video_b/layout_b/mainlayout_e/y_edge
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/scopeio_e/video_b/layout_b/mainbox_eox
add wave -noupdate /testbench/scopeio_e/video_b/layout_b/mainbox_b/videobox_b/videobox_e/video_xon
add wave -noupdate /testbench/scopeio_e/video_b/layout_b/mainbox_b/videobox_b/videobox_e/video_yon
add wave -noupdate /testbench/scopeio_e/video_b/layout_b/mainbox_b/videobox_b/videobox_e/video_eox
add wave -noupdate /testbench/scopeio_e/video_b/layout_b/mainbox_b/videobox_b/videobox_e/box_xedge
add wave -noupdate /testbench/scopeio_e/video_b/layout_b/mainbox_b/videobox_b/videobox_e/box_yedge
add wave -noupdate /testbench/scopeio_e/video_b/layout_b/mainbox_b/videobox_b/videobox_e/box_x
add wave -noupdate /testbench/scopeio_e/video_b/layout_b/mainbox_b/videobox_b/videobox_e/box_y
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {498136 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 285
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
WaveRestoreZoom {0 ns} {525 us}
