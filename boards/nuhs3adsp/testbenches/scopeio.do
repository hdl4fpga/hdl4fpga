onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {New Divider}
add wave -noupdate -expand -group mii_rx /testbench/du_e/mii_rxc
add wave -noupdate -expand -group mii_rx /testbench/du_e/mii_rxdv
add wave -noupdate -expand -group mii_rx -radix hexadecimal /testbench/du_e/mii_rxd
add wave -noupdate -expand -group mii_rx /testbench/du_e/mii_txc
add wave -noupdate -expand -group mii_rx /testbench/du_e/mii_txen
add wave -noupdate -expand -group mii_rx -radix hexadecimal -childformat {{/testbench/du_e/mii_txd(0) -radix hexadecimal} {/testbench/du_e/mii_txd(1) -radix hexadecimal} {/testbench/du_e/mii_txd(2) -radix hexadecimal} {/testbench/du_e/mii_txd(3) -radix hexadecimal}} -subitemconfig {/testbench/du_e/mii_txd(0) {-height 29 -radix hexadecimal} /testbench/du_e/mii_txd(1) {-height 29 -radix hexadecimal} /testbench/du_e/mii_txd(2) {-height 29 -radix hexadecimal} /testbench/du_e/mii_txd(3) {-height 29 -radix hexadecimal}} /testbench/du_e/mii_txd
add wave -noupdate -expand -group mii_rx -divider {New Divider}
add wave -noupdate -group ddr /testbench/du_e/ddr_ckp
add wave -noupdate -group ddr /testbench/du_e/ddr_cs
add wave -noupdate -group ddr /testbench/du_e/ddr_cke
add wave -noupdate -group ddr /testbench/du_e/ddr_ras
add wave -noupdate -group ddr /testbench/du_e/ddr_cas
add wave -noupdate -group ddr /testbench/du_e/ddr_we
add wave -noupdate -group ddr -radix hexadecimal /testbench/du_e/ddr_ba
add wave -noupdate -group ddr -radix hexadecimal -childformat {{/testbench/du_e/ddr_a(12) -radix hexadecimal} {/testbench/du_e/ddr_a(11) -radix hexadecimal} {/testbench/du_e/ddr_a(10) -radix hexadecimal} {/testbench/du_e/ddr_a(9) -radix hexadecimal} {/testbench/du_e/ddr_a(8) -radix hexadecimal} {/testbench/du_e/ddr_a(7) -radix hexadecimal} {/testbench/du_e/ddr_a(6) -radix hexadecimal} {/testbench/du_e/ddr_a(5) -radix hexadecimal} {/testbench/du_e/ddr_a(4) -radix hexadecimal} {/testbench/du_e/ddr_a(3) -radix hexadecimal} {/testbench/du_e/ddr_a(2) -radix hexadecimal} {/testbench/du_e/ddr_a(1) -radix hexadecimal} {/testbench/du_e/ddr_a(0) -radix hexadecimal}} -subitemconfig {/testbench/du_e/ddr_a(12) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(11) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(10) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(9) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(8) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(7) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(6) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(5) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(4) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(3) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(2) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(1) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(0) {-height 29 -radix hexadecimal}} /testbench/du_e/ddr_a
add wave -noupdate -group ddr -expand /testbench/du_e/ddr_dqs
add wave -noupdate -group ddr -radix hexadecimal -childformat {{/testbench/du_e/ddr_dq(15) -radix hexadecimal} {/testbench/du_e/ddr_dq(14) -radix hexadecimal} {/testbench/du_e/ddr_dq(13) -radix hexadecimal} {/testbench/du_e/ddr_dq(12) -radix hexadecimal} {/testbench/du_e/ddr_dq(11) -radix hexadecimal} {/testbench/du_e/ddr_dq(10) -radix hexadecimal} {/testbench/du_e/ddr_dq(9) -radix hexadecimal} {/testbench/du_e/ddr_dq(8) -radix hexadecimal} {/testbench/du_e/ddr_dq(7) -radix hexadecimal} {/testbench/du_e/ddr_dq(6) -radix hexadecimal} {/testbench/du_e/ddr_dq(5) -radix hexadecimal} {/testbench/du_e/ddr_dq(4) -radix hexadecimal} {/testbench/du_e/ddr_dq(3) -radix hexadecimal} {/testbench/du_e/ddr_dq(2) -radix hexadecimal} {/testbench/du_e/ddr_dq(1) -radix hexadecimal} {/testbench/du_e/ddr_dq(0) -radix hexadecimal}} -subitemconfig {/testbench/du_e/ddr_dq(15) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_dq(14) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_dq(13) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_dq(12) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_dq(11) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_dq(10) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_dq(9) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_dq(8) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_dq(7) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_dq(6) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_dq(5) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_dq(4) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_dq(3) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_dq(2) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_dq(1) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_dq(0) {-height 29 -radix hexadecimal}} /testbench/du_e/ddr_dq
add wave -noupdate -group ddr -expand /testbench/du_e/ddr_dm
add wave -noupdate -group ddr /testbench/du_e/ddr_st_dqs
add wave -noupdate -group ddr /testbench/du_e/ddr_st_lp_dqs
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/scopeio_e/scopeio_video_e/textbox_g/scopeio_texbox_e/cgaram_e/video_clk
add wave -noupdate /testbench/du_e/scopeio_e/scopeio_video_e/textbox_g/scopeio_texbox_e/cgaram_e/video_on
add wave -noupdate -radix hexadecimal /testbench/du_e/scopeio_e/scopeio_video_e/textbox_g/scopeio_texbox_e/cgaram_e/video_addr
add wave -noupdate /testbench/du_e/scopeio_e/scopeio_video_e/textbox_g/scopeio_texbox_e/cgaram_e/font_vcntr
add wave -noupdate -radix hexadecimal /testbench/du_e/scopeio_e/scopeio_video_e/textbox_g/scopeio_texbox_e/cgaram_e/font_hcntr
add wave -noupdate /testbench/du_e/scopeio_e/scopeio_video_e/textbox_g/scopeio_texbox_e/text_on
add wave -noupdate /testbench/du_e/scopeio_e/scopeio_video_e/textbox_g/scopeio_texbox_e/textfg
add wave -noupdate /testbench/du_e/scopeio_e/scopeio_video_e/textbox_g/scopeio_texbox_e/textbg
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
add wave -noupdate /testbench/du_e/scopeio_e/scopeio_video_e/scopeio_layout_e/mainbox_b/sgmntbox_b/box_e/line__335/y
add wave -noupdate /testbench/du_e/scopeio_e/scopeio_video_e/scopeio_layout_e/mainbox_xedge
add wave -noupdate /testbench/du_e/scopeio_e/scopeio_video_e/scopeio_layout_e/mainbox_b/sgmntbox_xedge
add wave -noupdate -radix ascii /testbench/du_e/scopeio_e/scopeio_video_e/textbox_g/scopeio_texbox_e/cgaram_e/cga_code
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {114185192 ps} 1} {{Cursor 4} {114208330 ps} 0}
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
WaveRestoreZoom {114134496 ps} {114257544 ps}
