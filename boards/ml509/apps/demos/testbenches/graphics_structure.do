onerror {resume}
quietly virtual signal -install /testbench/du_e { /testbench/du_e/ddr2_d(15 downto 0)} chip_dq0
quietly virtual signal -install /testbench/du_e { /testbench/du_e/ddr2_d(15 downto 0)} dq16
quietly virtual signal -install /testbench/du_e { /testbench/du_e/ddr2_d(7 downto 0)} dq8
quietly virtual signal -install /testbench/du_e { /testbench/du_e/gpio_led(2 to 7)} ppp
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group phy_rx /testbench/du_e/phy_rxclk
add wave -noupdate -expand -group phy_rx /testbench/du_e/phy_rxctl_rxdv
add wave -noupdate -expand -group phy_rx -radix hexadecimal -childformat {{/testbench/du_e/phy_rxd(0) -radix hexadecimal} {/testbench/du_e/phy_rxd(1) -radix hexadecimal} {/testbench/du_e/phy_rxd(2) -radix hexadecimal} {/testbench/du_e/phy_rxd(3) -radix hexadecimal} {/testbench/du_e/phy_rxd(4) -radix hexadecimal} {/testbench/du_e/phy_rxd(5) -radix hexadecimal} {/testbench/du_e/phy_rxd(6) -radix hexadecimal} {/testbench/du_e/phy_rxd(7) -radix hexadecimal}} -subitemconfig {/testbench/du_e/phy_rxd(0) {-height 29 -radix hexadecimal} /testbench/du_e/phy_rxd(1) {-height 29 -radix hexadecimal} /testbench/du_e/phy_rxd(2) {-height 29 -radix hexadecimal} /testbench/du_e/phy_rxd(3) {-height 29 -radix hexadecimal} /testbench/du_e/phy_rxd(4) {-height 29 -radix hexadecimal} /testbench/du_e/phy_rxd(5) {-height 29 -radix hexadecimal} /testbench/du_e/phy_rxd(6) {-height 29 -radix hexadecimal} /testbench/du_e/phy_rxd(7) {-height 29 -radix hexadecimal}} /testbench/du_e/phy_rxd
add wave -noupdate -expand -group phy_tx /testbench/du_e/phy_txclk
add wave -noupdate -expand -group phy_tx /testbench/du_e/phy_txctl_txen
add wave -noupdate -expand -group phy_tx -radix hexadecimal /testbench/du_e/phy_txd
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
add wave -noupdate -expand -group ddr2 -radix hexadecimal /testbench/du_e/dq8
add wave -noupdate -expand -group ddr2 -radix hexadecimal -childformat {{/testbench/du_e/dq16(15) -radix hexadecimal} {/testbench/du_e/dq16(14) -radix hexadecimal} {/testbench/du_e/dq16(13) -radix hexadecimal} {/testbench/du_e/dq16(12) -radix hexadecimal} {/testbench/du_e/dq16(11) -radix hexadecimal} {/testbench/du_e/dq16(10) -radix hexadecimal} {/testbench/du_e/dq16(9) -radix hexadecimal} {/testbench/du_e/dq16(8) -radix hexadecimal} {/testbench/du_e/dq16(7) -radix hexadecimal} {/testbench/du_e/dq16(6) -radix hexadecimal} {/testbench/du_e/dq16(5) -radix hexadecimal} {/testbench/du_e/dq16(4) -radix hexadecimal} {/testbench/du_e/dq16(3) -radix hexadecimal} {/testbench/du_e/dq16(2) -radix hexadecimal} {/testbench/du_e/dq16(1) -radix hexadecimal} {/testbench/du_e/dq16(0) -radix hexadecimal}} -subitemconfig {/testbench/du_e/ddr2_d(15) {-radix hexadecimal} /testbench/du_e/ddr2_d(14) {-radix hexadecimal} /testbench/du_e/ddr2_d(13) {-radix hexadecimal} /testbench/du_e/ddr2_d(12) {-radix hexadecimal} /testbench/du_e/ddr2_d(11) {-radix hexadecimal} /testbench/du_e/ddr2_d(10) {-radix hexadecimal} /testbench/du_e/ddr2_d(9) {-radix hexadecimal} /testbench/du_e/ddr2_d(8) {-radix hexadecimal} /testbench/du_e/ddr2_d(7) {-radix hexadecimal} /testbench/du_e/ddr2_d(6) {-radix hexadecimal} /testbench/du_e/ddr2_d(5) {-radix hexadecimal} /testbench/du_e/ddr2_d(4) {-radix hexadecimal} /testbench/du_e/ddr2_d(3) {-radix hexadecimal} /testbench/du_e/ddr2_d(2) {-radix hexadecimal} /testbench/du_e/ddr2_d(1) {-radix hexadecimal} /testbench/du_e/ddr2_d(0) {-radix hexadecimal}} /testbench/du_e/dq16
add wave -noupdate -expand -group ddr2 -radix hexadecimal -childformat {{/testbench/du_e/ddr2_d(63) -radix hexadecimal} {/testbench/du_e/ddr2_d(62) -radix hexadecimal} {/testbench/du_e/ddr2_d(61) -radix hexadecimal} {/testbench/du_e/ddr2_d(60) -radix hexadecimal} {/testbench/du_e/ddr2_d(59) -radix hexadecimal} {/testbench/du_e/ddr2_d(58) -radix hexadecimal} {/testbench/du_e/ddr2_d(57) -radix hexadecimal} {/testbench/du_e/ddr2_d(56) -radix hexadecimal} {/testbench/du_e/ddr2_d(55) -radix hexadecimal} {/testbench/du_e/ddr2_d(54) -radix hexadecimal} {/testbench/du_e/ddr2_d(53) -radix hexadecimal} {/testbench/du_e/ddr2_d(52) -radix hexadecimal} {/testbench/du_e/ddr2_d(51) -radix hexadecimal} {/testbench/du_e/ddr2_d(50) -radix hexadecimal} {/testbench/du_e/ddr2_d(49) -radix hexadecimal} {/testbench/du_e/ddr2_d(48) -radix hexadecimal} {/testbench/du_e/ddr2_d(47) -radix hexadecimal} {/testbench/du_e/ddr2_d(46) -radix hexadecimal} {/testbench/du_e/ddr2_d(45) -radix hexadecimal} {/testbench/du_e/ddr2_d(44) -radix hexadecimal} {/testbench/du_e/ddr2_d(43) -radix hexadecimal} {/testbench/du_e/ddr2_d(42) -radix hexadecimal} {/testbench/du_e/ddr2_d(41) -radix hexadecimal} {/testbench/du_e/ddr2_d(40) -radix hexadecimal} {/testbench/du_e/ddr2_d(39) -radix hexadecimal} {/testbench/du_e/ddr2_d(38) -radix hexadecimal} {/testbench/du_e/ddr2_d(37) -radix hexadecimal} {/testbench/du_e/ddr2_d(36) -radix hexadecimal} {/testbench/du_e/ddr2_d(35) -radix hexadecimal} {/testbench/du_e/ddr2_d(34) -radix hexadecimal} {/testbench/du_e/ddr2_d(33) -radix hexadecimal} {/testbench/du_e/ddr2_d(32) -radix hexadecimal} {/testbench/du_e/ddr2_d(31) -radix hexadecimal} {/testbench/du_e/ddr2_d(30) -radix hexadecimal} {/testbench/du_e/ddr2_d(29) -radix hexadecimal} {/testbench/du_e/ddr2_d(28) -radix hexadecimal} {/testbench/du_e/ddr2_d(27) -radix hexadecimal} {/testbench/du_e/ddr2_d(26) -radix hexadecimal} {/testbench/du_e/ddr2_d(25) -radix hexadecimal} {/testbench/du_e/ddr2_d(24) -radix hexadecimal} {/testbench/du_e/ddr2_d(23) -radix hexadecimal} {/testbench/du_e/ddr2_d(22) -radix hexadecimal} {/testbench/du_e/ddr2_d(21) -radix hexadecimal} {/testbench/du_e/ddr2_d(20) -radix hexadecimal} {/testbench/du_e/ddr2_d(19) -radix hexadecimal} {/testbench/du_e/ddr2_d(18) -radix hexadecimal} {/testbench/du_e/ddr2_d(17) -radix hexadecimal} {/testbench/du_e/ddr2_d(16) -radix hexadecimal} {/testbench/du_e/ddr2_d(15) -radix hexadecimal} {/testbench/du_e/ddr2_d(14) -radix hexadecimal} {/testbench/du_e/ddr2_d(13) -radix hexadecimal} {/testbench/du_e/ddr2_d(12) -radix hexadecimal} {/testbench/du_e/ddr2_d(11) -radix hexadecimal} {/testbench/du_e/ddr2_d(10) -radix hexadecimal} {/testbench/du_e/ddr2_d(9) -radix hexadecimal} {/testbench/du_e/ddr2_d(8) -radix hexadecimal} {/testbench/du_e/ddr2_d(7) -radix hexadecimal} {/testbench/du_e/ddr2_d(6) -radix hexadecimal} {/testbench/du_e/ddr2_d(5) -radix hexadecimal} {/testbench/du_e/ddr2_d(4) -radix hexadecimal} {/testbench/du_e/ddr2_d(3) -radix hexadecimal} {/testbench/du_e/ddr2_d(2) -radix hexadecimal} {/testbench/du_e/ddr2_d(1) -radix hexadecimal} {/testbench/du_e/ddr2_d(0) -radix hexadecimal}} -subitemconfig {/testbench/du_e/ddr2_d(63) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(62) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(61) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(60) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(59) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(58) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(57) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(56) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(55) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(54) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(53) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(52) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(51) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(50) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(49) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(48) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(47) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(46) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(45) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(44) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(43) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(42) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(41) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(40) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(39) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(38) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(37) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(36) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(35) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(34) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(33) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(32) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(31) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(30) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(29) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(28) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(27) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(26) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(25) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(24) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(23) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(22) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(21) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(20) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(19) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(18) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(17) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(16) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(15) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(14) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(13) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(12) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(11) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(10) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(9) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(8) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(7) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(6) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(5) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(4) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(3) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(2) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(1) {-height 29 -radix hexadecimal} /testbench/du_e/ddr2_d(0) {-height 29 -radix hexadecimal}} /testbench/du_e/ddr2_d
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_datai_b_i_igbx_1_adjdqi_b_dqi_i_xc5v_g_idelay_i_idelay_i/DATAOUT
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_datai_b_i_igbx_1_adjdqi_b_dqi_i_xc5v_g_idelay_i_idelay_i/IDATAIN
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_datai_b_i_igbx_1_adjdqi_b_dqi_i_xc5v_g_idelay_i_idelay_i/idelay_count
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_datai_b_i_igbx_1_igbx_g_data_gear4_g_igbx_i_reg_g_0_iserdese_g_xv5_g_iser_i/Q1
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_datai_b_i_igbx_1_igbx_g_data_gear4_g_igbx_i_reg_g_0_iserdese_g_xv5_g_iser_i/Q2
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_datai_b_i_igbx_1_igbx_g_data_gear4_g_igbx_i_reg_g_0_iserdese_g_xv5_g_iser_i/Q3
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_datai_b_i_igbx_1_igbx_g_data_gear4_g_igbx_i_reg_g_0_iserdese_g_xv5_g_iser_i/Q4
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_datai_b_i_igbx_1_igbx_g_data_gear4_g_igbx_i_reg_g_0_iserdese_g_xv5_g_iser_i/CLK
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_datai_b_i_igbx_1_igbx_g_data_gear4_g_igbx_i_reg_g_0_iserdese_g_xv5_g_iser_i/CLKB
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_datai_b_i_igbx_1_igbx_g_data_gear4_g_igbx_i_reg_g_0_iserdese_g_xv5_g_iser_i/CLKDIV
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_datai_b_i_igbx_1_igbx_g_data_gear4_g_igbx_i_reg_g_0_iserdese_g_xv5_g_iser_i/OCLK
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_dqsi_b_dqsidelay_i_xc5v_g_idelay_i_idelay_i/DATAOUT
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_dqsi_b_dqsidelay_i_xc5v_g_idelay_i_idelay_i/IDATAIN
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_dqsi_b_dqsidelay_i_xc5v_g_idelay_i_idelay_i/idelay_count
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_dqsi_b_igbx_i_reg_g_0_iserdese_g_xv5_g_iser_i/CLK
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_dqsi_b_igbx_i_reg_g_0_iserdese_g_xv5_g_iser_i/CLKB
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_dqsi_b_igbx_i_reg_g_0_iserdese_g_xv5_g_iser_i/CLKDIV
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_dqsi_b_igbx_i_reg_g_0_iserdese_g_xv5_g_iser_i/OCLK
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_dqsi_b_igbx_i_reg_g_0_iserdese_g_xv5_g_iser_i/Q1
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_dqsi_b_igbx_i_reg_g_0_iserdese_g_xv5_g_iser_i/Q2
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_dqsi_b_igbx_i_reg_g_0_iserdese_g_xv5_g_iser_i/Q3
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_dqsi_b_igbx_i_reg_g_0_iserdese_g_xv5_g_iser_i/Q4
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_adjdqs_req/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_dqsi_b_adjdqs_e_rdy/O
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_adjdqi_req_0/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_datai_b_i_igbx_0_adjdqi_b_adjdqi_e_rdy/O
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_dqsi_b_dqsidelay_i_xc5v_g_idelay_i_idelay_i/idelay_count
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_adjdqs_req/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_dqsi_b_adjdqs_e_rdy/O
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_datai_b_i_igbx_0_adjdqi_b_dqi_i_xc5v_g_idelay_i_idelay_i/idelay_count
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_adjdqi_req_0/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_datai_b_i_igbx_0_adjdqi_b_adjdqi_e_rdy/O
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_datai_b_i_igbx_0_adjdqi_b_adjdqi_e_step_req/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_dqipau_rdy_0/O
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_dqipause_req/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_dqipause_rdy/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_pause_req/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_pause_rdy/O
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_dqipau_rdy_0_Q 
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_dqipau_rdy_1_Q 
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_dqipau_rdy_2_Q 
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_dqipau_rdy_3_Q 
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_dqipau_rdy_4_Q 
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_dqipau_rdy_5_Q 
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_dqipau_rdy_6_Q 
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_dqipau_rdy_7_Q 
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_dqipau_rdy_0_Q 
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_dqipau_rdy_1_Q 
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_dqipau_rdy_2_Q 
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_dqipau_rdy_3_Q 
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_dqipau_rdy_4_Q 
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_dqipau_rdy_5_Q 
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_dqipau_rdy_6_Q 
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_dqipau_rdy_7_Q 
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/gpio_led
add wave -noupdate /testbench/du_e/gpio_led_c
add wave -noupdate /testbench/du_e/gpio_led_e
add wave -noupdate /testbench/du_e/gpio_led_n
add wave -noupdate /testbench/du_e/gpio_led_s
add wave -noupdate /testbench/du_e/gpio_led_w
add wave -noupdate -divider {New Divider}

TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {30653680 ps} 0} {{Cursor 2} {48740658 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 237
configure wave -valuecolwidth 172
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
WaveRestoreZoom {30544200 ps} {30763160 ps}
