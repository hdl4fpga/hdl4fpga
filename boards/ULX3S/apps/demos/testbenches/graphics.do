onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {New Divider}
add wave -noupdate -expand -group sdram /testbench/du_e/sdram_clk
add wave -noupdate -expand -group sdram /testbench/du_e/sdram_cke
add wave -noupdate -expand -group sdram /testbench/du_e/sdram_csn
add wave -noupdate -expand -group sdram /testbench/du_e/sdram_rasn
add wave -noupdate -expand -group sdram /testbench/du_e/sdram_wen
add wave -noupdate -expand -group sdram /testbench/du_e/sdram_casn
add wave -noupdate -expand -group sdram /testbench/du_e/sdram_ba
add wave -noupdate -expand -group sdram -radix hexadecimal -childformat {{/testbench/du_e/sdram_a(12) -radix hexadecimal} {/testbench/du_e/sdram_a(11) -radix hexadecimal} {/testbench/du_e/sdram_a(10) -radix hexadecimal} {/testbench/du_e/sdram_a(9) -radix hexadecimal} {/testbench/du_e/sdram_a(8) -radix hexadecimal} {/testbench/du_e/sdram_a(7) -radix hexadecimal} {/testbench/du_e/sdram_a(6) -radix hexadecimal} {/testbench/du_e/sdram_a(5) -radix hexadecimal} {/testbench/du_e/sdram_a(4) -radix hexadecimal} {/testbench/du_e/sdram_a(3) -radix hexadecimal} {/testbench/du_e/sdram_a(2) -radix hexadecimal} {/testbench/du_e/sdram_a(1) -radix hexadecimal} {/testbench/du_e/sdram_a(0) -radix hexadecimal}} -subitemconfig {/testbench/du_e/sdram_a(12) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(11) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(10) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(9) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(8) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(7) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(6) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(5) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(4) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(3) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(2) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(1) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(0) {-height 29 -radix hexadecimal}} /testbench/du_e/sdram_a
add wave -noupdate -expand -group sdram /testbench/du_e/sdram_d
add wave -noupdate -expand -group uart /testbench/du_e/ftdi_txd
add wave -noupdate -expand -group uart /testbench/du_e/ftdi_rxd
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/ctlr_alat
add wave -noupdate /testbench/du_e/debug
add wave -noupdate /testbench/du_e/grahics_e/sdrctlr_b/sdrctlr_e/debug
add wave -noupdate /testbench/du_e/grahics_e/debug
add wave -noupdate /testbench/hdlc_b/uartrx_e/baudrate
add wave -noupdate /testbench/hdlc_b/uartrx_e/uart_rxc
add wave -noupdate /testbench/hdlc_b/uarttx_e/uart_txc
add wave -noupdate /testbench/du_e/hdlc_g/uartrx_e/uart_rxc
add wave -noupdate /testbench/du_e/hdlc_g/uarttx_e/uart_txc
add wave -noupdate /testbench/hdlc_b/uarttx_e/debug_txen
add wave -noupdate -radix hexadecimal /testbench/hdlc_b/uarttx_e/debug_txd
add wave -noupdate -radix hexadecimal /testbench/du_e/hdlc_g/uartrx_e/debug_rxd
add wave -noupdate /testbench/du_e/hdlc_g/uartrx_e/debug_rxdv
add wave -noupdate /testbench/du_e/hdlc_g/uartrx_e/baudrate
add wave -noupdate /testbench/du_e/grahics_e/sin_frm
add wave -noupdate /testbench/du_e/grahics_e/sin_irdy
add wave -noupdate /testbench/du_e/grahics_e/sin_trdy
add wave -noupdate /testbench/du_e/grahics_e/sin_data
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/sync_e/video_clk
add wave -noupdate -radix unsigned /testbench/du_e/grahics_e/adapter_b/sync_e/video_hzcntr
add wave -noupdate -radix unsigned /testbench/du_e/grahics_e/adapter_b/sync_e/video_vtcntr
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/sync_e/video_hzon
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/sync_e/video_vton
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/sync_e/video_hzsync
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/sync_e/video_vtsync
add wave -noupdate -divider {New Divider}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {23363182120 fs} 0} {{Cursor 2} {58056155510 fs} 0}
quietly wave cursor active 1
configure wave -namecolwidth 221
configure wave -valuecolwidth 130
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
WaveRestoreZoom {25805175770 fs} {26010253910 fs}
