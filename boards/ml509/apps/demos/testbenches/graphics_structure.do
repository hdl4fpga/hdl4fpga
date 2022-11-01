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

add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_datai_b_i_igbx_1_adjdqi_b_dqi_i_xc5v_g_idelay_i_idelay_i/DATAOUT
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_datai_b_i_igbx_1_adjdqi_b_dqi_i_xc5v_g_idelay_i_idelay_i/IDATAIN
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_datai_b_i_igbx_1_adjdqi_b_dqi_i_xc5v_g_idelay_i_idelay_i/idelay_count
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_datai_b_i_igbx_1_igbx_g_data_gear4_g_igbx_i_reg_g_0_iserdese_g_xv5_g_iser_i/OCLK
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_dqsi_b_dqsidelay_i_xc5v_g_idelay_i_idelay_i/DATAOUT
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_dqsi_b_dqsidelay_i_xc5v_g_idelay_i_idelay_i/IDATAIN
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_dqsi_b_dqsidelay_i_xc5v_g_idelay_i_idelay_i/idelay_count
add wave -noupdate -divider {New Divider}

add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_adjdqs_req/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_dqsi_b_adjdqs_e_rdy/O

add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_dqsi_b_dqsidelay_i_xc5v_g_idelay_i_idelay_i/idelay_count
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_adjdqs_req/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_dqsi_b_adjdqs_e_rdy/O

add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_datai_b_i_igbx_0_adjdqi_b_dqi_i_xc5v_g_idelay_i_idelay_i/idelay_count
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_adjdqi_req_0/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_dqipau_rdy_0/O

add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_datai_b_i_igbx_1_adjdqi_b_dqi_i_xc5v_g_idelay_i_idelay_i/idelay_count
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_adjdqi_req_1/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_dqipau_rdy_1/O

add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_datai_b_i_igbx_2_adjdqi_b_dqi_i_xc5v_g_idelay_i_idelay_i/idelay_count
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_adjdqi_req_2/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_dqipau_rdy_2/O

add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_datai_b_i_igbx_3_adjdqi_b_dqi_i_xc5v_g_idelay_i_idelay_i/idelay_count
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_adjdqi_req_3/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_dqipau_rdy_3/O

add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_datai_b_i_igbx_4_adjdqi_b_dqi_i_xc5v_g_idelay_i_idelay_i/idelay_count
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_adjdqi_req_4/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_dqipau_rdy_4/O

add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_datai_b_i_igbx_5_adjdqi_b_dqi_i_xc5v_g_idelay_i_idelay_i/idelay_count
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_adjdqi_req_5/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_dqipau_rdy_5/O

add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_datai_b_i_igbx_6_adjdqi_b_dqi_i_xc5v_g_idelay_i_idelay_i/idelay_count
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_adjdqi_req_6/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_dqipau_rdy_6/O

add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_datai_b_i_igbx_7_adjdqi_b_dqi_i_xc5v_g_idelay_i_idelay_i/idelay_count
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_adjdqi_req_7/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_dqipau_rdy_7/O

add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_dqipause_req/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_dqipause_rdy/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_pause_req/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_pause_rdy/O


add wave -noupdate -divider {New Divider}


add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/gpio_led
add wave -noupdate /testbench/du_e/gpio_led_c
add wave -noupdate /testbench/du_e/gpio_led_e
add wave -noupdate /testbench/du_e/gpio_led_n
add wave -noupdate /testbench/du_e/gpio_led_s
add wave -noupdate /testbench/du_e/gpio_led_w

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
