onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/du_e/clk_25mhz
add wave -noupdate /testbench/du_e/ftdi_rxd
add wave -noupdate /testbench/du_e/ftdi_txd
add wave -noupdate /testbench/du_e/sdram_rasn
add wave -noupdate /testbench/du_e/sdram_clk
add wave -noupdate /testbench/du_e/sdram_casn
add wave -noupdate /testbench/du_e/sdram_wen
add wave -noupdate -radix hexadecimal /testbench/du_e/sdram_ba
add wave -noupdate -radix hexadecimal -childformat {{/testbench/du_e/sdram_a(12) -radix hexadecimal} {/testbench/du_e/sdram_a(11) -radix hexadecimal} {/testbench/du_e/sdram_a(10) -radix hexadecimal} {/testbench/du_e/sdram_a(9) -radix hexadecimal} {/testbench/du_e/sdram_a(8) -radix hexadecimal} {/testbench/du_e/sdram_a(7) -radix hexadecimal} {/testbench/du_e/sdram_a(6) -radix hexadecimal} {/testbench/du_e/sdram_a(5) -radix hexadecimal} {/testbench/du_e/sdram_a(4) -radix hexadecimal} {/testbench/du_e/sdram_a(3) -radix hexadecimal} {/testbench/du_e/sdram_a(2) -radix hexadecimal} {/testbench/du_e/sdram_a(1) -radix hexadecimal} {/testbench/du_e/sdram_a(0) -radix hexadecimal}} -subitemconfig {/testbench/du_e/sdram_a(12) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(11) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(10) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(9) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(8) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(7) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(6) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(5) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(4) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(3) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(2) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(1) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(0) {-height 29 -radix hexadecimal}} /testbench/du_e/sdram_a
add wave -noupdate -radix hexadecimal /testbench/du_e/sdram_d
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/grahics_e/dmaio_we
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/dmaio_len
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/dmaio_addr
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix hexadecimal /testbench/hdlc_b/uarttx_e/debug_txen
add wave -noupdate -radix hexadecimal /testbench/hdlc_b/uarttx_e/debug_txd
add wave -noupdate -radix hexadecimal /testbench/du_e/hdlc_g/uartrx_e/debug_rxdv
add wave -noupdate -radix hexadecimal /testbench/du_e/hdlc_g/uartrx_e/debug_rxd
add wave -noupdate -radix hexadecimal /testbench/du_e/hdlc_g/uarttx_e/debug_txen
add wave -noupdate -radix hexadecimal /testbench/du_e/hdlc_g/uarttx_e/debug_txd
add wave -noupdate -radix hexadecimal /testbench/hdlc_b/uartrx_e/debug_rxd
add wave -noupdate -radix hexadecimal /testbench/hdlc_b/uartrx_e/debug_rxdv
add wave -noupdate /testbench/hdlc_b/hdlcfcsrx_sb
add wave -noupdate /testbench/hdlc_b/hdlcfcsrx_vld
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_e/devcfg_req
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_e/devcfg_rdy
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/sync_e/video_clk
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/sync_e/video_hzsync
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/sync_e/video_vtsync
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/graphics_e/serdes_e/serdes_clk
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/graphics_e/serdes_e/serdes_frm
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/graphics_e/serdes_e/ser_trdy
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/adapter_b/graphics_e/serdes_e/ser_data
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/graphics_e/serdes_e/des_frm
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/graphics_e/serdes_e/des_irdy
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/graphics_e/serdes_e/ser_irdy
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/graphics_e/serdes_e/des_trdy
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/adapter_b/graphics_e/serdes_e/des_data
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/adapter_b/graphics_e/vram_data
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/graphics_e/video_on
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/adapter_b/graphics_e/video_pixel
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/graphics_e/vt_req
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/adapter_b/graphics_e/dma_len
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/adapter_b/graphics_e/dma_addr
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/adapter_b/graphics_e/dma_step
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/graphics_e/vram_e/src_irdy
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/graphics_e/vram_e/src_trdy
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/graphics_e/level
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/graphics_e/video_frm
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/adapter_b/graphics_e/vram_e/wr_ptr
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/adapter_b/graphics_e/vram_e/rd_cntr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {104972644150 fs} 0} {{Cursor 2} {30539315663370 fs} 0}
quietly wave cursor active 2
configure wave -namecolwidth 259
configure wave -valuecolwidth 166
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
WaveRestoreZoom {0 fs} {32550 us}
