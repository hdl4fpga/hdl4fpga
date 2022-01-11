onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/du_e/sys_rst
add wave -noupdate /testbench/du_e/mii_rxc
add wave -noupdate /testbench/du_e/mii_rxdv
add wave -noupdate -radix hexadecimal /testbench/du_e/mii_rxd
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/mii_txc
add wave -noupdate /testbench/du_e/mii_txen
add wave -noupdate -radix hexadecimal /testbench/du_e/mii_txd
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix hexadecimal /testbench/du_e/ddr3_reset
add wave -noupdate -radix hexadecimal /testbench/du_e/ddr3_clk_p
add wave -noupdate -radix hexadecimal /testbench/du_e/ddr3_clk_n
add wave -noupdate -radix hexadecimal /testbench/du_e/ddr3_cke
add wave -noupdate -radix hexadecimal /testbench/du_e/ddr3_cs
add wave -noupdate -radix hexadecimal /testbench/du_e/ddr3_ras
add wave -noupdate -radix hexadecimal /testbench/du_e/ddr3_cas
add wave -noupdate -radix hexadecimal /testbench/du_e/ddr3_we
add wave -noupdate -radix hexadecimal /testbench/du_e/ddr3_ba
add wave -noupdate -radix hexadecimal /testbench/du_e/ddr3_a
add wave -noupdate -radix hexadecimal /testbench/du_e/ddr3_dq
add wave -noupdate /testbench/du_e/ddr3_dqs_p(1)
add wave -noupdate /testbench/du_e/ddr3_dqs_p(0)
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/ctlrphy_b
add wave -noupdate -radix hexadecimal -childformat {{/testbench/du_e/grahics_e/ctlrphy_a(13) -radix hexadecimal} {/testbench/du_e/grahics_e/ctlrphy_a(12) -radix hexadecimal} {/testbench/du_e/grahics_e/ctlrphy_a(11) -radix hexadecimal} {/testbench/du_e/grahics_e/ctlrphy_a(10) -radix hexadecimal} {/testbench/du_e/grahics_e/ctlrphy_a(9) -radix hexadecimal} {/testbench/du_e/grahics_e/ctlrphy_a(8) -radix hexadecimal} {/testbench/du_e/grahics_e/ctlrphy_a(7) -radix hexadecimal} {/testbench/du_e/grahics_e/ctlrphy_a(6) -radix hexadecimal} {/testbench/du_e/grahics_e/ctlrphy_a(5) -radix hexadecimal} {/testbench/du_e/grahics_e/ctlrphy_a(4) -radix hexadecimal} {/testbench/du_e/grahics_e/ctlrphy_a(3) -radix hexadecimal} {/testbench/du_e/grahics_e/ctlrphy_a(2) -radix hexadecimal} {/testbench/du_e/grahics_e/ctlrphy_a(1) -radix hexadecimal} {/testbench/du_e/grahics_e/ctlrphy_a(0) -radix hexadecimal}} -subitemconfig {/testbench/du_e/grahics_e/ctlrphy_a(13) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ctlrphy_a(12) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ctlrphy_a(11) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ctlrphy_a(10) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ctlrphy_a(9) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ctlrphy_a(8) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ctlrphy_a(7) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ctlrphy_a(6) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ctlrphy_a(5) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ctlrphy_a(4) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ctlrphy_a(3) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ctlrphy_a(2) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ctlrphy_a(1) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ctlrphy_a(0) {-height 29 -radix hexadecimal}} /testbench/du_e/grahics_e/ctlrphy_a
add wave -noupdate /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_b
add wave -noupdate /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_a
add wave -noupdate /testbench/du_e/grahics_e/ddrctlr_b/inirdy
add wave -noupdate /testbench/du_e/ddrphy_e/sys_wlreq
add wave -noupdate /testbench/du_e/ddrphy_e/sys_wlrdy
add wave -noupdate /testbench/du_e/ddrphy_e/sys_rlreq
add wave -noupdate /testbench/du_e/ddrphy_e/sys_rlrdy
add wave -noupdate /testbench/du_e/grahics_e/ctlrphy_irdy
add wave -noupdate /testbench/du_e/grahics_e/ctlrphy_trdy
add wave -noupdate /testbench/du_e/grahics_e/ctlrphy_ini
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ddr_init_e/ddr_init_pc
add wave -noupdate /testbench/du_e/ddrphy_e/phy_cmd_rdy
add wave -noupdate /testbench/du_e/ddrphy_e/phy_cmd_req
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {81890149 ps} 0}
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
WaveRestoreZoom {0 ps} {105 us}
