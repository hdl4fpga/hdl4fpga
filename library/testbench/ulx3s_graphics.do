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
add wave -noupdate -radix hexadecimal /testbench/du_e/adapter_b/graphics_e/dma_len
add wave -noupdate -radix hexadecimal /testbench/du_e/adapter_b/graphics_e/dma_addr
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/sdram_clk
add wave -noupdate /testbench/du_e/sdram_rasn
add wave -noupdate /testbench/du_e/sdram_casn
add wave -noupdate /testbench/du_e/sdram_wen
add wave -noupdate -radix hexadecimal /testbench/du_e/sdram_ba
add wave -noupdate -radix hexadecimal /testbench/du_e/sdram_a
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
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/dmactlr_e/devcfg_req
add wave -noupdate /testbench/du_e/dmactlr_e/devcfg_rdy
add wave -noupdate /testbench/du_e/dmactlr_e/dev_req
add wave -noupdate /testbench/du_e/dmactlr_e/dev_rdy
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {436561070 fs} 0} {{Cursor 2} {439665460 fs} 0}
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
WaveRestoreZoom {0 fs} {1050 ns}
