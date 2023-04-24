onerror {resume}
quietly virtual signal -install /testbench/du_e/graphics_e/adapter_b/dvi_b/xx_e { /testbench/du_e/graphics_e/adapter_b/dvi_b/xx_e/line__45/q_m(8 downto 0)} qm8to0
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group uart /testbench/du_e/ftdi_txd
add wave -noupdate -expand -group uart /testbench/du_e/ftdi_rxd
add wave -noupdate -expand -group uart /testbench/du_e/ftdi_txd
add wave -noupdate -expand -group uart /testbench/du_e/ftdi_rxd
add wave -noupdate -expand -group sdram /testbench/du_e/sdram_clk
add wave -noupdate -expand -group sdram /testbench/du_e/sdram_cke
add wave -noupdate -expand -group sdram /testbench/du_e/sdram_csn
add wave -noupdate -expand -group sdram /testbench/du_e/sdram_rasn
add wave -noupdate -expand -group sdram /testbench/du_e/sdram_casn
add wave -noupdate -expand -group sdram /testbench/du_e/sdram_wen
add wave -noupdate -expand -group sdram -radix hexadecimal /testbench/du_e/sdram_a
add wave -noupdate -expand -group sdram /testbench/du_e/sdram_ba
add wave -noupdate -expand -group sdram -expand /testbench/du_e/sdram_dqm
add wave -noupdate -expand -group sdram -radix hexadecimal -childformat {{/testbench/du_e/sdram_d(15) -radix hexadecimal} {/testbench/du_e/sdram_d(14) -radix hexadecimal} {/testbench/du_e/sdram_d(13) -radix hexadecimal} {/testbench/du_e/sdram_d(12) -radix hexadecimal} {/testbench/du_e/sdram_d(11) -radix hexadecimal} {/testbench/du_e/sdram_d(10) -radix hexadecimal} {/testbench/du_e/sdram_d(9) -radix hexadecimal} {/testbench/du_e/sdram_d(8) -radix hexadecimal} {/testbench/du_e/sdram_d(7) -radix hexadecimal} {/testbench/du_e/sdram_d(6) -radix hexadecimal} {/testbench/du_e/sdram_d(5) -radix hexadecimal} {/testbench/du_e/sdram_d(4) -radix hexadecimal} {/testbench/du_e/sdram_d(3) -radix hexadecimal} {/testbench/du_e/sdram_d(2) -radix hexadecimal} {/testbench/du_e/sdram_d(1) -radix hexadecimal} {/testbench/du_e/sdram_d(0) -radix hexadecimal}} -subitemconfig {/testbench/du_e/sdram_d(15) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_d(14) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_d(13) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_d(12) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_d(11) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_d(10) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_d(9) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_d(8) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_d(7) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_d(6) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_d(5) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_d(4) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_d(3) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_d(2) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_d(1) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_d(0) {-height 29 -radix hexadecimal}} /testbench/du_e/sdram_d
add wave -noupdate -expand -group sdram /testbench/du_e/sdram_clk
add wave -noupdate -expand -group sdram /testbench/du_e/sdram_cke
add wave -noupdate -expand -group sdram /testbench/du_e/sdram_csn
add wave -noupdate -expand -group sdram /testbench/du_e/sdram_rasn
add wave -noupdate -expand -group sdram /testbench/du_e/sdram_casn
add wave -noupdate -expand -group sdram /testbench/du_e/sdram_wen
add wave -noupdate -expand -group sdram -radix hexadecimal /testbench/du_e/sdram_a
add wave -noupdate -expand -group sdram /testbench/du_e/sdram_ba
add wave -noupdate -expand -group sdram -expand /testbench/du_e/sdram_dqm
add wave -noupdate -expand -group sdram -radix hexadecimal -childformat {{/testbench/du_e/sdram_d(15) -radix hexadecimal} {/testbench/du_e/sdram_d(14) -radix hexadecimal} {/testbench/du_e/sdram_d(13) -radix hexadecimal} {/testbench/du_e/sdram_d(12) -radix hexadecimal} {/testbench/du_e/sdram_d(11) -radix hexadecimal} {/testbench/du_e/sdram_d(10) -radix hexadecimal} {/testbench/du_e/sdram_d(9) -radix hexadecimal} {/testbench/du_e/sdram_d(8) -radix hexadecimal} {/testbench/du_e/sdram_d(7) -radix hexadecimal} {/testbench/du_e/sdram_d(6) -radix hexadecimal} {/testbench/du_e/sdram_d(5) -radix hexadecimal} {/testbench/du_e/sdram_d(4) -radix hexadecimal} {/testbench/du_e/sdram_d(3) -radix hexadecimal} {/testbench/du_e/sdram_d(2) -radix hexadecimal} {/testbench/du_e/sdram_d(1) -radix hexadecimal} {/testbench/du_e/sdram_d(0) -radix hexadecimal}} -subitemconfig {/testbench/du_e/sdram_d(15) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_d(14) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_d(13) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_d(12) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_d(11) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_d(10) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_d(9) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_d(8) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_d(7) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_d(6) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_d(5) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_d(4) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_d(3) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_d(2) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_d(1) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_d(0) {-height 29 -radix hexadecimal}} /testbench/du_e/sdram_d
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix hexadecimal /testbench/hdlc_b/uartrx_e/debug_rxd
add wave -noupdate /testbench/hdlc_b/uartrx_e/debug_rxdv
add wave -noupdate -divider {New Divider}
add wave -noupdate -group graphics_e -radix hexadecimal /testbench/du_e/graphics_e/ctlrphy_dqi
add wave -noupdate -group graphics_e -expand /testbench/du_e/graphics_e/ctlrphy_sto
add wave -noupdate -group graphics_e -expand /testbench/du_e/graphics_e/ctlrphy_sti
add wave -noupdate -group graphics_e -radix hexadecimal /testbench/du_e/graphics_e/ctlrphy_dqi
add wave -noupdate -group graphics_e /testbench/du_e/graphics_e/dma_do
add wave -noupdate -group graphics_e /testbench/du_e/graphics_e/dma_do_dv
add wave -noupdate -group graphics_e -radix hexadecimal /testbench/du_e/graphics_e/ctlrphy_dqi
add wave -noupdate -group graphics_e -expand /testbench/du_e/graphics_e/ctlrphy_sto
add wave -noupdate -group graphics_e -expand /testbench/du_e/graphics_e/ctlrphy_sti
add wave -noupdate -group graphics_e -radix hexadecimal /testbench/du_e/graphics_e/ctlrphy_dqi
add wave -noupdate -group graphics_e /testbench/du_e/graphics_e/dma_do
add wave -noupdate -group graphics_e /testbench/du_e/graphics_e/dma_do_dv
add wave -noupdate -divider {New Divider}
add wave -noupdate -expand -group sdrphy_e /testbench/du_e/sdrphy_e/sclk
add wave -noupdate -expand -group sdrphy_e /testbench/du_e/sdrphy_e/sys_sti
add wave -noupdate -expand -group sdrphy_e /testbench/du_e/sdrphy_e/sys_sto
add wave -noupdate -expand -group sdrphy_e -radix hexadecimal /testbench/du_e/sdrphy_e/sys_dqo
add wave -noupdate -expand -group sdrphy_e /testbench/du_e/sdrphy_e/sclk
add wave -noupdate -expand -group sdrphy_e /testbench/du_e/sdrphy_e/sys_sti
add wave -noupdate -expand -group sdrphy_e /testbench/du_e/sdrphy_e/sys_sto
add wave -noupdate -expand -group sdrphy_e -radix hexadecimal /testbench/du_e/sdrphy_e/sys_dqo
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/graphics_e/video_clk
add wave -noupdate /testbench/du_e/graphics_e/video_shift_clk
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/graphics_e/adapter_b/dvi_b/vga2dvid_e/u21/clk
add wave -noupdate /testbench/du_e/graphics_e/adapter_b/dvi_b/xx_e/data
add wave -noupdate /testbench/du_e/graphics_e/adapter_b/dvi_b/vga2dvid_e/u21/data
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/graphics_e/adapter_b/dvi_b/vga2dvid_e/u21/ones
add wave -noupdate /testbench/du_e/graphics_e/adapter_b/dvi_b/vga2dvid_e/u21/data_word_disparity
add wave -noupdate /testbench/du_e/graphics_e/adapter_b/dvi_b/xx_e/line__45/n10
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/graphics_e/adapter_b/dvi_b/vga2dvid_e/u21/data_word
add wave -noupdate /testbench/du_e/graphics_e/adapter_b/dvi_b/xx_e/qm8to0
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/graphics_e/adapter_b/dvi_b/vga2dvid_e/u21/encoded
add wave -noupdate /testbench/du_e/graphics_e/adapter_b/dvi_b/xx_e/encoded
add wave -noupdate /testbench/du_e/graphics_e/adapter_b/dvi_b/xx1_e/dvisubpxl_e/chn0to2_g(2)/tmds_encoder_e/encoded
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/graphics_e/adapter_b/dvi_b/vga2dvid_e/u21/dc_bias
add wave -noupdate /testbench/du_e/graphics_e/adapter_b/dvi_b/xx_e/line__45/cnt
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/graphics_e/adapter_b/dvi_b/xx1_e/chn2
add wave -noupdate /testbench/du_e/graphics_e/adapter_b/dvi_b/vga2dvid_e/out_red
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/graphics_e/adapter_b/dvi_b/vga2dvid_e/latched_red
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix hexadecimal /testbench/hdlc_b/uartrx_e/debug_rxd
add wave -noupdate /testbench/hdlc_b/uartrx_e/debug_rxdv
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/graphics_e/video_clk
add wave -noupdate /testbench/du_e/graphics_e/video_shift_clk
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/graphics_e/adapter_b/dvi_b/vga2dvid_e/u21/clk
add wave -noupdate /testbench/du_e/graphics_e/adapter_b/dvi_b/xx_e/data
add wave -noupdate /testbench/du_e/graphics_e/adapter_b/dvi_b/vga2dvid_e/u21/data
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/graphics_e/adapter_b/dvi_b/vga2dvid_e/u21/ones
add wave -noupdate /testbench/du_e/graphics_e/adapter_b/dvi_b/vga2dvid_e/u21/data_word_disparity
add wave -noupdate /testbench/du_e/graphics_e/adapter_b/dvi_b/xx_e/line__45/n10
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/graphics_e/adapter_b/dvi_b/vga2dvid_e/u21/data_word
add wave -noupdate /testbench/du_e/graphics_e/adapter_b/dvi_b/xx_e/qm8to0
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/graphics_e/adapter_b/dvi_b/vga2dvid_e/u21/encoded
add wave -noupdate /testbench/du_e/graphics_e/adapter_b/dvi_b/xx_e/encoded
add wave -noupdate /testbench/du_e/graphics_e/adapter_b/dvi_b/xx1_e/dvisubpxl_e/chn0to2_g(2)/tmds_encoder_e/encoded
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/graphics_e/adapter_b/dvi_b/vga2dvid_e/u21/dc_bias
add wave -noupdate /testbench/du_e/graphics_e/adapter_b/dvi_b/xx_e/line__45/cnt
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/graphics_e/adapter_b/dvi_b/xx1_e/serlzr_g(2)/serlzr_e/src_data
add wave -noupdate /testbench/du_e/graphics_e/adapter_b/dvi_b/xx1_e/serlzr_g(2)/serlzr_e/dst_data
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {19063882068 fs} 0} {{Cursor 2} {19077327190 fs} 0} {{Cursor 3} {19090655904 fs} 0} {{Cursor 4} {19104101025 fs} 0}
quietly wave cursor active 1
configure wave -namecolwidth 271
configure wave -valuecolwidth 256
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
WaveRestoreZoom {19035187500 fs} {19113937500 fs}
