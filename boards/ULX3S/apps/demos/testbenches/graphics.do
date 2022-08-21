onerror {resume}
quietly virtual signal -install /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_b/col_e { /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_b/col_e/wr_cntr(1 to 3)} wr
quietly virtual signal -install /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_b/col_e { /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_b/col_e/rd_cntr(1 to 3)} rd
quietly virtual signal -install /testbench/du_e/grahics_e { (context /testbench/du_e/grahics_e )( sout_data(7) & sout_data(6) & sout_data(5) & sout_data(4) & sout_data(3) & sout_data(2) & sout_data(1) & sout_data(0) )} pp
quietly virtual signal -install /testbench/du_e/grahics_e { (context /testbench/du_e/grahics_e )( sout_data(7) & sout_data(6) & sout_data(5) & sout_data(4) & sout_data(3) & sout_data(2) & sout_data(1) & sout_data(0) )} soddata
quietly virtual signal -install /testbench/du_e/grahics_e { (context /testbench/du_e/grahics_e )( sin_data(7) & sin_data(6) & sin_data(5) & sin_data(4) & sin_data(3) & sin_data(2) & sin_data(1) & sin_data(0) )} sin_rdata
quietly virtual signal -install /testbench/du_e/grahics_e { (context /testbench/du_e/grahics_e )( sout_data(7) & sout_data(6) & sout_data(5) & sout_data(4) & sout_data(3) & sout_data(2) & sout_data(1) & sout_data(0) )} sout_rdata
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
add wave -noupdate /testbench/du_e/grahics_e/sin_frm
add wave -noupdate /testbench/du_e/grahics_e/sin_irdy
add wave -noupdate /testbench/du_e/grahics_e/sin_trdy
add wave -noupdate /testbench/du_e/grahics_e/sin_data
add wave -noupdate /testbench/du_e/hdlc_g/siodaahdlc_e/siohdlc_e/hdlc_b/hdlcdll_rx_e/fcs_sb
add wave -noupdate /testbench/du_e/hdlc_g/siodaahdlc_e/siohdlc_e/hdlc_b/hdlcdll_rx_e/fcs_vld
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/ctlr_refreq
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/adapter_b/sync_e/video_hzcntr
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/sync_e/video_hzsync
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/adapter_b/sync_e/video_vtcntr
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/sync_e/video_vtsync
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dmatrans_req
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dmatrans_rdy
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/graphics_e/ctlr_di_dv
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/graphics_e/ctlr_di
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {77753509720 fs} 0} {{Cursor 2} {268146513900 fs} 0}
quietly wave cursor active 2
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
WaveRestoreZoom {295324218750 fs} {300246093750 fs}
