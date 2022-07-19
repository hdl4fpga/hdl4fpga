onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {New Divider}
add wave -noupdate -expand -group phy1 /testbench/du_e/phy1_gtxclk
add wave -noupdate -expand -group phy1 -radix hexadecimal /testbench/du_e/phy1_rx_dv
add wave -noupdate -expand -group phy1 -radix hexadecimal /testbench/du_e/phy1_rx_d
add wave -noupdate -expand -group phy1 /testbench/du_e/phy1_tx_en
add wave -noupdate -expand -group phy1 /testbench/du_e/phy1_tx_d
add wave -noupdate -expand -group ddr3 /testbench/du_e/ddr3_clk
add wave -noupdate -expand -group ddr3 /testbench/du_e/ddr3_rst
add wave -noupdate -expand -group ddr3 /testbench/du_e/ddr3_cke
add wave -noupdate -expand -group ddr3 /testbench/du_e/ddr3_cs
add wave -noupdate -expand -group ddr3 /testbench/du_e/ddr3_ras
add wave -noupdate -expand -group ddr3 /testbench/du_e/ddr3_cas
add wave -noupdate -expand -group ddr3 /testbench/du_e/ddr3_we
add wave -noupdate -expand -group ddr3 -radix hexadecimal /testbench/du_e/ddr3_ba
add wave -noupdate -expand -group ddr3 -radix hexadecimal /testbench/du_e/ddr3_a
add wave -noupdate -expand -group ddr3 /testbench/du_e/ddr3_dm
add wave -noupdate -expand -group ddr3 -expand /testbench/du_e/ddr3_dqs
add wave -noupdate -expand -group ddr3 -radix hexadecimal /testbench/du_e/ddr3_dq
add wave -noupdate -expand -group ddr3 /testbench/du_e/ddr3_odt
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix hexadecimal -childformat {{/testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/dyndelay(7) -radix hexadecimal} {/testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/dyndelay(6) -radix hexadecimal} {/testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/dyndelay(5) -radix hexadecimal} {/testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/dyndelay(4) -radix hexadecimal} {/testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/dyndelay(3) -radix hexadecimal} {/testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/dyndelay(2) -radix hexadecimal} {/testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/dyndelay(1) -radix hexadecimal} {/testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/dyndelay(0) -radix hexadecimal}} -expand -subitemconfig {/testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/dyndelay(7) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/dyndelay(6) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/dyndelay(5) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/dyndelay(4) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/dyndelay(3) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/dyndelay(2) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/dyndelay(1) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/dyndelay(0) {-height 29 -radix hexadecimal}} /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/dyndelay
add wave -noupdate /testbench/du_e/ddrphy_e/eclk
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/dqsw
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/dqsdel
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/dqsbufd_i/eclk_quarter_period
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do_dv
add wave -noupdate /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/dqsbufd_i/rst
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/dqsbufd_i/sclk
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/dqsbufd_i/read
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/dqsbufd_i/eclk
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/dqsbufd_i/eclkw
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/dqsbufd_i/dqsdel
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/dqsbufd_i/dqsi
add wave -noupdate /testbench/du_e/ddrphy_e/dqsdll_b/line__345/q
add wave -noupdate -divider {New Divider}
add wave -noupdate -group dqsdllb /testbench/du_e/ddrphy_e/dqsdll_b/dqsdllb_i/LOCK_CYC
add wave -noupdate -group dqsdllb /testbench/du_e/ddrphy_e/dqsdll_b/dqsdllb_i/LOCK_SENSITIVITY
add wave -noupdate -group dqsdllb /testbench/du_e/ddrphy_e/dqsdll_b/dqsdllb_i/CLK
add wave -noupdate -group dqsdllb /testbench/du_e/ddrphy_e/dqsdll_b/dqsdllb_i/RST
add wave -noupdate -group dqsdllb /testbench/du_e/ddrphy_e/dqsdll_b/dqsdllb_i/UDDCNTLN
add wave -noupdate -group dqsdllb /testbench/du_e/ddrphy_e/dqsdll_b/dqsdllb_i/LOCK
add wave -noupdate -group dqsdllb /testbench/du_e/ddrphy_e/dqsdll_b/dqsdllb_i/DQSDEL
add wave -noupdate -group dqsdllb /testbench/du_e/ddrphy_e/dqsdll_b/dqsdllb_i/RST_int
add wave -noupdate -group dqsdllb /testbench/du_e/ddrphy_e/dqsdll_b/dqsdllb_i/UDDCNTL_int
add wave -noupdate -group dqsdllb /testbench/du_e/ddrphy_e/dqsdll_b/dqsdllb_i/LOCK_int
add wave -noupdate -group dqsdllb /testbench/du_e/ddrphy_e/dqsdll_b/dqsdllb_i/DQSDEL_int
add wave -noupdate -group dqsdllb /testbench/du_e/ddrphy_e/dqsdll_b/dqsdllb_i/clkin_in
add wave -noupdate -group dqsdllb /testbench/du_e/ddrphy_e/dqsdll_b/dqsdllb_i/clk_rising_edge_count
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {27361765 ps} 0} {{Cursor 2} {26088000 ps} 0}
quietly wave cursor active 2
configure wave -namecolwidth 212
configure wave -valuecolwidth 177
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
WaveRestoreZoom {10338 ns} {41838 ns}
