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
add wave -noupdate /testbench/du_e/ctlr_refreq
add wave -noupdate -radix hexadecimal /testbench/du_e/dmaio_len
add wave -noupdate -radix hexadecimal /testbench/du_e/dmaio_addr
add wave -noupdate /testbench/du_e/ddr_ckp
add wave -noupdate /testbench/du_e/ddr_ras
add wave -noupdate /testbench/du_e/ddr_cas
add wave -noupdate /testbench/du_e/ddr_we
add wave -noupdate /testbench/du_e/ddr_ba
add wave -noupdate -radix hexadecimal -childformat {{/testbench/du_e/ddr_a(12) -radix hexadecimal} {/testbench/du_e/ddr_a(11) -radix hexadecimal} {/testbench/du_e/ddr_a(10) -radix hexadecimal} {/testbench/du_e/ddr_a(9) -radix hexadecimal} {/testbench/du_e/ddr_a(8) -radix hexadecimal} {/testbench/du_e/ddr_a(7) -radix hexadecimal} {/testbench/du_e/ddr_a(6) -radix hexadecimal} {/testbench/du_e/ddr_a(5) -radix hexadecimal} {/testbench/du_e/ddr_a(4) -radix hexadecimal} {/testbench/du_e/ddr_a(3) -radix hexadecimal} {/testbench/du_e/ddr_a(2) -radix hexadecimal} {/testbench/du_e/ddr_a(1) -radix hexadecimal} {/testbench/du_e/ddr_a(0) -radix hexadecimal}} -subitemconfig {/testbench/du_e/ddr_a(12) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(11) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(10) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(9) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(8) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(7) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(6) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(5) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(4) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(3) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(2) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(1) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(0) {-height 29 -radix hexadecimal}} /testbench/du_e/ddr_a
add wave -noupdate -expand /testbench/du_e/ddr_dqs
add wave -noupdate -radix hexadecimal /testbench/du_e/ddr_dq
add wave -noupdate -radix hexadecimal /testbench/du_e/adapter_b/hzcntr
add wave -noupdate -radix hexadecimal /testbench/du_e/adapter_b/vtcntr
add wave -noupdate /testbench/du_e/adapter_b/hzon
add wave -noupdate /testbench/du_e/adapter_b/vton
add wave -noupdate /testbench/du_e/adapter_b/hzsync
add wave -noupdate /testbench/du_e/adapter_b/vtsync
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/dmactlr_e/dmatransgnt_e/rsrc_clk
add wave -noupdate /testbench/du_e/dmactlr_e/dmatransgnt_e/rsrc_rdy
add wave -noupdate /testbench/du_e/dmactlr_e/dmatransgnt_e/rsrc_req
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/dmactlr_e/dma_gnt
add wave -noupdate /testbench/du_e/dmactlr_e/dmatrans_e/load
add wave -noupdate /testbench/du_e/dmactlr_e/dmatrans_e/dma_e/load
add wave -noupdate /testbench/du_e/dmactlr_e/dmatrans_e/dma_e/cntr_e/load
add wave -noupdate -radix hexadecimal /testbench/du_e/dmactlr_e/dmargtr_addr
add wave -noupdate -radix hexadecimal /testbench/du_e/dmactlr_e/dmargtr_len
add wave -noupdate -radix hexadecimal /testbench/du_e/dmactlr_e/dmatrans_iaddr
add wave -noupdate -radix hexadecimal /testbench/du_e/dmactlr_e/dmatrans_ilen
add wave -noupdate /testbench/du_e/dmactlr_e/dmatrans_req
add wave -noupdate /testbench/du_e/dmactlr_e/dmatrans_rdy
add wave -noupdate /testbench/du_e/dmactlr_e/dev_req(1)
add wave -noupdate /testbench/du_e/dmactlr_e/dev_rdy(1)
add wave -noupdate /testbench/du_e/dmactlr_e/dmargtr_dv
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/si_b/debug_dmacfgio_req
add wave -noupdate /testbench/du_e/adapter_b/graphics_e/debug_dmacfg_req
add wave -noupdate /testbench/du_e/dmactlr_e/dmacfg_gnt
add wave -noupdate /testbench/du_e/dmactlr_e/dmargtr_id
add wave -noupdate /testbench/du_e/dmactlr_e/dmargtrgnt_e/arb_req
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/si_b/debug_dmaio_req
add wave -noupdate /testbench/du_e/adapter_b/graphics_e/debug_dma_req
add wave -noupdate -radix symbolic -childformat {{/testbench/du_e/dmactlr_e/dmatrans_rid(0) -radix hexadecimal}} -subitemconfig {/testbench/du_e/dmactlr_e/dmatrans_rid(0) {-height 29 -radix hexadecimal}} /testbench/du_e/dmactlr_e/dmatrans_rid
add wave -noupdate /testbench/du_e/dmactlr_e/dma_gnt
add wave -noupdate /testbench/du_e/dmactlr_e/dmatransgnt_e/arb_req
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/dmactlr_e/dmacfg_gnt(1)
add wave -noupdate /testbench/du_e/dmactlr_e/dmargtrgnt_e/rsrc_clk
add wave -noupdate /testbench/du_e/dmactlr_e/devcfg_req(1)
add wave -noupdate /testbench/du_e/dmactlr_e/devcfg_rdy(1)
add wave -noupdate /testbench/du_e/dmactlr_e/dev_req(1)
add wave -noupdate /testbench/du_e/dmactlr_e/dev_rdy(1)
add wave -noupdate /testbench/du_e/dmactlr_e/dma_gnt(1)
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/dmactlr_e/devcfg_req(0)
add wave -noupdate /testbench/du_e/dmactlr_e/devcfg_rdy(0)
add wave -noupdate /testbench/du_e/dmactlr_e/devcfg_rdy(0)
add wave -noupdate /testbench/du_e/dmactlr_e/devcfg_rdy(1)
add wave -noupdate /testbench/du_e/dmactlr_e/devcfg_req
add wave -noupdate /testbench/du_e/dmactlr_e/devcfg_rdy
add wave -noupdate /testbench/du_e/dmactlr_e/dev_req
add wave -noupdate /testbench/du_e/dmactlr_e/dev_rdy
add wave -noupdate /testbench/du_e/dmactlr_e/dmargtrgnt_e/arb_req
TreeUpdate [SetDefaultTree]
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
WaveRestoreZoom {263388058880 fs} {281763058880 fs}
