onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/scopeio_e/video_b/video_e/video_clk
add wave -noupdate /testbench/scopeio_e/video_b/video_e/video_hzsync
add wave -noupdate /testbench/scopeio_e/video_b/video_e/video_vtsync
add wave -noupdate -radix unsigned /testbench/scopeio_e/video_b/video_e/video_hzcntr
add wave -noupdate -radix unsigned /testbench/scopeio_e/video_b/video_e/video_vtcntr
add wave -noupdate /testbench/scopeio_e/video_b/video_e/video_hzon
add wave -noupdate -radix hexadecimal /testbench/scopeio_e/video_b/video_e/video_vton
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix unsigned /testbench/scopeio_e/video_b/layout_b/mainbox_b/scopeio_segment_e/x
add wave -noupdate -radix unsigned /testbench/scopeio_e/video_b/layout_b/mainbox_b/scopeio_segment_e/y
add wave -noupdate /testbench/scopeio_e/video_b/layout_b/mainbox_b/hz_on
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/scopeio_e/video_b/vt_bgon
add wave -noupdate /testbench/scopeio_e/video_b/grid_bgon
add wave -noupdate /testbench/scopeio_e/video_b/hz_bgon
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/scopeio_e/video_hsync
add wave -noupdate /testbench/scopeio_e/video_vsync
add wave -noupdate /testbench/scopeio_e/video_blank
add wave -noupdate /testbench/scopeio_e/video_sync
add wave -noupdate /testbench/scopeio_e/video_color
add wave -noupdate -radix unsigned /testbench/scopeio_e/video_b/layout_b/mainbox_b/sgmntbox_b/xdiv
add wave -noupdate -radix unsigned -childformat {{/testbench/scopeio_e/video_b/layout_b/mainbox_b/sgmntbox_b/ydiv(0) -radix unsigned} {/testbench/scopeio_e/video_b/layout_b/mainbox_b/sgmntbox_b/ydiv(1) -radix unsigned} {/testbench/scopeio_e/video_b/layout_b/mainbox_b/sgmntbox_b/ydiv(2) -radix unsigned}} -subitemconfig {/testbench/scopeio_e/video_b/layout_b/mainbox_b/sgmntbox_b/ydiv(0) {-height 16 -radix unsigned} /testbench/scopeio_e/video_b/layout_b/mainbox_b/sgmntbox_b/ydiv(1) {-height 16 -radix unsigned} /testbench/scopeio_e/video_b/layout_b/mainbox_b/sgmntbox_b/ydiv(2) {-height 16 -radix unsigned}} /testbench/scopeio_e/video_b/layout_b/mainbox_b/sgmntbox_b/ydiv
add wave -noupdate /testbench/scopeio_e/video_b/layout_b/mainbox_b/sgmntbox_b/box_on
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/scopeio_e/video_b/layout_b/mainbox_b/sgmntbox_vxon
add wave -noupdate /testbench/scopeio_e/video_b/layout_b/mainbox_b/sgmntbox_vyon
add wave -noupdate /testbench/scopeio_e/video_b/layout_b/mainbox_b/sgmntbox_b/xon
add wave -noupdate /testbench/scopeio_e/video_b/layout_b/mainbox_b/sgmntbox_b/yon
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/scopeio_e/video_b/layout_b/mainbox_yon
add wave -noupdate /testbench/scopeio_e/video_b/layout_b/mainbox_xon
add wave -noupdate /testbench/scopeio_e/video_b/sgmntbox_on
add wave -noupdate /testbench/scopeio_e/video_b/layout_b/mainbox_b/box_b/xon
add wave -noupdate /testbench/scopeio_e/video_b/layout_b/mainbox_b/sgmntbox_b/yon
add wave -noupdate /testbench/scopeio_e/video_b/layout_b/mainbox_b/sgmntbox_xon
add wave -noupdate /testbench/scopeio_e/video_b/layout_b/mainbox_b/box_b/nexty
add wave -noupdate /testbench/scopeio_e/video_b/layout_b/mainbox_b/sgmntbox_yon
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {980025 ns} 0} {{Cursor 2} {629616 ns} 0}
quietly wave cursor active 2
configure wave -namecolwidth 174
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
WaveRestoreZoom {0 ns} {1050 us}
