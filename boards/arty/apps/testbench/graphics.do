onerror {resume}
quietly virtual signal -install /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_b/col_e { /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_b/col_e/wr_cntr(1 to 3)} wr
quietly virtual signal -install /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_b/col_e { /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_b/col_e/rd_cntr(1 to 3)} rd
quietly virtual signal -install /testbench/du_e/grahics_e { (context /testbench/du_e/grahics_e )( sout_data(7) & sout_data(6) & sout_data(5) & sout_data(4) & sout_data(3) & sout_data(2) & sout_data(1) & sout_data(0) )} pp
quietly virtual signal -install /testbench/du_e/grahics_e { (context /testbench/du_e/grahics_e )( sout_data(7) & sout_data(6) & sout_data(5) & sout_data(4) & sout_data(3) & sout_data(2) & sout_data(1) & sout_data(0) )} soddata
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/du_e/btn(0)
add wave -noupdate -expand -group eth_rx /testbench/du_e/eth_rx_clk
add wave -noupdate -expand -group eth_rx /testbench/du_e/eth_rx_dv
add wave -noupdate -expand -group eth_rx -radix hexadecimal /testbench/du_e/eth_rxd
add wave -noupdate -expand -group eth_tx /testbench/du_e/eth_tx_clk
add wave -noupdate -expand -group eth_tx /testbench/du_e/eth_tx_en
add wave -noupdate -expand -group eth_tx -radix hexadecimal /testbench/du_e/eth_txd
add wave -noupdate -expand -group ddr3 -radix hexadecimal /testbench/du_e/ddr3_clk_p
add wave -noupdate -expand -group ddr3 -radix hexadecimal /testbench/du_e/ddr3_reset
add wave -noupdate -expand -group ddr3 -radix hexadecimal /testbench/du_e/ddr3_cs
add wave -noupdate -expand -group ddr3 -radix hexadecimal /testbench/du_e/ddr3_cke
add wave -noupdate -expand -group ddr3 /testbench/du_e/ddr3_odt
add wave -noupdate -expand -group ddr3 -radix hexadecimal /testbench/du_e/ddr3_ras
add wave -noupdate -expand -group ddr3 -radix hexadecimal /testbench/du_e/ddr3_cas
add wave -noupdate -expand -group ddr3 -radix hexadecimal /testbench/du_e/ddr3_we
add wave -noupdate -expand -group ddr3 -divider {New Divider}
add wave -noupdate -expand -group ddr3 -radix symbolic -childformat {{/testbench/du_e/ddr3_ba(2) -radix hexadecimal} {/testbench/du_e/ddr3_ba(1) -radix hexadecimal} {/testbench/du_e/ddr3_ba(0) -radix hexadecimal}} -subitemconfig {/testbench/du_e/ddr3_ba(2) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_ba(1) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_ba(0) {-height 29 -radix hexadecimal}} /testbench/du_e/ddr3_ba
add wave -noupdate -expand -group ddr3 -radix hexadecimal -childformat {{/testbench/du_e/ddr3_dq(15) -radix hexadecimal} {/testbench/du_e/ddr3_dq(14) -radix hexadecimal} {/testbench/du_e/ddr3_dq(13) -radix hexadecimal} {/testbench/du_e/ddr3_dq(12) -radix hexadecimal} {/testbench/du_e/ddr3_dq(11) -radix hexadecimal} {/testbench/du_e/ddr3_dq(10) -radix hexadecimal} {/testbench/du_e/ddr3_dq(9) -radix hexadecimal} {/testbench/du_e/ddr3_dq(8) -radix hexadecimal} {/testbench/du_e/ddr3_dq(7) -radix hexadecimal} {/testbench/du_e/ddr3_dq(6) -radix hexadecimal} {/testbench/du_e/ddr3_dq(5) -radix hexadecimal} {/testbench/du_e/ddr3_dq(4) -radix hexadecimal} {/testbench/du_e/ddr3_dq(3) -radix hexadecimal} {/testbench/du_e/ddr3_dq(2) -radix hexadecimal} {/testbench/du_e/ddr3_dq(1) -radix hexadecimal} {/testbench/du_e/ddr3_dq(0) -radix hexadecimal}} -subitemconfig {/testbench/du_e/ddr3_dq(15) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_dq(14) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_dq(13) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_dq(12) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_dq(11) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_dq(10) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_dq(9) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_dq(8) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_dq(7) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_dq(6) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_dq(5) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_dq(4) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_dq(3) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_dq(2) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_dq(1) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_dq(0) {-height 29 -radix hexadecimal}} /testbench/du_e/ddr3_dq
add wave -noupdate -expand -group ddr3 -radix hexadecimal -childformat {{/testbench/du_e/ddr3_a(13) -radix hexadecimal} {/testbench/du_e/ddr3_a(12) -radix hexadecimal} {/testbench/du_e/ddr3_a(11) -radix hexadecimal} {/testbench/du_e/ddr3_a(10) -radix hexadecimal} {/testbench/du_e/ddr3_a(9) -radix hexadecimal} {/testbench/du_e/ddr3_a(8) -radix hexadecimal} {/testbench/du_e/ddr3_a(7) -radix hexadecimal} {/testbench/du_e/ddr3_a(6) -radix hexadecimal} {/testbench/du_e/ddr3_a(5) -radix hexadecimal} {/testbench/du_e/ddr3_a(4) -radix hexadecimal} {/testbench/du_e/ddr3_a(3) -radix hexadecimal} {/testbench/du_e/ddr3_a(2) -radix hexadecimal} {/testbench/du_e/ddr3_a(1) -radix hexadecimal} {/testbench/du_e/ddr3_a(0) -radix hexadecimal}} -subitemconfig {/testbench/du_e/ddr3_a(13) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_a(12) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_a(11) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_a(10) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_a(9) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_a(8) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_a(7) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_a(6) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_a(5) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_a(4) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_a(3) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_a(2) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_a(1) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_a(0) {-height 29 -radix hexadecimal}} /testbench/du_e/ddr3_a
add wave -noupdate -expand -group ddr3 /testbench/du_e/ddr3_dqs_p(1)
add wave -noupdate -expand -group ddr3 /testbench/du_e/ddr3_dqs_p(0)
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/grahics_e/sout_frm
add wave -noupdate /testbench/du_e/grahics_e/sout_irdy
add wave -noupdate /testbench/du_e/grahics_e/sout_trdy
add wave -noupdate /testbench/du_e/grahics_e/sout_end
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/soddata
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/grahics_e/ctlr_clks(0)
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dev_do_dv(1)
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/ctlr_do
add wave -noupdate /testbench/du_e/grahics_e/sio_b/tx_b/sodata_b/dmaso_irdy
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/sio_b/tx_b/sodata_b/dmaso_data
add wave -noupdate /testbench/du_e/grahics_e/sio_b/tx_b/sodata_b/fifo_irdy
add wave -noupdate /testbench/du_e/grahics_e/sio_b/tx_b/sodata_b/fifo_trdy
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/sio_b/tx_b/sodata_b/fifo_data
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ddr_pgm_e/pgm_cmd
add wave -noupdate /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ddr_pgm_e/ddr_input
add wave -noupdate /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ddr_mpu_ref
add wave -noupdate /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ddr_pgm_e/ddr_pgm_pc
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/ctlr_trdy
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/ctlr_cmd
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/ctlr_cas
add wave -noupdate /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_frm
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_b/col_frm
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_b/ena
add wave -noupdate /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_refreq
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/refreq
add wave -noupdate /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ddr_refi_req
add wave -noupdate /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ddr_refi_rdy
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix hexadecimal -childformat {{/testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_b/col(8) -radix hexadecimal} {/testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_b/col(7) -radix hexadecimal} {/testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_b/col(6) -radix hexadecimal} {/testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_b/col(5) -radix hexadecimal} {/testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_b/col(4) -radix hexadecimal} {/testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_b/col(3) -radix hexadecimal} {/testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_b/col(2) -radix hexadecimal}} -subitemconfig {/testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_b/col(8) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_b/col(7) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_b/col(6) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_b/col(5) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_b/col(4) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_b/col(3) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_b/col(2) {-height 29 -radix hexadecimal}} /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_b/col
add wave -noupdate /testbench/du_e/grahics_e/sio_b/sio_dmahdsk_e/dma_req
add wave -noupdate /testbench/du_e/grahics_e/sio_b/sio_dmahdsk_e/dma_rdy
add wave -noupdate /testbench/du_e/grahics_e/sio_b/dmaio_next
add wave -noupdate /testbench/du_e/grahics_e/sio_b/dmaio_trdy
add wave -noupdate /testbench/du_e/grahics_e/sio_b/acktx_irdy
add wave -noupdate /testbench/du_e/grahics_e/sio_b/acktx_trdy
add wave -noupdate -divider {New Divider}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {14366111 ps} 1} {{Cursor 2} {41937768 ps} 0} {{Cursor 3} {41937561 ps} 0}
quietly wave cursor active 3
configure wave -namecolwidth 221
configure wave -valuecolwidth 247
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
WaveRestoreZoom {41907164 ps} {42048716 ps}
