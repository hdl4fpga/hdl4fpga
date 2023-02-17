onerror {resume}
quietly virtual signal -install /testbench/du_e { /testbench/du_e/ddr2_d(15 downto 0)} chip_dq0
quietly virtual signal -install /testbench/du_e { /testbench/du_e/ddr2_d(15 downto 0)} dq16
quietly virtual signal -install /testbench/du_e { /testbench/du_e/ddr2_d(7 downto 0)} dq8
quietly virtual signal -install /testbench/du_e/graphics_e {/testbench/du_e/graphics_e/sout_data  } xxx
quietly virtual signal -install /testbench/du_e/graphics_e { (context /testbench/du_e/graphics_e )( sout_data(7) & sout_data(6) & sout_data(5) & sout_data(4) & sout_data(3) & sout_data(2) & sout_data(1) & sout_data(0) )} rev_soutdata
quietly virtual signal -install /testbench/du_e { /testbench/du_e/ddr2_d(15 downto 0)} ddr2_d16
quietly virtual signal -install /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i { (context /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i )(dqspre & dqs180 )} xx
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group phy_rx /testbench/du_e/phy_rxclk
add wave -noupdate -expand -group phy_rx /testbench/du_e/phy_rxctl_rxdv
add wave -noupdate -expand -group phy_rx -radix hexadecimal -childformat {{/testbench/du_e/phy_rxd(0) -radix hexadecimal} {/testbench/du_e/phy_rxd(1) -radix hexadecimal} {/testbench/du_e/phy_rxd(2) -radix hexadecimal} {/testbench/du_e/phy_rxd(3) -radix hexadecimal} {/testbench/du_e/phy_rxd(4) -radix hexadecimal} {/testbench/du_e/phy_rxd(5) -radix hexadecimal} {/testbench/du_e/phy_rxd(6) -radix hexadecimal} {/testbench/du_e/phy_rxd(7) -radix hexadecimal}} -subitemconfig {/testbench/du_e/phy_rxd(0) {-height 29 -radix hexadecimal} /testbench/du_e/phy_rxd(1) {-height 29 -radix hexadecimal} /testbench/du_e/phy_rxd(2) {-height 29 -radix hexadecimal} /testbench/du_e/phy_rxd(3) {-height 29 -radix hexadecimal} /testbench/du_e/phy_rxd(4) {-height 29 -radix hexadecimal} /testbench/du_e/phy_rxd(5) {-height 29 -radix hexadecimal} /testbench/du_e/phy_rxd(6) {-height 29 -radix hexadecimal} /testbench/du_e/phy_rxd(7) {-height 29 -radix hexadecimal}} /testbench/du_e/phy_rxd
add wave -noupdate -expand -group phy_tx /testbench/du_e/phy_txclk
add wave -noupdate -expand -group phy_tx /testbench/du_e/phy_txctl_txen
add wave -noupdate -expand -group phy_tx -radix hexadecimal -childformat {{/testbench/du_e/phy_txd(0) -radix hexadecimal} {/testbench/du_e/phy_txd(1) -radix hexadecimal} {/testbench/du_e/phy_txd(2) -radix hexadecimal} {/testbench/du_e/phy_txd(3) -radix hexadecimal} {/testbench/du_e/phy_txd(4) -radix hexadecimal} {/testbench/du_e/phy_txd(5) -radix hexadecimal} {/testbench/du_e/phy_txd(6) -radix hexadecimal} {/testbench/du_e/phy_txd(7) -radix hexadecimal}} -subitemconfig {/testbench/du_e/phy_txd(0) {-height 29 -radix hexadecimal} /testbench/du_e/phy_txd(1) {-height 29 -radix hexadecimal} /testbench/du_e/phy_txd(2) {-height 29 -radix hexadecimal} /testbench/du_e/phy_txd(3) {-height 29 -radix hexadecimal} /testbench/du_e/phy_txd(4) {-height 29 -radix hexadecimal} /testbench/du_e/phy_txd(5) {-height 29 -radix hexadecimal} /testbench/du_e/phy_txd(6) {-height 29 -radix hexadecimal} /testbench/du_e/phy_txd(7) {-height 29 -radix hexadecimal}} /testbench/du_e/phy_txd
add wave -noupdate -expand -group ddr2 /testbench/du_e/ddr2_clk_p(0)
add wave -noupdate -expand -group ddr2 /testbench/du_e/ddr2_cs(0)
add wave -noupdate -expand -group ddr2 /testbench/du_e/ddr2_cke(0)
add wave -noupdate -expand -group ddr2 /testbench/du_e/ddr2_ras
add wave -noupdate -expand -group ddr2 /testbench/du_e/ddr2_cas
add wave -noupdate -expand -group ddr2 /testbench/du_e/ddr2_we
add wave -noupdate -expand -group ddr2 /testbench/du_e/ddr2_odt(0)
add wave -noupdate -expand -group ddr2 -radix hexadecimal -childformat {{/testbench/du_e/ddr2_a(13) -radix hexadecimal} {/testbench/du_e/ddr2_a(12) -radix hexadecimal} {/testbench/du_e/ddr2_a(11) -radix hexadecimal} {/testbench/du_e/ddr2_a(10) -radix hexadecimal} {/testbench/du_e/ddr2_a(9) -radix hexadecimal} {/testbench/du_e/ddr2_a(8) -radix hexadecimal} {/testbench/du_e/ddr2_a(7) -radix hexadecimal} {/testbench/du_e/ddr2_a(6) -radix hexadecimal} {/testbench/du_e/ddr2_a(5) -radix hexadecimal} {/testbench/du_e/ddr2_a(4) -radix hexadecimal} {/testbench/du_e/ddr2_a(3) -radix hexadecimal} {/testbench/du_e/ddr2_a(2) -radix hexadecimal} {/testbench/du_e/ddr2_a(1) -radix hexadecimal} {/testbench/du_e/ddr2_a(0) -radix hexadecimal}} -subitemconfig {/testbench/du_e/ddr2_a(13) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_a(12) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_a(11) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_a(10) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_a(9) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_a(8) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_a(7) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_a(6) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_a(5) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_a(4) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_a(3) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_a(2) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_a(1) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_a(0) {-height 29 -radix hexadecimal}} /testbench/du_e/ddr2_a
add wave -noupdate -expand -group ddr2 -radix hexadecimal -childformat {{/testbench/du_e/ddr2_ba(2) -radix hexadecimal} {/testbench/du_e/ddr2_ba(1) -radix hexadecimal} {/testbench/du_e/ddr2_ba(0) -radix hexadecimal}} -subitemconfig {/testbench/du_e/ddr2_ba(2) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_ba(1) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_ba(0) {-height 29 -radix hexadecimal}} /testbench/du_e/ddr2_ba
add wave -noupdate -expand -group ddr2 /testbench/du_e/ddr2_dqs_p(0)
add wave -noupdate -expand -group ddr2 /testbench/du_e/ddr2_dqs_p(1)
add wave -noupdate -expand -group ddr2 -radix hexadecimal -childformat {{/testbench/du_e/ddr2_d16(15) -radix hexadecimal} {/testbench/du_e/ddr2_d16(14) -radix hexadecimal} {/testbench/du_e/ddr2_d16(13) -radix hexadecimal} {/testbench/du_e/ddr2_d16(12) -radix hexadecimal} {/testbench/du_e/ddr2_d16(11) -radix hexadecimal} {/testbench/du_e/ddr2_d16(10) -radix hexadecimal} {/testbench/du_e/ddr2_d16(9) -radix hexadecimal} {/testbench/du_e/ddr2_d16(8) -radix hexadecimal} {/testbench/du_e/ddr2_d16(7) -radix hexadecimal} {/testbench/du_e/ddr2_d16(6) -radix hexadecimal} {/testbench/du_e/ddr2_d16(5) -radix hexadecimal} {/testbench/du_e/ddr2_d16(4) -radix hexadecimal} {/testbench/du_e/ddr2_d16(3) -radix hexadecimal} {/testbench/du_e/ddr2_d16(2) -radix hexadecimal} {/testbench/du_e/ddr2_d16(1) -radix hexadecimal} {/testbench/du_e/ddr2_d16(0) -radix hexadecimal}} -subitemconfig {/testbench/du_e/ddr2_d(15) {-radix hexadecimal} /testbench/du_e/ddr2_d(14) {-radix hexadecimal} /testbench/du_e/ddr2_d(13) {-radix hexadecimal} /testbench/du_e/ddr2_d(12) {-radix hexadecimal} /testbench/du_e/ddr2_d(11) {-radix hexadecimal} /testbench/du_e/ddr2_d(10) {-radix hexadecimal} /testbench/du_e/ddr2_d(9) {-radix hexadecimal} /testbench/du_e/ddr2_d(8) {-radix hexadecimal} /testbench/du_e/ddr2_d(7) {-radix hexadecimal} /testbench/du_e/ddr2_d(6) {-radix hexadecimal} /testbench/du_e/ddr2_d(5) {-radix hexadecimal} /testbench/du_e/ddr2_d(4) {-radix hexadecimal} /testbench/du_e/ddr2_d(3) {-radix hexadecimal} /testbench/du_e/ddr2_d(2) {-radix hexadecimal} /testbench/du_e/ddr2_d(1) {-radix hexadecimal} /testbench/du_e/ddr2_d(0) {-radix hexadecimal}} /testbench/du_e/ddr2_d16
add wave -noupdate -expand -group ddr2 -radix hexadecimal -childformat {{/testbench/du_e/ddr2_d(63) -radix hexadecimal} {/testbench/du_e/ddr2_d(62) -radix hexadecimal} {/testbench/du_e/ddr2_d(61) -radix hexadecimal} {/testbench/du_e/ddr2_d(60) -radix hexadecimal} {/testbench/du_e/ddr2_d(59) -radix hexadecimal} {/testbench/du_e/ddr2_d(58) -radix hexadecimal} {/testbench/du_e/ddr2_d(57) -radix hexadecimal} {/testbench/du_e/ddr2_d(56) -radix hexadecimal} {/testbench/du_e/ddr2_d(55) -radix hexadecimal} {/testbench/du_e/ddr2_d(54) -radix hexadecimal} {/testbench/du_e/ddr2_d(53) -radix hexadecimal} {/testbench/du_e/ddr2_d(52) -radix hexadecimal} {/testbench/du_e/ddr2_d(51) -radix hexadecimal} {/testbench/du_e/ddr2_d(50) -radix hexadecimal} {/testbench/du_e/ddr2_d(49) -radix hexadecimal} {/testbench/du_e/ddr2_d(48) -radix hexadecimal} {/testbench/du_e/ddr2_d(47) -radix hexadecimal} {/testbench/du_e/ddr2_d(46) -radix hexadecimal} {/testbench/du_e/ddr2_d(45) -radix hexadecimal} {/testbench/du_e/ddr2_d(44) -radix hexadecimal} {/testbench/du_e/ddr2_d(43) -radix hexadecimal} {/testbench/du_e/ddr2_d(42) -radix hexadecimal} {/testbench/du_e/ddr2_d(41) -radix hexadecimal} {/testbench/du_e/ddr2_d(40) -radix hexadecimal} {/testbench/du_e/ddr2_d(39) -radix hexadecimal} {/testbench/du_e/ddr2_d(38) -radix hexadecimal} {/testbench/du_e/ddr2_d(37) -radix hexadecimal} {/testbench/du_e/ddr2_d(36) -radix hexadecimal} {/testbench/du_e/ddr2_d(35) -radix hexadecimal} {/testbench/du_e/ddr2_d(34) -radix hexadecimal} {/testbench/du_e/ddr2_d(33) -radix hexadecimal} {/testbench/du_e/ddr2_d(32) -radix hexadecimal} {/testbench/du_e/ddr2_d(31) -radix hexadecimal} {/testbench/du_e/ddr2_d(30) -radix hexadecimal} {/testbench/du_e/ddr2_d(29) -radix hexadecimal} {/testbench/du_e/ddr2_d(28) -radix hexadecimal} {/testbench/du_e/ddr2_d(27) -radix hexadecimal} {/testbench/du_e/ddr2_d(26) -radix hexadecimal} {/testbench/du_e/ddr2_d(25) -radix hexadecimal} {/testbench/du_e/ddr2_d(24) -radix hexadecimal} {/testbench/du_e/ddr2_d(23) -radix hexadecimal} {/testbench/du_e/ddr2_d(22) -radix hexadecimal} {/testbench/du_e/ddr2_d(21) -radix hexadecimal} {/testbench/du_e/ddr2_d(20) -radix hexadecimal} {/testbench/du_e/ddr2_d(19) -radix hexadecimal} {/testbench/du_e/ddr2_d(18) -radix hexadecimal} {/testbench/du_e/ddr2_d(17) -radix hexadecimal} {/testbench/du_e/ddr2_d(16) -radix hexadecimal} {/testbench/du_e/ddr2_d(15) -radix hexadecimal} {/testbench/du_e/ddr2_d(14) -radix hexadecimal} {/testbench/du_e/ddr2_d(13) -radix hexadecimal} {/testbench/du_e/ddr2_d(12) -radix hexadecimal} {/testbench/du_e/ddr2_d(11) -radix hexadecimal} {/testbench/du_e/ddr2_d(10) -radix hexadecimal} {/testbench/du_e/ddr2_d(9) -radix hexadecimal} {/testbench/du_e/ddr2_d(8) -radix hexadecimal} {/testbench/du_e/ddr2_d(7) -radix hexadecimal} {/testbench/du_e/ddr2_d(6) -radix hexadecimal} {/testbench/du_e/ddr2_d(5) -radix hexadecimal} {/testbench/du_e/ddr2_d(4) -radix hexadecimal} {/testbench/du_e/ddr2_d(3) -radix hexadecimal} {/testbench/du_e/ddr2_d(2) -radix hexadecimal} {/testbench/du_e/ddr2_d(1) -radix hexadecimal} {/testbench/du_e/ddr2_d(0) -radix hexadecimal}} -subitemconfig {/testbench/du_e/ddr2_d(63) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(62) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(61) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(60) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(59) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(58) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(57) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(56) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(55) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(54) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(53) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(52) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(51) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(50) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(49) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(48) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(47) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(46) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(45) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(44) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(43) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(42) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(41) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(40) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(39) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(38) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(37) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(36) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(35) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(34) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(33) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(32) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(31) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(30) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(29) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(28) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(27) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(26) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(25) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(24) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(23) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(22) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(21) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(20) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(19) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(18) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(17) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(16) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(15) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(14) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(13) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(12) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(11) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(10) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(9) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(8) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(7) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(6) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(5) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(4) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(3) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(2) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(1) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(0) {-height 29 -radix hexadecimal}} /testbench/du_e/ddr2_d
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datai_b/i_igbx(1)/igbx_g/data_gear4_g/igbx_i/d(0)
add wave -noupdate /testbench/du_e/sdrphy_e/clk0x2
add wave -noupdate /testbench/du_e/sdrphy_e/clk90
add wave -noupdate /testbench/du_e/sdrphy_e/clk0
add wave -noupdate /testbench/du_e/sdrphy_e/clk90x2
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix hexadecimal /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do_dv
add wave -noupdate /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do_dv(7)
add wave -noupdate -radix hexadecimal /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/data_align
add wave -noupdate -divider {New Divider}
add wave -noupdate -expand /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/sys_sti
add wave -noupdate -expand /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/sys_sto
add wave -noupdate -radix hexadecimal /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/sys_dqo
add wave -noupdate /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datai_b/i_igbx(0)/igbx_g/data_gear4_g/q1
add wave -noupdate /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datai_b/i_igbx(0)/igbx_g/data_gear4_g/q2
add wave -noupdate -radix hexadecimal /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/dq
add wave -noupdate -radix hexadecimal /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/sdram_dqi
add wave -noupdate /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/xx
add wave -noupdate /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/dqspre
add wave -noupdate /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/dqs180
add wave -noupdate -divider {New Divider}
add wave -noupdate -group mii_ipoe /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ethrx_e/fcs_sb
add wave -noupdate -group mii_ipoe /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ethrx_e/fcs_vld
add wave -noupdate -group mii_ipoe -radix hexadecimal /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ethrx_e/fcs_rem
add wave -noupdate -group arpd_e -expand -group arprx_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/arpd_e/arprx_e/mii_clk
add wave -noupdate -group arpd_e -expand -group arprx_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/arpd_e/arprx_e/arp_frm
add wave -noupdate -group arpd_e -expand -group arprx_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/arpd_e/arprx_e/arp_irdy
add wave -noupdate -group arpd_e -expand -group arprx_e -radix hexadecimal /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/arpd_e/arprx_e/arp_data
add wave -noupdate -group arpd_e -expand -group arprx_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/arpd_e/arprx_e/tpa_frm
add wave -noupdate -group arpd_e -expand -group arprx_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/arpd_e/arprx_e/frm_ptr
add wave -noupdate -group arpd_e -group arptx_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/arpd_e/arptx_e/pa_frm
add wave -noupdate -group arpd_e -group arptx_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/arpd_e/arptx_e/pa_irdy
add wave -noupdate -group arpd_e -group arptx_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/arpd_e/arptx_e/pa_trdy
add wave -noupdate -group arpd_e -group arptx_e -radix hexadecimal /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/arpd_e/arptx_e/pa_data
add wave -noupdate -group arpd_e -group arptx_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/arpd_e/arptx_e/pa_end
add wave -noupdate -group arpd_e -group arptx_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/arpd_e/arptx_e/arp_frm
add wave -noupdate -group arpd_e -group arptx_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/arpd_e/arptx_e/arp_irdy
add wave -noupdate -group arpd_e -group arptx_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/arpd_e/arptx_e/arp_trdy
add wave -noupdate -group arpd_e -group arptx_e -radix hexadecimal /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/arpd_e/arptx_e/arp_data
add wave -noupdate -group arpd_e -group arptx_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/arpd_e/arptx_e/pa_frm
add wave -noupdate -group arpd_e -group arptx_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/arpd_e/arptx_e/pa_irdy
add wave -noupdate -group arpd_e -group arptx_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/arpd_e/arptx_e/pa_trdy
add wave -noupdate -group arpd_e -group arptx_e -radix hexadecimal /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/arpd_e/arptx_e/pa_data
add wave -noupdate -group arpd_e -group arptx_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/arpd_e/arptx_e/pa_end
add wave -noupdate -group arpd_e -group arptx_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/arpd_e/arptx_e/arp_frm
add wave -noupdate -group arpd_e -group arptx_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/arpd_e/arptx_e/arp_irdy
add wave -noupdate -group arpd_e -group arptx_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/arpd_e/arptx_e/arp_trdy
add wave -noupdate -group arpd_e -group arptx_e -radix hexadecimal /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/arpd_e/arptx_e/arp_data
add wave -noupdate -group arpd_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/arpd_e/arprx_frm
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/mii_clk
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/pl_frm
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/pl_irdy
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/pl_trdy
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/pl_end
add wave -noupdate -group ipv4_tx -radix hexadecimal /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/pl_data
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4a_frm
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4a_irdy
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4a_end
add wave -noupdate -group ipv4_tx -radix hexadecimal /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4a_data
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4len_frm
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4len_irdy
add wave -noupdate -group ipv4_tx -radix hexadecimal /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4len_data
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/dlltx_irdy
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/dlltx_end
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/nettx_irdy
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/nettx_end
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4len_frm
add wave -noupdate -group ipv4_tx -divider {New Divider}
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4shdr_frm
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4shdr_irdy
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4shdr_trdy
add wave -noupdate -group ipv4_tx -radix hexadecimal /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4shdr_data
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4shdr_end
add wave -noupdate -group ipv4_tx -divider {New Divider}
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4proto_frm
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4proto_end
add wave -noupdate -group ipv4_tx -radix hexadecimal /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4hdr_data
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/state
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/cksm_irdy
add wave -noupdate -group ipv4_tx -radix hexadecimal /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/cksm_data
add wave -noupdate -group ipv4_tx -radix hexadecimal /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4chsm_data
add wave -noupdate -group ipv4_tx -divider {New Divider}
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4_frm
add wave -noupdate -group ipv4_tx -radix hexadecimal /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/frm_ptr
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4_irdy
add wave -noupdate -group ipv4_tx -divider {New Divider}
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/meta_b/hwda_e/si_irdy
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4_trdy
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4_end
add wave -noupdate -group ipv4_tx -radix hexadecimal -childformat {{/testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4_data(0) -radix hexadecimal} {/testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4_data(1) -radix hexadecimal} {/testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4_data(2) -radix hexadecimal} {/testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4_data(3) -radix hexadecimal} {/testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4_data(4) -radix hexadecimal} {/testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4_data(5) -radix hexadecimal} {/testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4_data(6) -radix hexadecimal} {/testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4_data(7) -radix hexadecimal}} -subitemconfig {/testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4_data(0) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4_data(1) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4_data(2) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4_data(3) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4_data(4) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4_data(5) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4_data(6) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4_data(7) {-height 29 -radix hexadecimal}} /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4_data
add wave -noupdate -divider {New Divider}
add wave -noupdate -group icmprply_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/icmpd_b/icmpd_e/icmprply_e/mii_clk
add wave -noupdate -group icmprply_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/icmpd_b/icmpd_e/icmprply_e/pl_frm
add wave -noupdate -group icmprply_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/icmpd_b/icmpd_e/icmprply_e/pl_irdy
add wave -noupdate -group icmprply_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/icmpd_b/icmpd_e/icmprply_e/pl_trdy
add wave -noupdate -group icmprply_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/icmpd_b/icmpd_e/icmprply_e/pl_end
add wave -noupdate -group icmprply_e -radix hexadecimal /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/icmpd_b/icmpd_e/icmprply_e/pl_data
add wave -noupdate -group icmprply_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/icmpd_b/icmpd_e/icmprply_e/metatx_end
add wave -noupdate -group icmprply_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/icmpd_b/icmpd_e/icmprply_e/icmpcksm_frm
add wave -noupdate -group icmprply_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/icmpd_b/icmpd_e/icmprply_e/icmp_frm
add wave -noupdate -group icmprply_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/icmpd_b/icmpd_e/icmprply_e/icmp_irdy
add wave -noupdate -group icmprply_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/icmpd_b/icmpd_e/icmprply_e/icmp_trdy
add wave -noupdate -group icmprply_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/icmpd_b/icmpd_e/icmprply_e/icmp_end
add wave -noupdate -group icmprply_e -radix hexadecimal /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/icmpd_b/icmpd_e/icmprply_e/icmp_data
add wave -noupdate -group icmprply_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/icmpd_b/icmpd_e/icmprply_e/frm_ptr
add wave -noupdate -divider {New Divider}
add wave -noupdate -group dhcpcd_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpcd_req
add wave -noupdate -group dhcpcd_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpcd_rdy
add wave -noupdate -group dhcpcd_e -expand -group dhcpdscb_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/mii_clk
add wave -noupdate -group dhcpcd_e -expand -group dhcpdscb_e -radix hexadecimal /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dhcp_sp
add wave -noupdate -group dhcpcd_e -expand -group dhcpdscb_e -radix hexadecimal /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dhcp_dp
add wave -noupdate -group dhcpcd_e -expand -group dhcpdscb_e -radix hexadecimal /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dhcp_mac
add wave -noupdate -group dhcpcd_e -expand -group dhcpdscb_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dhcpdscb_frm
add wave -noupdate -group dhcpcd_e -expand -group dhcpdscb_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dlltx_end
add wave -noupdate -group dhcpcd_e -expand -group dhcpdscb_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/netlentx_irdy
add wave -noupdate -group dhcpcd_e -expand -group dhcpdscb_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/netlentx_end
add wave -noupdate -group dhcpcd_e -expand -group dhcpdscb_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/netdatx_irdy
add wave -noupdate -group dhcpcd_e -expand -group dhcpdscb_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/netdatx_end
add wave -noupdate -group dhcpcd_e -expand -group dhcpdscb_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dhcpdscb_irdy
add wave -noupdate -group dhcpcd_e -expand -group dhcpdscb_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dhcpdscb_trdy
add wave -noupdate -group dhcpcd_e -expand -group dhcpdscb_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dhcpdscb_end
add wave -noupdate -group dhcpcd_e -expand -group dhcpdscb_e -radix hexadecimal -childformat {{/testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dhcpdscb_data(0) -radix hexadecimal} {/testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dhcpdscb_data(1) -radix hexadecimal} {/testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dhcpdscb_data(2) -radix hexadecimal} {/testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dhcpdscb_data(3) -radix hexadecimal} {/testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dhcpdscb_data(4) -radix hexadecimal} {/testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dhcpdscb_data(5) -radix hexadecimal} {/testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dhcpdscb_data(6) -radix hexadecimal} {/testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dhcpdscb_data(7) -radix hexadecimal}} -subitemconfig {/testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dhcpdscb_data(0) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dhcpdscb_data(1) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dhcpdscb_data(2) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dhcpdscb_data(3) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dhcpdscb_data(4) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dhcpdscb_data(5) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dhcpdscb_data(6) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dhcpdscb_data(7) {-height 29 -radix hexadecimal}} /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dhcpdscb_data
add wave -noupdate -group dhcpcd_e -expand -group dhcpdscb_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/mii_clk
add wave -noupdate -group dhcpcd_e -expand -group dhcpdscb_e -radix hexadecimal /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dhcp_sp
add wave -noupdate -group dhcpcd_e -expand -group dhcpdscb_e -radix hexadecimal /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dhcp_dp
add wave -noupdate -group dhcpcd_e -expand -group dhcpdscb_e -radix hexadecimal /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dhcp_mac
add wave -noupdate -group dhcpcd_e -expand -group dhcpdscb_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dhcpdscb_frm
add wave -noupdate -group dhcpcd_e -expand -group dhcpdscb_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dlltx_end
add wave -noupdate -group dhcpcd_e -expand -group dhcpdscb_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/netlentx_irdy
add wave -noupdate -group dhcpcd_e -expand -group dhcpdscb_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/netlentx_end
add wave -noupdate -group dhcpcd_e -expand -group dhcpdscb_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/netdatx_irdy
add wave -noupdate -group dhcpcd_e -expand -group dhcpdscb_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/netdatx_end
add wave -noupdate -group dhcpcd_e -expand -group dhcpdscb_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/net_end
add wave -noupdate -group dhcpcd_e -expand -group dhcpdscb_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dhcpdscb_trdy
add wave -noupdate -group dhcpcd_e -expand -group dhcpdscb_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dhcpdscb_irdy
add wave -noupdate -group dhcpcd_e -expand -group dhcpdscb_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dhcpdscb_end
add wave -noupdate -group dhcpcd_e -expand -group dhcpdscb_e -radix hexadecimal -childformat {{/testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dhcpdscb_data(0) -radix hexadecimal} {/testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dhcpdscb_data(1) -radix hexadecimal} {/testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dhcpdscb_data(2) -radix hexadecimal} {/testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dhcpdscb_data(3) -radix hexadecimal} {/testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dhcpdscb_data(4) -radix hexadecimal} {/testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dhcpdscb_data(5) -radix hexadecimal} {/testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dhcpdscb_data(6) -radix hexadecimal} {/testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dhcpdscb_data(7) -radix hexadecimal}} -subitemconfig {/testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dhcpdscb_data(0) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dhcpdscb_data(1) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dhcpdscb_data(2) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dhcpdscb_data(3) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dhcpdscb_data(4) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dhcpdscb_data(5) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dhcpdscb_data(6) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dhcpdscb_data(7) {-height 29 -radix hexadecimal}} /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dhcpdscb_data
add wave -noupdate -group dhcpcd_e -expand -group dhcpdscb_e -radix hexadecimal /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dhcpdscb_ptr
add wave -noupdate -group dhcpcd_e -expand -group dhcpdscb_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dhcppkt_irdy
add wave -noupdate -group dhcpcd_e -expand -group dhcpdscb_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dhcppkt_trdy
add wave -noupdate -group dhcpcd_e -expand -group dhcpdscb_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dhcppkt_ena
add wave -noupdate -group dhcpcd_e -expand -group dhcpdscb_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dhcppkt_end
add wave -noupdate -group dhcpcd_e -expand -group dhcpdscb_e -radix hexadecimal /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dhcppkt_data
add wave -noupdate -divider {New Divider}
add wave -noupdate -group udptx_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/udptx_b/udptx_e/mii_clk
add wave -noupdate -group udptx_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/udptx_b/udptx_e/pl_frm
add wave -noupdate -group udptx_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/udptx_b/udptx_e/pl_irdy
add wave -noupdate -group udptx_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/udptx_b/udptx_e/pl_trdy
add wave -noupdate -group udptx_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/udptx_b/udptx_e/pl_end
add wave -noupdate -group udptx_e -radix hexadecimal /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/udptx_b/udptx_e/pl_data
add wave -noupdate -group udptx_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/udptx_b/udptx_e/udp_frm
add wave -noupdate -group udptx_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/udptx_b/udptx_e/dlltx_irdy
add wave -noupdate -group udptx_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/udptx_b/udptx_e/dlltx_end
add wave -noupdate -group udptx_e -radix hexadecimal /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/udptx_b/udptx_e/dlltx_data
add wave -noupdate -group udptx_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/udptx_b/udptx_e/netdatx_irdy
add wave -noupdate -group udptx_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/udptx_b/udptx_e/netdatx_end
add wave -noupdate -group udptx_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/udptx_b/udptx_e/netlentx_irdy
add wave -noupdate -group udptx_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/udptx_b/udptx_e/netlentx_end
add wave -noupdate -group udptx_e -radix hexadecimal /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/udptx_b/udptx_e/netlentx_data
add wave -noupdate -group udptx_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/udptx_b/udptx_e/tptsp_irdy
add wave -noupdate -group udptx_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/udptx_b/udptx_e/tptsp_end
add wave -noupdate -group udptx_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/udptx_b/udptx_e/tptdp_irdy
add wave -noupdate -group udptx_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/udptx_b/udptx_e/tptdp_end
add wave -noupdate -group udptx_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/udptx_b/udptx_e/tptlen_irdy
add wave -noupdate -group udptx_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/udptx_b/udptx_e/tptlen_end
add wave -noupdate -group udptx_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/udptx_b/udptx_e/tpttx_end
add wave -noupdate -group udptx_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/udptx_b/udptx_e/udpsp_irdy
add wave -noupdate -group udptx_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/udptx_b/udptx_e/udpsp_end
add wave -noupdate -group udptx_e -radix hexadecimal /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/udptx_b/udptx_e/udpsp_data
add wave -noupdate -group udptx_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/udptx_b/udptx_e/udpdp_irdy
add wave -noupdate -group udptx_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/udptx_b/udptx_e/udpdp_end
add wave -noupdate -group udptx_e -radix hexadecimal /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/udptx_b/udptx_e/udpdp_data
add wave -noupdate -group udptx_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/udptx_b/udptx_e/udplen_irdy
add wave -noupdate -group udptx_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/udptx_b/udptx_e/udplen_end
add wave -noupdate -group udptx_e -radix hexadecimal /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/udptx_b/udptx_e/udplen_data
add wave -noupdate -group udptx_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/udptx_b/udptx_e/udp_irdy
add wave -noupdate -group udptx_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/udptx_b/udptx_e/udp_trdy
add wave -noupdate -group udptx_e -radix hexadecimal /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/udptx_b/udptx_e/udp_data
add wave -noupdate -group udptx_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/udptx_b/udptx_e/udp_end
add wave -noupdate -group udptx_e -radix hexadecimal /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/udptx_b/udptx_e/frm_ptr
add wave -noupdate -group udptx_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/udptx_b/udptx_e/cksm_irdy
add wave -noupdate -group udptx_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/udptx_b/udptx_e/cksm_end
add wave -noupdate -group udptx_e -radix hexadecimal /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/udptx_b/udptx_e/cksm_data
add wave -noupdate -group udptx_e -radix hexadecimal /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/udptx_b/udptx_e/so_sum
add wave -noupdate -group udptx_e -radix hexadecimal /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/udptx_b/udptx_e/so_sum1
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/sdram_sch_e/strl_tab
add wave -noupdate /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/sdram_sch_e/rwnl_tab
add wave -noupdate /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/sdram_sch_e/dqszl_tab
add wave -noupdate /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/sdram_sch_e/dqsol_tab
add wave -noupdate /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/sdram_sch_e/dqzl_tab
add wave -noupdate /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/sdram_sch_e/wwnl_tab
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {58021527 ps} 0} {{Cursor 2} {58035955 ps} 0}
quietly wave cursor active 2
configure wave -namecolwidth 185
configure wave -valuecolwidth 210
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
WaveRestoreZoom {58001528 ps} {58069333 ps}
