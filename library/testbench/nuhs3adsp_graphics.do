onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/du_e/mii_rxc
add wave -noupdate /testbench/du_e/mii_rxdv
add wave -noupdate -radix hexadecimal /testbench/du_e/mii_rxd
add wave -noupdate /testbench/du_e/mii_txc
add wave -noupdate /testbench/du_e/mii_txen
add wave -noupdate -radix hexadecimal /testbench/du_e/mii_txd
add wave -noupdate /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/mii_ipoe_e/txc_rxdv
add wave -noupdate -radix hexadecimal -childformat {{/testbench/du_e/si_b/udpdaisy_e/sioudpp_e/mii_ipoe_e/txc_rxd(0) -radix hexadecimal} {/testbench/du_e/si_b/udpdaisy_e/sioudpp_e/mii_ipoe_e/txc_rxd(1) -radix hexadecimal} {/testbench/du_e/si_b/udpdaisy_e/sioudpp_e/mii_ipoe_e/txc_rxd(2) -radix hexadecimal} {/testbench/du_e/si_b/udpdaisy_e/sioudpp_e/mii_ipoe_e/txc_rxd(3) -radix hexadecimal}} -subitemconfig {/testbench/du_e/si_b/udpdaisy_e/sioudpp_e/mii_ipoe_e/txc_rxd(0) {-height 29 -radix hexadecimal} /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/mii_ipoe_e/txc_rxd(1) {-height 29 -radix hexadecimal} /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/mii_ipoe_e/txc_rxd(2) {-height 29 -radix hexadecimal} /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/mii_ipoe_e/txc_rxd(3) {-height 29 -radix hexadecimal}} /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/mii_ipoe_e/txc_rxd
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/ddr_ckp
add wave -noupdate /testbench/du_e/ddr_cas
add wave -noupdate /testbench/du_e/ddr_ras
add wave -noupdate /testbench/du_e/ddr_we
add wave -noupdate /testbench/du_e/ddr_ba
add wave -noupdate -radix hexadecimal /testbench/du_e/ddr_a
add wave -noupdate /testbench/du_e/ddr_dqs
add wave -noupdate -radix hexadecimal /testbench/du_e/ddr_dq
add wave -noupdate -radix hexadecimal /testbench/du_e/dmaio_len
add wave -noupdate -radix hexadecimal /testbench/du_e/dmaio_addr
add wave -noupdate /testbench/du_e/dmactlr_e/dmargtr_dv
add wave -noupdate /testbench/du_e/dmactlr_e/dmargtr_id
add wave -noupdate -radix hexadecimal /testbench/du_e/dmactlr_e/dmargtr_addr
add wave -noupdate -radix hexadecimal /testbench/du_e/dmactlr_e/dmargtr_len
add wave -noupdate -radix hexadecimal /testbench/du_e/dmactlr_e/dmargtr_we
add wave -noupdate -radix hexadecimal /testbench/du_e/dmactlr_e/dmatrans_rid
add wave -noupdate -radix hexadecimal /testbench/du_e/dmactlr_e/dmatrans_iaddr
add wave -noupdate -radix hexadecimal /testbench/du_e/dmactlr_e/dmatrans_ilen
add wave -noupdate /testbench/du_e/dmactlr_e/devcfg_req(1)
add wave -noupdate /testbench/du_e/dmactlr_e/devcfg_rdy(1)
add wave -noupdate /testbench/du_e/dmactlr_e/dev_req(1)
add wave -noupdate /testbench/du_e/dmactlr_e/dev_rdy(1)
add wave -noupdate /testbench/du_e/dmactlr_e/dmatrans_e/load
add wave -noupdate -radix hexadecimal /testbench/du_e/dmactlr_e/dmatrans_e/dma_e/iaddr
add wave -noupdate -radix hexadecimal /testbench/du_e/dmactlr_e/dmatrans_e/dma_e/ilen
add wave -noupdate -radix hexadecimal /testbench/du_e/dmactlr_e/dmatrans_e/dma_e/taddr
add wave -noupdate -radix hexadecimal /testbench/du_e/dmactlr_e/dmatrans_e/dma_e/tlen
add wave -noupdate -radix hexadecimal /testbench/du_e/dmactlr_e/dmatrans_e/dma_e/bnk
add wave -noupdate -radix hexadecimal /testbench/du_e/dmactlr_e/dmatrans_e/dma_e/row
add wave -noupdate -radix hexadecimal /testbench/du_e/dmactlr_e/dmatrans_e/dma_e/col
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 2} {281484761280 fs} 0}
quietly wave cursor active 1
configure wave -namecolwidth 249
configure wave -valuecolwidth 165
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
WaveRestoreZoom {281380995070 fs} {281586073230 fs}
