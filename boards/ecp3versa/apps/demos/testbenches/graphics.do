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
add wave -noupdate /testbench/du_e/ddrphy_e/phy_frm
add wave -noupdate /testbench/du_e/ddrphy_e/phy_ini
add wave -noupdate /testbench/du_e/ddrphy_e/read_leveling_l_b/ddr_act
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_trdy
add wave -noupdate /testbench/du_e/ddrphy_e/phy_trdy
add wave -noupdate /testbench/du_e/ddrphy_e/read_leveling_l_b/line__388/s_pre
add wave -noupdate /testbench/du_e/ddrphy_e/read_leveling_l_b/ddr_idle
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/read_rdy
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/read_req
add wave -noupdate /testbench/du_e/ddrphy_e/read_leveling_l_b/readcycle_p/state
add wave -noupdate /testbench/du_e/ddrphy_e/read_leveling_l_b/readcycle_p/z
add wave -noupdate /testbench/du_e/ddrphy_e/read_leveling_l_b/leveling
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do_dv
add wave -noupdate -radix hexadecimal -childformat {{/testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(63) -radix hexadecimal} {/testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(62) -radix hexadecimal} {/testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(61) -radix hexadecimal} {/testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(60) -radix hexadecimal} {/testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(59) -radix hexadecimal} {/testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(58) -radix hexadecimal} {/testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(57) -radix hexadecimal} {/testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(56) -radix hexadecimal} {/testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(55) -radix hexadecimal} {/testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(54) -radix hexadecimal} {/testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(53) -radix hexadecimal} {/testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(52) -radix hexadecimal} {/testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(51) -radix hexadecimal} {/testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(50) -radix hexadecimal} {/testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(49) -radix hexadecimal} {/testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(48) -radix hexadecimal} {/testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(47) -radix hexadecimal} {/testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(46) -radix hexadecimal} {/testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(45) -radix hexadecimal} {/testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(44) -radix hexadecimal} {/testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(43) -radix hexadecimal} {/testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(42) -radix hexadecimal} {/testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(41) -radix hexadecimal} {/testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(40) -radix hexadecimal} {/testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(39) -radix hexadecimal} {/testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(38) -radix hexadecimal} {/testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(37) -radix hexadecimal} {/testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(36) -radix hexadecimal} {/testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(35) -radix hexadecimal} {/testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(34) -radix hexadecimal} {/testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(33) -radix hexadecimal} {/testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(32) -radix hexadecimal} {/testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(31) -radix hexadecimal} {/testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(30) -radix hexadecimal} {/testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(29) -radix hexadecimal} {/testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(28) -radix hexadecimal} {/testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(27) -radix hexadecimal} {/testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(26) -radix hexadecimal} {/testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(25) -radix hexadecimal} {/testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(24) -radix hexadecimal} {/testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(23) -radix hexadecimal} {/testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(22) -radix hexadecimal} {/testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(21) -radix hexadecimal} {/testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(20) -radix hexadecimal} {/testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(19) -radix hexadecimal} {/testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(18) -radix hexadecimal} {/testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(17) -radix hexadecimal} {/testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(16) -radix hexadecimal} {/testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(15) -radix hexadecimal} {/testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(14) -radix hexadecimal} {/testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(13) -radix hexadecimal} {/testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(12) -radix hexadecimal} {/testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(11) -radix hexadecimal} {/testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(10) -radix hexadecimal} {/testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(9) -radix hexadecimal} {/testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(8) -radix hexadecimal} {/testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(7) -radix hexadecimal} {/testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(6) -radix hexadecimal} {/testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(5) -radix hexadecimal} {/testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(4) -radix hexadecimal} {/testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(3) -radix hexadecimal} {/testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(2) -radix hexadecimal} {/testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(1) -radix hexadecimal} {/testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(0) -radix hexadecimal}} -subitemconfig {/testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(63) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(62) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(61) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(60) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(59) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(58) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(57) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(56) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(55) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(54) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(53) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(52) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(51) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(50) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(49) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(48) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(47) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(46) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(45) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(44) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(43) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(42) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(41) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(40) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(39) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(38) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(37) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(36) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(35) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(34) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(33) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(32) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(31) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(30) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(29) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(28) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(27) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(26) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(25) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(24) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(23) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(22) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(21) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(20) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(19) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(18) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(17) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(16) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(15) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(14) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(13) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(12) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(11) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(10) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(9) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(8) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(7) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(6) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(5) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(4) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(3) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(2) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(1) {-height 29 -radix hexadecimal} /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do(0) {-height 29 -radix hexadecimal}} /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/dqsbufd_i/rst
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/dqsbufd_i/sclk
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/dqsbufd_i/read
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/dqsbufd_i/eclk
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/dqsbufd_i/eclkw
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/dqsbufd_i/dqsdel
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/dqsbufd_i/dqsi
add wave -noupdate /testbench/du_e/ddrphy_e/dqsdll_b/line__345/q
add wave -noupdate /testbench/du_e/ddrphy_e/phy_rlreq
add wave -noupdate /testbench/du_e/ddrphy_e/phy_rlrdy
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/phy_sti
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/read
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/datavalid
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/prmbdet
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/rl_b/lat
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
WaveRestoreCursors {{Cursor 1} {20777500 ps} 0} {{Cursor 2} {25722515 ps} 0}
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
WaveRestoreZoom {25630567 ps} {25841887 ps}
