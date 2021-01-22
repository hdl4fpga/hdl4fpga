onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /testbench/du_e/uartrx_e/debug_rxd
add wave -noupdate /testbench/du_e/uartrx_e/debug_rxdv
add wave -noupdate -radix hexadecimal /testbench/du_e/uarttx_e/debug_txd
add wave -noupdate -radix hexadecimal /testbench/du_e/uarttx_e/debug_txen
add wave -noupdate /testbench/du_e/sdram_clk
add wave -noupdate /testbench/du_e/sdram_rasn
add wave -noupdate /testbench/du_e/sdram_casn
add wave -noupdate /testbench/du_e/sdram_wen
add wave -noupdate -radix hexadecimal /testbench/du_e/sdram_ba
add wave -noupdate -radix hexadecimal -childformat {{/testbench/du_e/sdram_a(12) -radix hexadecimal} {/testbench/du_e/sdram_a(11) -radix hexadecimal} {/testbench/du_e/sdram_a(10) -radix hexadecimal} {/testbench/du_e/sdram_a(9) -radix hexadecimal} {/testbench/du_e/sdram_a(8) -radix hexadecimal} {/testbench/du_e/sdram_a(7) -radix hexadecimal} {/testbench/du_e/sdram_a(6) -radix hexadecimal} {/testbench/du_e/sdram_a(5) -radix hexadecimal} {/testbench/du_e/sdram_a(4) -radix hexadecimal} {/testbench/du_e/sdram_a(3) -radix hexadecimal} {/testbench/du_e/sdram_a(2) -radix hexadecimal} {/testbench/du_e/sdram_a(1) -radix hexadecimal} {/testbench/du_e/sdram_a(0) -radix hexadecimal}} -subitemconfig {/testbench/du_e/sdram_a(12) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(11) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(10) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(9) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(8) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(7) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(6) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(5) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(4) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(3) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(2) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(1) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(0) {-height 29 -radix hexadecimal}} /testbench/du_e/sdram_a
add wave -noupdate -radix hexadecimal /testbench/du_e/sdram_d
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/grahics_e/sio_b/dmaio_trdy
add wave -noupdate /testbench/du_e/grahics_e/sio_b/dmaio_next
add wave -noupdate /testbench/du_e/grahics_e/dmaio_we
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/dmaio_len
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/dmaio_addr
add wave -noupdate /testbench/du_e/grahics_e/dmaio_req
add wave -noupdate /testbench/du_e/grahics_e/dmaio_rdy
add wave -noupdate /testbench/du_e/grahics_e/sio_b/dmasin_irdy
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/graphics_e/vram_e/src_clk
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/grahics_e/sio_b/sodata_b/ctlrio_irdy
add wave -noupdate -divider {New Divider}
add wave -noupdate -expand /testbench/du_e/grahics_e/dev_gnt
add wave -noupdate -expand /testbench/du_e/grahics_e/ctlr_do_dv
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/hzsync
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/vtsync
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/video_vton
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/video_hzon
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_e/ctlr_clk
add wave -noupdate -color Cyan /testbench/du_e/grahics_e/dev_gnt(0)
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/pp
add wave -noupdate /testbench/du_e/grahics_e/ctlr_do_dv(0)
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/graphics_e/vram_e/src_clk
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/graphics_e/video_frm
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/adapter_b/graphics_e/vram_e/wr_cntr
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/adapter_b/graphics_e/vram_e/async_b/wr_cpy
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/adapter_b/graphics_e/vram_e/wr_cmp
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/adapter_b/graphics_e/vram_e/rd_cntr
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/adapter_b/graphics_e/vram_e/async_b/rd_cpy
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/adapter_b/graphics_e/vram_e/rd_cmp
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/graphics_e/vram_e/dst_irdy
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/graphics_e/vram_e/dst_trdy
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/graphics_e/video_clk
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/graphics_e/video_hzon
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/graphics_e/video_vton
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/adapter_b/graphics_e/level
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/graphics_e/video_frm
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/graphics_e/hz_req
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/graphics_e/vt_req
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_e/dev_gnt(0)
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/pp
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/ppp
add wave -noupdate /testbench/du_e/grahics_e/ctlr_do_dv(0)
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/ctlrvideo_irdy
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/graphics_e/trans_rdy
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/graphics_e/trans_req
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/graphics_e/dmacfg_clk
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/graphics_e/dmacfg_req
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/graphics_e/dmacfg_rdy
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/graphics_e/dma_req
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/graphics_e/dma_rdy
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {839793750000 fs} 1} {{Cursor 2} {839659764500 fs} 0}
quietly wave cursor active 2
configure wave -namecolwidth 259
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
configure wave -timelineunits us
update
WaveRestoreZoom {839281054680 fs} {840306445320 fs}
