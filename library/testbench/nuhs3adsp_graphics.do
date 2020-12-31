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
add wave -noupdate -radix decimal /testbench/ethtx_e/eth_ptr
add wave -noupdate /testbench/ethtx_e/eth_ptr(0)
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/si_b/udpdaisy_e/so_frm
add wave -noupdate /testbench/du_e/ctlr_refreq
add wave -noupdate /testbench/du_e/si_b/udpdaisy_e/so_irdy
add wave -noupdate -radix hexadecimal /testbench/du_e/si_b/udpdaisy_e/so_data
add wave -noupdate /testbench/du_e/dmaio_trdy
add wave -noupdate /testbench/du_e/dmaiolen_irdy
add wave -noupdate /testbench/du_e/dmaioaddr_irdy
add wave -noupdate /testbench/du_e/si_b/dmalen_e/dst_clk
add wave -noupdate /testbench/du_e/si_b/dma_b/cfg2ctlr_req
add wave -noupdate /testbench/du_e/si_b/dma_b/cfg2ctlr_rdy
add wave -noupdate /testbench/du_e/si_b/dma_b/ctlr2cfg_req
add wave -noupdate /testbench/du_e/si_b/dma_b/ctlr2cfg_rdy
add wave -noupdate /testbench/du_e/si_b/dma_b/dmacfg_req
add wave -noupdate /testbench/du_e/si_b/dma_b/dmacfg_rdy
add wave -noupdate /testbench/du_e/si_b/dma_b/dma_req
add wave -noupdate /testbench/du_e/si_b/dma_b/dma_rdy
add wave -noupdate /testbench/du_e/ddr_ras
add wave -noupdate /testbench/du_e/ddr_cas
add wave -noupdate /testbench/du_e/ddr_we
add wave -noupdate /testbench/du_e/ddr_ba
add wave -noupdate -radix hexadecimal /testbench/du_e/ddr_a
add wave -noupdate /testbench/du_e/ddr_dqs
add wave -noupdate -radix hexadecimal /testbench/du_e/ddr_dq
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 2} {343786832350 fs} 0}
quietly wave cursor active 1
configure wave -namecolwidth 323
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
WaveRestoreZoom {318004530370 fs} {370242031810 fs}
