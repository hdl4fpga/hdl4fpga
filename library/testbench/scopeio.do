onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/du/scopeio_e/video_clk
add wave -noupdate /testbench/du/scopeio_e/video_b/graphics_b/sgmnt_b/parent_e/video_clk
add wave -noupdate /testbench/du/scopeio_e/video_b/graphics_b/sgmnt_b/parent_e/win_ena
add wave -noupdate -radix unsigned /testbench/du/scopeio_e/video_b/video_e/hcntr
add wave -noupdate -radix unsigned /testbench/du/scopeio_e/video_b/video_e/vcntr
add wave -noupdate /testbench/du/scopeio_e/video_b/video_e/vsync
add wave -noupdate /testbench/du/scopeio_e/video_b/video_e/hsync
add wave -noupdate /testbench/du/scopeio_e/video_b/video_e/don
add wave -noupdate /testbench/du/scopeio_e/video_b/graphics_b/sgmnt_b/pwin_x
add wave -noupdate /testbench/du/scopeio_e/video_b/graphics_b/sgmnt_b/pwin_y
add wave -noupdate /testbench/du/scopeio_e/video_b/graphics_b/sgmnt_b/pfrm
add wave -noupdate /testbench/du/scopeio_e/video_b/graphics_b/sgmnt_b/phon
add wave -noupdate /testbench/du/scopeio_e/video_b/graphics_b/sgmnt_b/cdon
add wave -noupdate /testbench/du/scopeio_e/video_b/graphics_b/sgmnt_b/cfrm
add wave -noupdate /testbench/du/scopeio_e/video_b/graphics_b/sgmnt_b/wena
add wave -noupdate /testbench/du/scopeio_e/video_b/graphics_b/sgmnt_b/wfrm
add wave -noupdate /testbench/du/scopeio_e/video_b/graphics_b/sgmnt_b/x
add wave -noupdate -radix unsigned /testbench/du/scopeio_e/video_b/graphics_b/sgmnt_b/win_y
add wave -noupdate -radix unsigned /testbench/du/scopeio_e/video_b/graphics_b/sgmnt_b/win_x
add wave -noupdate /testbench/du/scopeio_e/win_don
add wave -noupdate /testbench/du/scopeio_e/win_frm
add wave -noupdate /testbench/du/scopeio_e/video_b/graphics_b/sgmnt_b/scopeio_segment_e/win_frm
add wave -noupdate /testbench/du/scopeio_e/video_b/graphics_b/sgmnt_b/scopeio_segment_e/win_on
add wave -noupdate /testbench/du/scopeio_e/video_b/graphics_b/sgmnt_b/scopeio_segment_e/win_x
add wave -noupdate /testbench/du/scopeio_e/video_b/graphics_b/sgmnt_b/scopeio_segment_e/win_y
add wave -noupdate /testbench/du/scopeio_e/video_b/graphics_b/sgmnt_b/scopeio_segment_e/grid_on
add wave -noupdate /testbench/du/scopeio_e/video_b/graphics_b/sgmnt_b/scopeio_segment_e/grid_dot
add wave -noupdate /testbench/du/scopeio_e/video_b/scopeio_palette_e/video_rgb
add wave -noupdate /testbench/du/scopeio_e/video_pixel
add wave -noupdate /testbench/du/scopeio_e/video_rgb
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {839656665 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
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
WaveRestoreZoom {839246505 ps} {840066825 ps}
