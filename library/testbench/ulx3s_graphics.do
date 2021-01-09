onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/du_e/sio_b/siodayahdlc_e/sioahdlc_e/uart_clk
add wave -noupdate /testbench/du_e/sio_b/uartrx_e/debug_rxdv
add wave -noupdate -radix hexadecimal /testbench/du_e/sio_b/uartrx_e/debug_rxd
add wave -noupdate /testbench/du_e/sio_b/uarttx_e/debug_txen
add wave -noupdate -radix hexadecimal /testbench/du_e/sio_b/uarttx_e/debug_txd
add wave -noupdate -radix hexadecimal /testbench/du_e/dmaio_len
add wave -noupdate -radix hexadecimal /testbench/du_e/dmaio_addr
add wave -noupdate /testbench/du_e/dev_we
add wave -noupdate /testbench/du_e/dmaio_trdy
add wave -noupdate /testbench/du_e/dmacfgio_req
add wave -noupdate /testbench/du_e/dmacfgio_rdy
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/dmaio_req
add wave -noupdate /testbench/du_e/dmaio_rdy
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/sio_b/dmalen_irdy
add wave -noupdate /testbench/du_e/sio_b/dmalen_trdy
add wave -noupdate -radix hexadecimal -childformat {{/testbench/du_e/adapter_b/graphics_e/dma_len(23) -radix hexadecimal} {/testbench/du_e/adapter_b/graphics_e/dma_len(22) -radix hexadecimal} {/testbench/du_e/adapter_b/graphics_e/dma_len(21) -radix hexadecimal} {/testbench/du_e/adapter_b/graphics_e/dma_len(20) -radix hexadecimal} {/testbench/du_e/adapter_b/graphics_e/dma_len(19) -radix hexadecimal} {/testbench/du_e/adapter_b/graphics_e/dma_len(18) -radix hexadecimal} {/testbench/du_e/adapter_b/graphics_e/dma_len(17) -radix hexadecimal} {/testbench/du_e/adapter_b/graphics_e/dma_len(16) -radix hexadecimal} {/testbench/du_e/adapter_b/graphics_e/dma_len(15) -radix hexadecimal} {/testbench/du_e/adapter_b/graphics_e/dma_len(14) -radix hexadecimal} {/testbench/du_e/adapter_b/graphics_e/dma_len(13) -radix hexadecimal} {/testbench/du_e/adapter_b/graphics_e/dma_len(12) -radix hexadecimal} {/testbench/du_e/adapter_b/graphics_e/dma_len(11) -radix hexadecimal} {/testbench/du_e/adapter_b/graphics_e/dma_len(10) -radix hexadecimal} {/testbench/du_e/adapter_b/graphics_e/dma_len(9) -radix hexadecimal} {/testbench/du_e/adapter_b/graphics_e/dma_len(8) -radix hexadecimal} {/testbench/du_e/adapter_b/graphics_e/dma_len(7) -radix hexadecimal} {/testbench/du_e/adapter_b/graphics_e/dma_len(6) -radix hexadecimal} {/testbench/du_e/adapter_b/graphics_e/dma_len(5) -radix hexadecimal} {/testbench/du_e/adapter_b/graphics_e/dma_len(4) -radix hexadecimal} {/testbench/du_e/adapter_b/graphics_e/dma_len(3) -radix hexadecimal} {/testbench/du_e/adapter_b/graphics_e/dma_len(2) -radix hexadecimal} {/testbench/du_e/adapter_b/graphics_e/dma_len(1) -radix hexadecimal} {/testbench/du_e/adapter_b/graphics_e/dma_len(0) -radix hexadecimal}} -subitemconfig {/testbench/du_e/adapter_b/graphics_e/dma_len(23) {-height 29 -radix hexadecimal} /testbench/du_e/adapter_b/graphics_e/dma_len(22) {-height 29 -radix hexadecimal} /testbench/du_e/adapter_b/graphics_e/dma_len(21) {-height 29 -radix hexadecimal} /testbench/du_e/adapter_b/graphics_e/dma_len(20) {-height 29 -radix hexadecimal} /testbench/du_e/adapter_b/graphics_e/dma_len(19) {-height 29 -radix hexadecimal} /testbench/du_e/adapter_b/graphics_e/dma_len(18) {-height 29 -radix hexadecimal} /testbench/du_e/adapter_b/graphics_e/dma_len(17) {-height 29 -radix hexadecimal} /testbench/du_e/adapter_b/graphics_e/dma_len(16) {-height 29 -radix hexadecimal} /testbench/du_e/adapter_b/graphics_e/dma_len(15) {-height 29 -radix hexadecimal} /testbench/du_e/adapter_b/graphics_e/dma_len(14) {-height 29 -radix hexadecimal} /testbench/du_e/adapter_b/graphics_e/dma_len(13) {-height 29 -radix hexadecimal} /testbench/du_e/adapter_b/graphics_e/dma_len(12) {-height 29 -radix hexadecimal} /testbench/du_e/adapter_b/graphics_e/dma_len(11) {-height 29 -radix hexadecimal} /testbench/du_e/adapter_b/graphics_e/dma_len(10) {-height 29 -radix hexadecimal} /testbench/du_e/adapter_b/graphics_e/dma_len(9) {-height 29 -radix hexadecimal} /testbench/du_e/adapter_b/graphics_e/dma_len(8) {-height 29 -radix hexadecimal} /testbench/du_e/adapter_b/graphics_e/dma_len(7) {-height 29 -radix hexadecimal} /testbench/du_e/adapter_b/graphics_e/dma_len(6) {-height 29 -radix hexadecimal} /testbench/du_e/adapter_b/graphics_e/dma_len(5) {-height 29 -radix hexadecimal} /testbench/du_e/adapter_b/graphics_e/dma_len(4) {-height 29 -radix hexadecimal} /testbench/du_e/adapter_b/graphics_e/dma_len(3) {-height 29 -radix hexadecimal} /testbench/du_e/adapter_b/graphics_e/dma_len(2) {-height 29 -radix hexadecimal} /testbench/du_e/adapter_b/graphics_e/dma_len(1) {-height 29 -radix hexadecimal} /testbench/du_e/adapter_b/graphics_e/dma_len(0) {-height 29 -radix hexadecimal}} /testbench/du_e/adapter_b/graphics_e/dma_len
add wave -noupdate -radix hexadecimal -childformat {{/testbench/du_e/adapter_b/graphics_e/dma_addr(23) -radix hexadecimal} {/testbench/du_e/adapter_b/graphics_e/dma_addr(22) -radix hexadecimal} {/testbench/du_e/adapter_b/graphics_e/dma_addr(21) -radix hexadecimal} {/testbench/du_e/adapter_b/graphics_e/dma_addr(20) -radix hexadecimal} {/testbench/du_e/adapter_b/graphics_e/dma_addr(19) -radix hexadecimal} {/testbench/du_e/adapter_b/graphics_e/dma_addr(18) -radix hexadecimal} {/testbench/du_e/adapter_b/graphics_e/dma_addr(17) -radix hexadecimal} {/testbench/du_e/adapter_b/graphics_e/dma_addr(16) -radix hexadecimal} {/testbench/du_e/adapter_b/graphics_e/dma_addr(15) -radix hexadecimal} {/testbench/du_e/adapter_b/graphics_e/dma_addr(14) -radix hexadecimal} {/testbench/du_e/adapter_b/graphics_e/dma_addr(13) -radix hexadecimal} {/testbench/du_e/adapter_b/graphics_e/dma_addr(12) -radix hexadecimal} {/testbench/du_e/adapter_b/graphics_e/dma_addr(11) -radix hexadecimal} {/testbench/du_e/adapter_b/graphics_e/dma_addr(10) -radix hexadecimal} {/testbench/du_e/adapter_b/graphics_e/dma_addr(9) -radix hexadecimal} {/testbench/du_e/adapter_b/graphics_e/dma_addr(8) -radix hexadecimal} {/testbench/du_e/adapter_b/graphics_e/dma_addr(7) -radix hexadecimal} {/testbench/du_e/adapter_b/graphics_e/dma_addr(6) -radix hexadecimal} {/testbench/du_e/adapter_b/graphics_e/dma_addr(5) -radix hexadecimal} {/testbench/du_e/adapter_b/graphics_e/dma_addr(4) -radix hexadecimal} {/testbench/du_e/adapter_b/graphics_e/dma_addr(3) -radix hexadecimal} {/testbench/du_e/adapter_b/graphics_e/dma_addr(2) -radix hexadecimal} {/testbench/du_e/adapter_b/graphics_e/dma_addr(1) -radix hexadecimal} {/testbench/du_e/adapter_b/graphics_e/dma_addr(0) -radix hexadecimal}} -subitemconfig {/testbench/du_e/adapter_b/graphics_e/dma_addr(23) {-height 29 -radix hexadecimal} /testbench/du_e/adapter_b/graphics_e/dma_addr(22) {-height 29 -radix hexadecimal} /testbench/du_e/adapter_b/graphics_e/dma_addr(21) {-height 29 -radix hexadecimal} /testbench/du_e/adapter_b/graphics_e/dma_addr(20) {-height 29 -radix hexadecimal} /testbench/du_e/adapter_b/graphics_e/dma_addr(19) {-height 29 -radix hexadecimal} /testbench/du_e/adapter_b/graphics_e/dma_addr(18) {-height 29 -radix hexadecimal} /testbench/du_e/adapter_b/graphics_e/dma_addr(17) {-height 29 -radix hexadecimal} /testbench/du_e/adapter_b/graphics_e/dma_addr(16) {-height 29 -radix hexadecimal} /testbench/du_e/adapter_b/graphics_e/dma_addr(15) {-height 29 -radix hexadecimal} /testbench/du_e/adapter_b/graphics_e/dma_addr(14) {-height 29 -radix hexadecimal} /testbench/du_e/adapter_b/graphics_e/dma_addr(13) {-height 29 -radix hexadecimal} /testbench/du_e/adapter_b/graphics_e/dma_addr(12) {-height 29 -radix hexadecimal} /testbench/du_e/adapter_b/graphics_e/dma_addr(11) {-height 29 -radix hexadecimal} /testbench/du_e/adapter_b/graphics_e/dma_addr(10) {-height 29 -radix hexadecimal} /testbench/du_e/adapter_b/graphics_e/dma_addr(9) {-height 29 -radix hexadecimal} /testbench/du_e/adapter_b/graphics_e/dma_addr(8) {-height 29 -radix hexadecimal} /testbench/du_e/adapter_b/graphics_e/dma_addr(7) {-height 29 -radix hexadecimal} /testbench/du_e/adapter_b/graphics_e/dma_addr(6) {-height 29 -radix hexadecimal} /testbench/du_e/adapter_b/graphics_e/dma_addr(5) {-height 29 -radix hexadecimal} /testbench/du_e/adapter_b/graphics_e/dma_addr(4) {-height 29 -radix hexadecimal} /testbench/du_e/adapter_b/graphics_e/dma_addr(3) {-height 29 -radix hexadecimal} /testbench/du_e/adapter_b/graphics_e/dma_addr(2) {-height 29 -radix hexadecimal} /testbench/du_e/adapter_b/graphics_e/dma_addr(1) {-height 29 -radix hexadecimal} /testbench/du_e/adapter_b/graphics_e/dma_addr(0) {-height 29 -radix hexadecimal}} /testbench/du_e/adapter_b/graphics_e/dma_addr
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/sdram_clk
add wave -noupdate /testbench/du_e/sdram_rasn
add wave -noupdate /testbench/du_e/sdram_casn
add wave -noupdate /testbench/du_e/sdram_wen
add wave -noupdate -radix hexadecimal /testbench/du_e/sdram_ba
add wave -noupdate -radix hexadecimal -childformat {{/testbench/du_e/sdram_a(12) -radix hexadecimal} {/testbench/du_e/sdram_a(11) -radix hexadecimal} {/testbench/du_e/sdram_a(10) -radix hexadecimal} {/testbench/du_e/sdram_a(9) -radix hexadecimal} {/testbench/du_e/sdram_a(8) -radix hexadecimal} {/testbench/du_e/sdram_a(7) -radix hexadecimal} {/testbench/du_e/sdram_a(6) -radix hexadecimal} {/testbench/du_e/sdram_a(5) -radix hexadecimal} {/testbench/du_e/sdram_a(4) -radix hexadecimal} {/testbench/du_e/sdram_a(3) -radix hexadecimal} {/testbench/du_e/sdram_a(2) -radix hexadecimal} {/testbench/du_e/sdram_a(1) -radix hexadecimal} {/testbench/du_e/sdram_a(0) -radix hexadecimal}} -subitemconfig {/testbench/du_e/sdram_a(12) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(11) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(10) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(9) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(8) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(7) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(6) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(5) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(4) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(3) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(2) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(1) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(0) {-height 29 -radix hexadecimal}} /testbench/du_e/sdram_a
add wave -noupdate -radix hexadecimal /testbench/du_e/sdram_d
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/adapter_b/graphics_e/video_clk
add wave -noupdate /testbench/du_e/video_shift_clk
add wave -noupdate /testbench/du_e/adapter_b/sync_e/video_hzsync
add wave -noupdate /testbench/du_e/adapter_b/sync_e/video_vtsync
add wave -noupdate /testbench/du_e/adapter_b/sync_e/video_hzcntr
add wave -noupdate -radix hexadecimal /testbench/du_e/adapter_b/sync_e/video_vtcntr
add wave -noupdate /testbench/du_e/adapter_b/sync_e/video_hzon
add wave -noupdate /testbench/du_e/adapter_b/sync_e/video_vton
add wave -noupdate /testbench/du_e/video_pixel
add wave -noupdate /testbench/du_e/dvi_b/in_red
add wave -noupdate /testbench/du_e/dvi_b/in_green
add wave -noupdate /testbench/du_e/dvi_b/in_blue
add wave -noupdate /testbench/du_e/adapter_b/graphics_e/ctlr_di
add wave -noupdate /testbench/du_e/adapter_b/graphics_e/vram_irdy
add wave -noupdate /testbench/du_e/adapter_b/graphics_e/vram_data
add wave -noupdate -divider {New Divider}
add wave -noupdate -expand /testbench/du_e/dmactlr_e/devcfg_req
add wave -noupdate /testbench/du_e/dmactlr_e/devcfg_rdy
add wave -noupdate -expand /testbench/du_e/dmactlr_e/dev_req
add wave -noupdate -expand /testbench/du_e/dmactlr_e/dev_rdy
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {138467500000 fs} 0} {{Cursor 2} {1770270664580 fs} 0}
quietly wave cursor active 1
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
WaveRestoreZoom {0 fs} {2100 us}
