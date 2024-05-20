onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {New Divider}
add wave -noupdate -expand -group mii_rx -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix ascii /testbench/du_e/scopeio_e/scopeio_video_e/textbox_g/scopeio_texbox_e/cgaram_e/cga_bitrom
add wave -noupdate /testbench/du_e/scopeio_e/scopeio_video_e/textbox_g/scopeio_texbox_e/cgaram_e/video_clk
add wave -noupdate /testbench/du_e/scopeio_e/scopeio_video_e/textbox_g/scopeio_texbox_e/cgaram_e/video_on
add wave -noupdate -radix hexadecimal /testbench/du_e/scopeio_e/scopeio_video_e/textbox_g/scopeio_texbox_e/cgaram_e/video_addr
add wave -noupdate /testbench/du_e/scopeio_e/scopeio_video_e/textbox_g/scopeio_texbox_e/cgaram_e/font_vcntr
add wave -noupdate -radix hexadecimal /testbench/du_e/scopeio_e/scopeio_video_e/textbox_g/scopeio_texbox_e/cgaram_e/font_hcntr
add wave -noupdate /testbench/du_e/scopeio_e/scopeio_video_e/textbox_g/scopeio_texbox_e/text_on
add wave -noupdate -expand /testbench/du_e/scopeio_e/scopeio_video_e/textbox_g/scopeio_texbox_e/sgmntbox_ena
add wave -noupdate -radix hexadecimal /testbench/du_e/scopeio_e/scopeio_video_e/textbox_g/scopeio_texbox_e/video_hcntr
add wave -noupdate -radix hexadecimal /testbench/du_e/scopeio_e/scopeio_video_e/textbox_g/scopeio_texbox_e/video_vcntr
add wave -noupdate /testbench/du_e/scopeio_e/scopeio_video_e/scopeio_layout_e/textbox_x
add wave -noupdate /testbench/du_e/scopeio_e/scopeio_video_e/scopeio_layout_e/textbox_y
add wave -noupdate -radix hexadecimal /testbench/du_e/scopeio_e/scopeio_video_e/scopeio_layout_e/mainbox_b/sgmntbox_b/sgmntbox_x
add wave -noupdate -radix hexadecimal /testbench/du_e/scopeio_e/scopeio_video_e/scopeio_layout_e/mainbox_b/sgmntbox_b/sgmntbox_y
add wave -noupdate /testbench/du_e/scopeio_e/scopeio_video_e/scopeio_layout_e/mainbox_b/sgmntbox_b/box_e/video_xon
add wave -noupdate /testbench/du_e/scopeio_e/scopeio_video_e/scopeio_layout_e/mainbox_b/sgmntbox_b/box_e/video_yon
add wave -noupdate /testbench/du_e/scopeio_e/scopeio_video_e/scopeio_layout_e/mainbox_b/sgmntbox_b/box_e/video_eox
add wave -noupdate /testbench/du_e/scopeio_e/scopeio_video_e/scopeio_layout_e/mainbox_b/sgmntbox_b/box_e/box_xedge
add wave -noupdate /testbench/du_e/scopeio_e/scopeio_video_e/scopeio_layout_e/mainbox_b/sgmntbox_b/box_e/box_yedge
add wave -noupdate -radix hexadecimal /testbench/du_e/scopeio_e/scopeio_video_e/scopeio_layout_e/mainbox_b/sgmntbox_b/box_e/box_x
add wave -noupdate -radix hexadecimal /testbench/du_e/scopeio_e/scopeio_video_e/scopeio_layout_e/mainbox_b/sgmntbox_b/box_e/box_y
add wave -noupdate -radix hexadecimal /testbench/du_e/scopeio_e/scopeio_video_e/scopeio_layout_e/mainbox_b/sgmntbox_b/box_e/line__335/x
add wave -noupdate -radix hexadecimal /testbench/du_e/scopeio_e/scopeio_video_e/scopeio_layout_e/mainbox_b/sgmntbox_b/box_e/line__335/y
add wave -noupdate /testbench/du_e/scopeio_e/scopeio_video_e/scopeio_layout_e/mainbox_xedge
add wave -noupdate /testbench/du_e/scopeio_e/scopeio_video_e/scopeio_layout_e/mainbox_b/sgmntbox_xedge
add wave -noupdate -radix ascii /testbench/du_e/scopeio_e/scopeio_video_e/textbox_g/scopeio_texbox_e/cgaram_e/cga_code
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {114185192000 fs} 1} {{Cursor 4} {114208330000 fs} 0}
quietly wave cursor active 2
configure wave -namecolwidth 254
configure wave -valuecolwidth 119
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
WaveRestoreZoom {0 fs} {168 us}
