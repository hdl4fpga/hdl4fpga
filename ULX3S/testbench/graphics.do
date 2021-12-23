onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/du_e/clk_25mhz
add wave -noupdate /testbench/du_e/ftdi_rxd
add wave -noupdate /testbench/du_e/ftdi_txd
add wave -noupdate /testbench/du_e/sdram_clk
add wave -noupdate /testbench/du_e/sdram_rasn
add wave -noupdate /testbench/du_e/sdram_casn
add wave -noupdate /testbench/du_e/sdram_wen
add wave -noupdate -radix hexadecimal /testbench/du_e/sdram_ba
add wave -noupdate -radix hexadecimal -childformat {{/testbench/du_e/sdram_a(12) -radix hexadecimal} {/testbench/du_e/sdram_a(11) -radix hexadecimal} {/testbench/du_e/sdram_a(10) -radix hexadecimal} {/testbench/du_e/sdram_a(9) -radix hexadecimal} {/testbench/du_e/sdram_a(8) -radix hexadecimal} {/testbench/du_e/sdram_a(7) -radix hexadecimal} {/testbench/du_e/sdram_a(6) -radix hexadecimal} {/testbench/du_e/sdram_a(5) -radix hexadecimal} {/testbench/du_e/sdram_a(4) -radix hexadecimal} {/testbench/du_e/sdram_a(3) -radix hexadecimal} {/testbench/du_e/sdram_a(2) -radix hexadecimal} {/testbench/du_e/sdram_a(1) -radix hexadecimal} {/testbench/du_e/sdram_a(0) -radix hexadecimal}} -subitemconfig {/testbench/du_e/sdram_a(12) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(11) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(10) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(9) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(8) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(7) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(6) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(5) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(4) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(3) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(2) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(1) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(0) {-height 29 -radix hexadecimal}} /testbench/du_e/sdram_a
add wave -noupdate -radix hexadecimal /testbench/du_e/sdram_d
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/graphics_e/vt_req
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/graphics_e/hz_req
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/adapter_b/graphics_e/level
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/adapter_b/graphics_e/dma_len
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/adapter_b/graphics_e/dma_addr
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/adapter_b/graphics_e/dma_step
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix hexadecimal /testbench/hdlc_b/uartrx_e/debug_rxd
add wave -noupdate /testbench/hdlc_b/uartrx_e/debug_rxdv
add wave -noupdate /testbench/hdlc_b/hdlcdll_rx_e/hdlcrx_frm
add wave -noupdate /testbench/hdlc_b/hdlcdll_rx_e/hdlcrx_irdy
add wave -noupdate /testbench/hdlc_b/hdlcdll_rx_e/hdlcrx_end
add wave -noupdate -radix hexadecimal /testbench/hdlc_b/hdlcdll_rx_e/hdlcrx_data
add wave -noupdate /testbench/du_e/grahics_e/sio_b/sodata_frm
add wave -noupdate /testbench/du_e/grahics_e/sio_b/sodata_irdy
add wave -noupdate /testbench/du_e/grahics_e/sio_b/sodata_trdy
add wave -noupdate /testbench/du_e/grahics_e/sio_b/sodata_end
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/sio_b/sodata_data
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/sio_b/sodata_b/sodata_e/low_cntr
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/sio_b/sodata_b/sodata_e/si_length
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {290740996880 fs} 0}
quietly wave cursor active 1
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
WaveRestoreZoom {290260266840 fs} {304615860440 fs}
