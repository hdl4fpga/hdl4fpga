onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {New Divider}
add wave -noupdate -expand -group sdram /testbench/du_e/sdram_clk
add wave -noupdate -expand -group sdram /testbench/du_e/sdram_cke
add wave -noupdate -expand -group sdram /testbench/du_e/sdram_csn
add wave -noupdate -expand -group sdram /testbench/du_e/sdram_wen
add wave -noupdate -expand -group sdram /testbench/du_e/sdram_rasn
add wave -noupdate -expand -group sdram /testbench/du_e/sdram_casn
add wave -noupdate -expand -group sdram /testbench/du_e/sdram_ba
add wave -noupdate -expand -group sdram -radix hexadecimal /testbench/du_e/sdram_a
add wave -noupdate -expand -group sdram /testbench/du_e/sdram_d
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/lrcd
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/coln_align
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/burst_bits
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_e/clk
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_e/load
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_e/ena
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_e/iaddr
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_e/ilen
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_e/taddr
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_e/tlen
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_e/bnk
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_e/row
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_e/col
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_e/bnk_eoc
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_e/row_eoc
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_e/col_eoc
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_e/len_eoc
add wave -noupdate /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_frm
add wave -noupdate /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ddr_mpu_e/ddr_mpu_trdy
add wave -noupdate /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ddr_pgm_e/ddr_pgm_pc
add wave -noupdate /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ddr_mpu_e/ddr_state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {118345560 ps} 0}
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
WaveRestoreZoom {118291720 ps} {118335870 ps}
