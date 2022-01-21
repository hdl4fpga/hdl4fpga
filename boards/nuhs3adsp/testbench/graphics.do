onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {New Divider}
add wave -noupdate -expand -group mii_rx /testbench/du_e/mii_rxc
add wave -noupdate -expand -group mii_rx /testbench/du_e/mii_rxdv
add wave -noupdate -expand -group mii_rx -radix hexadecimal /testbench/du_e/mii_rxd
add wave -noupdate -group mii_tx /testbench/du_e/mii_txc
add wave -noupdate -group mii_tx /testbench/du_e/mii_txen
add wave -noupdate -group mii_tx -radix hexadecimal /testbench/du_e/mii_txd
add wave -noupdate -expand -group ddr /testbench/du_e/ddr_ckp
add wave -noupdate -expand -group ddr /testbench/du_e/ddr_cs
add wave -noupdate -expand -group ddr /testbench/du_e/ddr_cke
add wave -noupdate -expand -group ddr -divider {New Divider}
add wave -noupdate -expand -group ddr /testbench/du_e/ddr_ras
add wave -noupdate -expand -group ddr /testbench/du_e/ddr_cas
add wave -noupdate -expand -group ddr /testbench/du_e/ddr_we
add wave -noupdate -expand -group ddr -radix hexadecimal /testbench/du_e/ddr_ba
add wave -noupdate -expand -group ddr -radix hexadecimal /testbench/du_e/ddr_a
add wave -noupdate -expand -group ddr -divider {New Divider}
add wave -noupdate -expand -group ddr /testbench/du_e/ddr_dqs
add wave -noupdate -expand -group ddr /testbench/du_e/ddr_dq
add wave -noupdate -expand -group ddr /testbench/du_e/ddr_st_dqs
add wave -noupdate -expand -group ddr /testbench/du_e/ddr_st_lp_dqs
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_b/fifo_b/bnk_e/wr_cntr
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_b/fifo_b/bnk_e/rd_cntr
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_b/fifo_b/bnk_irdy
add wave -noupdate -radix binary /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_b/dma_e/bnk
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_b/fifo_b/bnk_trdy
add wave -noupdate -radix binary /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/ddrdma_bnk
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ddr_pgm_e/ddr_pgm_frm
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/ctlr_trdy
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/ctlr_cmd
add wave -noupdate /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ddr_pgm_e/ddr_pgm_pc
add wave -noupdate /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ddr_mpu_e/ddr_state
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/ctlr_b
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/ctlr_a
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/load
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/ctlr_ras
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/ctlr_cas
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_b/dma_e/ena
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/ctlr_frm
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/leoc
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_b/fifo_b/fifo_frm
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dmatrans_clk
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_b/fifo_b/bnk_irdy
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_b/fifo_b/bnk_load
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/ena
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/loaded
add wave -noupdate -radix hexadecimal -childformat {{/testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_b/fifo_b/bnk_e/wr_cntr(0) -radix hexadecimal} {/testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_b/fifo_b/bnk_e/wr_cntr(1) -radix hexadecimal} {/testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_b/fifo_b/bnk_e/wr_cntr(2) -radix hexadecimal} {/testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_b/fifo_b/bnk_e/wr_cntr(3) -radix hexadecimal}} -subitemconfig {/testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_b/fifo_b/bnk_e/wr_cntr(0) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_b/fifo_b/bnk_e/wr_cntr(1) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_b/fifo_b/bnk_e/wr_cntr(2) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_b/fifo_b/bnk_e/wr_cntr(3) {-height 29 -radix hexadecimal}} /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_b/fifo_b/bnk_e/wr_cntr
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_b/fifo_b/bnk_e/rd_cntr
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_b/fifo_b/bnk_trdy
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_b/bnk
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/ddrdma_bnk
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/state_pre
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/ceoc
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_b/dma_e/col
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_b/fifo_b/col_irdy
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/ddrdma_col
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_b/dma_e/load
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_b/fifo_b/row_irdy
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_b/dma_e/row
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/ddrdma_row
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {208885240 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 221
configure wave -valuecolwidth 135
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
WaveRestoreZoom {208705845 ps} {209120745 ps}
