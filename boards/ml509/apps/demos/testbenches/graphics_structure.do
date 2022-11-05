onerror {resume}
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

add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_dqs180
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_dqsi_b_adjsto_e_dqs_pre/O
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_sys_sto_0_Q
add wave -noupdate /testbench/du_e/ctlrphy_dqi
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/graphics_e_dev_do_dv(1)
add wave -noupdate /testbench/du_e/graphics_e_ctlr_do
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/ctlr_clks(0)
add wave -noupdate /testbench/du_e/ddr_clk0x2
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/ctlr_clks(1)
add wave -noupdate /testbench/du_e/ddr_clk90x2
add wave -noupdate -divider {New Divider}

add wave -noupdate -divider {sdrphy_e_phy_rlrdyDivider}
add wave -noupdate /testbench/du_e/sdrphy_e_phy_rlrdy/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_dqsi_b_adjsto_e_synced/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_dqsi_b_adjsto_e_synced/O
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/ddr2_dqs_p_0_INBUF_DS
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_sys_dqso_0_Q
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_dqsi_b_igbx_i_reg_g_0_iserdese_g_xv5_g_iser_i_O
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/ddr2_dqs_p_1_INBUF_DS
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_sys_dqso_0_Q
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_dqsi_b_igbx_i_reg_g_0_iserdese_g_xv5_g_iser_i_O

#################################
add wave -noupdate -divider {BYTE 0}
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_sys_rlrdy/O

add wave -noupdate -divider {Pause}
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_pause_req/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_pause_rdy/O

add wave -noupdate -divider {DQS Pause}
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_dqsi_b_adjdqs_e_step_req/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_dqspau_rdy/O

add wave -noupdate -divider {DQI Pause}
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_dqipause_req/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_dqipause_rdy/O

add wave -noupdate -divider {DQS delay}
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_dqsi_b_dqsidelay_i_xc5v_g_idelay_i_idelay_i/DATAOUT
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_dqsi_b_dqsidelay_i_xc5v_g_idelay_i_idelay_i/IDATAIN
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_dqsi_b_dqsidelay_i_xc5v_g_idelay_i_idelay_i/idelay_count
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_adjdqs_req/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_dqsi_b_adjdqs_e_rdy/O

add wave -noupdate -divider {DQI[0] delay}
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_datai_b_i_igbx_0_adjdqi_b_dqi_i_xc5v_g_idelay_i_idelay_i/idelay_count
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_adjdqi_req_0/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_datai_b_i_igbx_0_adjdqi_b_adjdqi_e_rdy/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_datai_b_i_igbx_0_adjdqi_b_adjdqi_e_step_req/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_dqipau_rdy_0/O

add wave -noupdate -divider {DQI[1] delay}
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_datai_b_i_igbx_1_adjdqi_b_dqi_i_xc5v_g_idelay_i_idelay_i/idelay_count
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_adjdqi_req_1/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_datai_b_i_igbx_1_adjdqi_b_adjdqi_e_rdy/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_datai_b_i_igbx_1_adjdqi_b_adjdqi_e_step_req/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_dqipau_rdy_1/O

add wave -noupdate -divider {DQI[2] delay}
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_datai_b_i_igbx_2_adjdqi_b_dqi_i_xc5v_g_idelay_i_idelay_i/idelay_count
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_adjdqi_req_2/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_datai_b_i_igbx_2_adjdqi_b_adjdqi_e_rdy/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_datai_b_i_igbx_2_adjdqi_b_adjdqi_e_step_req/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_dqipau_rdy_2/O

add wave -noupdate -divider {DQI[3] delay}
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_datai_b_i_igbx_3_adjdqi_b_dqi_i_xc5v_g_idelay_i_idelay_i/idelay_count
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_adjdqi_req_3/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_datai_b_i_igbx_3_adjdqi_b_adjdqi_e_rdy/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_datai_b_i_igbx_3_adjdqi_b_adjdqi_e_step_req/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_dqipau_rdy_3/O

add wave -noupdate -divider {DQI[4] delay}
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_datai_b_i_igbx_4_adjdqi_b_dqi_i_xc5v_g_idelay_i_idelay_i/idelay_count
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_adjdqi_req_4/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_datai_b_i_igbx_4_adjdqi_b_adjdqi_e_rdy/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_datai_b_i_igbx_4_adjdqi_b_adjdqi_e_step_req/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_dqipau_rdy_4/O

add wave -noupdate -divider {DQI[5] delay}
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_datai_b_i_igbx_5_adjdqi_b_dqi_i_xc5v_g_idelay_i_idelay_i/idelay_count
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_adjdqi_req_5/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_datai_b_i_igbx_5_adjdqi_b_adjdqi_e_rdy/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_datai_b_i_igbx_5_adjdqi_b_adjdqi_e_step_req/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_dqipau_rdy_5/O

add wave -noupdate -divider {DQI[6] delay}
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_datai_b_i_igbx_6_adjdqi_b_dqi_i_xc5v_g_idelay_i_idelay_i/idelay_count
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_adjdqi_req_6/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_datai_b_i_igbx_6_adjdqi_b_adjdqi_e_rdy/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_datai_b_i_igbx_6_adjdqi_b_adjdqi_e_step_req/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_dqipau_rdy_6/O

add wave -noupdate -divider {DQI[7] delay}
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_datai_b_i_igbx_7_adjdqi_b_dqi_i_xc5v_g_idelay_i_idelay_i/idelay_count
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_adjdqi_req_7/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_datai_b_i_igbx_7_adjdqi_b_adjdqi_e_rdy/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_datai_b_i_igbx_7_adjdqi_b_adjdqi_e_step_req/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrdqphy_i_dqipau_rdy_7/O

#################################
add wave -noupdate -divider {BYTE 1}
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_sys_rlrdy/O

add wave -noupdate -divider {Pause}
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_pause_req/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_pause_rdy/O

add wave -noupdate -divider {DQS Pause}
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_dqsi_b_adjdqs_e_step_req/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_dqspau_rdy/O

add wave -noupdate -divider {DQI Pause}
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_dqipause_req/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_dqipause_rdy/O

add wave -noupdate -divider {DQS delay}
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_dqsi_b_dqsidelay_i_xc5v_g_idelay_i_idelay_i/DATAOUT
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_dqsi_b_dqsidelay_i_xc5v_g_idelay_i_idelay_i/IDATAIN
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_dqsi_b_dqsidelay_i_xc5v_g_idelay_i_idelay_i/idelay_count
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_adjdqs_req/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_dqsi_b_adjdqs_e_rdy/O

add wave -noupdate -divider {DQI[0] delay}
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_datai_b_i_igbx_0_adjdqi_b_dqi_i_xc5v_g_idelay_i_idelay_i/idelay_count
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_adjdqi_req_0/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_datai_b_i_igbx_0_adjdqi_b_adjdqi_e_rdy/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_datai_b_i_igbx_0_adjdqi_b_adjdqi_e_step_req/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_dqipau_rdy_0/O

add wave -noupdate -divider {DQI[1] delay}
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_datai_b_i_igbx_1_adjdqi_b_dqi_i_xc5v_g_idelay_i_idelay_i/idelay_count
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_adjdqi_req_1/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_datai_b_i_igbx_1_adjdqi_b_adjdqi_e_rdy/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_datai_b_i_igbx_1_adjdqi_b_adjdqi_e_step_req/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_dqipau_rdy_1/O

add wave -noupdate -divider {DQI[2] delay}
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_datai_b_i_igbx_2_adjdqi_b_dqi_i_xc5v_g_idelay_i_idelay_i/idelay_count
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_adjdqi_req_2/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_datai_b_i_igbx_2_adjdqi_b_adjdqi_e_rdy/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_datai_b_i_igbx_2_adjdqi_b_adjdqi_e_step_req/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_dqipau_rdy_2/O

add wave -noupdate -divider {DQI[3] delay}
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_datai_b_i_igbx_3_adjdqi_b_dqi_i_xc5v_g_idelay_i_idelay_i/idelay_count
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_adjdqi_req_3/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_datai_b_i_igbx_3_adjdqi_b_adjdqi_e_rdy/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_datai_b_i_igbx_3_adjdqi_b_adjdqi_e_step_req/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_dqipau_rdy_3/O

add wave -noupdate -divider {DQI[4] delay}
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_datai_b_i_igbx_4_adjdqi_b_dqi_i_xc5v_g_idelay_i_idelay_i/idelay_count
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_adjdqi_req_4/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_datai_b_i_igbx_4_adjdqi_b_adjdqi_e_rdy/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_datai_b_i_igbx_4_adjdqi_b_adjdqi_e_step_req/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_dqipau_rdy_4/O

add wave -noupdate -divider {DQI[5] delay}
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_datai_b_i_igbx_5_adjdqi_b_dqi_i_xc5v_g_idelay_i_idelay_i/idelay_count
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_adjdqi_req_5/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_datai_b_i_igbx_5_adjdqi_b_adjdqi_e_rdy/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_datai_b_i_igbx_5_adjdqi_b_adjdqi_e_step_req/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_dqipau_rdy_5/O

add wave -noupdate -divider {DQI[6] delay}
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_datai_b_i_igbx_6_adjdqi_b_dqi_i_xc5v_g_idelay_i_idelay_i/idelay_count
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_adjdqi_req_6/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_datai_b_i_igbx_6_adjdqi_b_adjdqi_e_rdy/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_datai_b_i_igbx_6_adjdqi_b_adjdqi_e_step_req/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_dqipau_rdy_6/O

add wave -noupdate -divider {DQI[7] delay}
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_datai_b_i_igbx_7_adjdqi_b_dqi_i_xc5v_g_idelay_i_idelay_i/idelay_count
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_adjdqi_req_7/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_datai_b_i_igbx_7_adjdqi_b_adjdqi_e_rdy/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_datai_b_i_igbx_7_adjdqi_b_adjdqi_e_step_req/O
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_1_sdrdqphy_i_dqipau_rdy_7/O


add wave -noupdate -divider {New Divider}


add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/gpio_led
add wave -noupdate /testbench/du_e/gpio_led_c
add wave -noupdate /testbench/du_e/gpio_led_e
add wave -noupdate /testbench/du_e/gpio_led_n
add wave -noupdate /testbench/du_e/gpio_led_s
add wave -noupdate /testbench/du_e/gpio_led_w

TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {37153680 ps} 0} {{Cursor 2} {37740658 ps} 0}
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
