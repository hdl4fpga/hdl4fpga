onerror {resume}
quietly virtual signal -install /testbench/du_e { (context /testbench/du_e )(graphics_e_dmaso_data_63 & graphics_e_dmaso_data_62 & graphics_e_dmaso_data_61 & graphics_e_dmaso_data_60 & graphics_e_dmaso_data_59 & graphics_e_dmaso_data_58 & graphics_e_dmaso_data_57 & graphics_e_dmaso_data_56 & graphics_e_dmaso_data_55 & graphics_e_dmaso_data_54 & graphics_e_dmaso_data_53 & graphics_e_dmaso_data_52 & graphics_e_dmaso_data_51 & graphics_e_dmaso_data_50 & graphics_e_dmaso_data_49 & graphics_e_dmaso_data_48 & graphics_e_dmaso_data_47 & graphics_e_dmaso_data_46 & graphics_e_dmaso_data_45 & graphics_e_dmaso_data_44 & graphics_e_dmaso_data_43 & graphics_e_dmaso_data_42 & graphics_e_dmaso_data_41 & graphics_e_dmaso_data_40 & graphics_e_dmaso_data_39 & graphics_e_dmaso_data_38 & graphics_e_dmaso_data_37 & graphics_e_dmaso_data_36 & graphics_e_dmaso_data_35 & graphics_e_dmaso_data_34 & graphics_e_dmaso_data_33 & graphics_e_dmaso_data_32 & graphics_e_dmaso_data_31 & graphics_e_dmaso_data_30 & graphics_e_dmaso_data_29 & graphics_e_dmaso_data_28 & graphics_e_dmaso_data_27 & graphics_e_dmaso_data_26 & graphics_e_dmaso_data_25 & graphics_e_dmaso_data_24 & graphics_e_dmaso_data_23 & graphics_e_dmaso_data_22 & graphics_e_dmaso_data_21 & graphics_e_dmaso_data_20 & graphics_e_dmaso_data_19 & graphics_e_dmaso_data_18 & graphics_e_dmaso_data_17 & graphics_e_dmaso_data_16 & graphics_e_dmaso_data_15 & graphics_e_dmaso_data_14 & graphics_e_dmaso_data_13 & graphics_e_dmaso_data_12 & graphics_e_dmaso_data_11 & graphics_e_dmaso_data_10 & graphics_e_dmaso_data_9 & graphics_e_dmaso_data_8 & graphics_e_dmaso_data_7 & graphics_e_dmaso_data_6 & graphics_e_dmaso_data_5 & graphics_e_dmaso_data_4 & graphics_e_dmaso_data_3 & graphics_e_dmaso_data_2 & graphics_e_dmaso_data_1 & graphics_e_dmaso_data_0 )} data
quietly virtual signal -install /testbench/du_e { (context /testbench/du_e )(graphics_e_sdrctlr_b_sdrctlr_e_sdram_init_e_sdram_timer_b_timer_b_timer_e_cntr_0 & graphics_e_sdrctlr_b_sdrctlr_e_sdram_init_e_sdram_timer_b_timer_b_timer_e_cntr_1 & graphics_e_sdrctlr_b_sdrctlr_e_sdram_init_e_sdram_timer_b_timer_b_timer_e_cntr_2 & graphics_e_sdrctlr_b_sdrctlr_e_sdram_init_e_sdram_timer_b_timer_b_timer_e_cntr_3 & graphics_e_sdrctlr_b_sdrctlr_e_sdram_init_e_sdram_timer_b_timer_b_timer_e_cntr_4 & graphics_e_sdrctlr_b_sdrctlr_e_sdram_init_e_sdram_timer_b_timer_b_timer_e_cntr_5 )} timer_cntr0
quietly virtual signal -install /testbench/du_e { (context /testbench/du_e )(graphics_e_sdrctlr_b_sdrctlr_e_sdram_init_e_sdram_timer_b_timer_b_timer_e_cntr_0_0 & graphics_e_sdrctlr_b_sdrctlr_e_sdram_init_e_sdram_timer_b_timer_b_timer_e_cntr_0_1 & graphics_e_sdrctlr_b_sdrctlr_e_sdram_init_e_sdram_timer_b_timer_b_timer_e_cntr_0_2 & graphics_e_sdrctlr_b_sdrctlr_e_sdram_init_e_sdram_timer_b_timer_b_timer_e_cntr_0_3 & graphics_e_sdrctlr_b_sdrctlr_e_sdram_init_e_sdram_timer_b_timer_b_timer_e_cntr_0_4 )} timer_cntr2001
quietly virtual signal -install /testbench/du_e {/testbench/du_e/timer_cntr2001  } timer_cntr3
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group ddram /testbench/du_e/ddram_clk
add wave -noupdate -expand -group ddram /testbench/du_e/ddram_reset_n
add wave -noupdate -expand -group ddram /testbench/du_e/ddram_cke
add wave -noupdate -expand -group ddram /testbench/du_e/ddram_cs_n
add wave -noupdate -expand -group ddram /testbench/du_e/ddram_ras_n
add wave -noupdate -expand -group ddram /testbench/du_e/ddram_cas_n
add wave -noupdate -expand -group ddram /testbench/du_e/ddram_we_n
add wave -noupdate -expand -group ddram /testbench/du_e/ddram_odt
add wave -noupdate -expand -group ddram -radix hexadecimal /testbench/du_e/ddram_a
add wave -noupdate -expand -group ddram -radix hexadecimal /testbench/du_e/ddram_ba
add wave -noupdate -expand -group ddram -radix hexadecimal -childformat {{/testbench/du_e/ddram_dq(15) -radix hexadecimal} {/testbench/du_e/ddram_dq(14) -radix hexadecimal} {/testbench/du_e/ddram_dq(13) -radix hexadecimal} {/testbench/du_e/ddram_dq(12) -radix hexadecimal} {/testbench/du_e/ddram_dq(11) -radix hexadecimal} {/testbench/du_e/ddram_dq(10) -radix hexadecimal} {/testbench/du_e/ddram_dq(9) -radix hexadecimal} {/testbench/du_e/ddram_dq(8) -radix hexadecimal} {/testbench/du_e/ddram_dq(7) -radix hexadecimal} {/testbench/du_e/ddram_dq(6) -radix hexadecimal} {/testbench/du_e/ddram_dq(5) -radix hexadecimal} {/testbench/du_e/ddram_dq(4) -radix hexadecimal} {/testbench/du_e/ddram_dq(3) -radix hexadecimal} {/testbench/du_e/ddram_dq(2) -radix hexadecimal} {/testbench/du_e/ddram_dq(1) -radix hexadecimal} {/testbench/du_e/ddram_dq(0) -radix hexadecimal}} -subitemconfig {/testbench/du_e/ddram_dq(15) {-height 29 -radix hexadecimal} /testbench/du_e/ddram_dq(14) {-height 29 -radix hexadecimal} /testbench/du_e/ddram_dq(13) {-height 29 -radix hexadecimal} /testbench/du_e/ddram_dq(12) {-height 29 -radix hexadecimal} /testbench/du_e/ddram_dq(11) {-height 29 -radix hexadecimal} /testbench/du_e/ddram_dq(10) {-height 29 -radix hexadecimal} /testbench/du_e/ddram_dq(9) {-height 29 -radix hexadecimal} /testbench/du_e/ddram_dq(8) {-height 29 -radix hexadecimal} /testbench/du_e/ddram_dq(7) {-height 29 -radix hexadecimal} /testbench/du_e/ddram_dq(6) {-height 29 -radix hexadecimal} /testbench/du_e/ddram_dq(5) {-height 29 -radix hexadecimal} /testbench/du_e/ddram_dq(4) {-height 29 -radix hexadecimal} /testbench/du_e/ddram_dq(3) {-height 29 -radix hexadecimal} /testbench/du_e/ddram_dq(2) {-height 29 -radix hexadecimal} /testbench/du_e/ddram_dq(1) {-height 29 -radix hexadecimal} /testbench/du_e/ddram_dq(0) {-height 29 -radix hexadecimal}} /testbench/du_e/ddram_dq
add wave -noupdate -expand -group ddram -radix hexadecimal /testbench/du_e/ddram_dm
add wave -noupdate -expand -group ddram -expand /testbench/du_e/ddram_dqs
add wave -noupdate -divider {New Divider}
add wave -noupdate -expand -group uart -label uart_rxd /testbench/du_e/gpio(0)
add wave -noupdate -expand -group uart -label uart_txd /testbench/du_e/gpio(1)
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/hdlctb_e/uartrx_e/debug_rxd
add wave -noupdate /testbench/hdlctb_e/uartrx_e/debug_rxdv
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/ddram_clk_MGIOLI/ECLK
add wave -noupdate /testbench/du_e/ddram_clk_MGIOLI/CLK
add wave -noupdate /testbench/du_e/ddram_clk_MGIOLI/IOLDO
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/ddram_ras_n_MGIOLI/IOLDO
add wave -noupdate /testbench/du_e/ddram_ras_n_MGIOLI/TXDATA0
add wave -noupdate /testbench/du_e/ddram_ras_n_MGIOLI/LSR
add wave -noupdate /testbench/du_e/ddram_ras_n_MGIOLI/CLK
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/sdrphy_locked_i
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_iI/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_i_DQSBUFM/DQSI
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_iI/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_i_DQSBUFM/READ1
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_iI/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_i_DQSBUFM/READ0
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_iI/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_i_DQSBUFM/READCLKSEL2
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_iI/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_i_DQSBUFM/READCLKSEL1
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_iI/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_i_DQSBUFM/READCLKSEL0
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_iI/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_i_DQSBUFM/SCLK
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_iI/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_i_DQSBUFM/ECLK
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_iI/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_i_DQSBUFM/DDRDEL
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_iI/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_i_DQSBUFM/RST
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_iI/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_i_DQSBUFM/PAUSE
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_iI/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_i_DQSBUFM/DYNDELAY7
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_iI/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_i_DQSBUFM/DYNDELAY6
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_iI/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_i_DQSBUFM/DYNDELAY5
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_iI/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_i_DQSBUFM/DYNDELAY4
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_iI/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_i_DQSBUFM/DYNDELAY3
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_iI/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_i_DQSBUFM/DYNDELAY2
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_iI/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_i_DQSBUFM/DYNDELAY1
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_iI/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_i_DQSBUFM/DYNDELAY0
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_iI/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_i_DQSBUFM/RDLOADN
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_iI/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_i_DQSBUFM/RDMOVE
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_iI/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_i_DQSBUFM/RDDIRECTION
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_iI/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_i_DQSBUFM/WRLOADN
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_iI/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_i_DQSBUFM/WRMOVE
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_iI/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_i_DQSBUFM/WRDIRECTION
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_iI/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_i_DQSBUFM/RDCFLAG
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_iI/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_i_DQSBUFM/RDPNTR2
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_iI/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_i_DQSBUFM/RDPNTR1
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_iI/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_i_DQSBUFM/RDPNTR0
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_iI/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_i_DQSBUFM/WRCFLAG
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_iI/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_i_DQSBUFM/WRPNTR2
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_iI/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_i_DQSBUFM/WRPNTR1
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_iI/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_i_DQSBUFM/WRPNTR0
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_iI/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_i_DQSBUFM/DQSR90
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_iI/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_i_DQSBUFM/DQSW
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_iI/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_i_DQSBUFM/DQSW270
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_iI/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_i_DQSBUFM/DATAVALID
add wave -noupdate /testbench/du_e/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_iI/sdrphy_e_byte_g_0_sdrphy_i_dqsbuf_b_dqsbufm_i_DQSBUFM/BURSTDET
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/ddram_clk_MGIOLI/ECLK
add wave -noupdate /testbench/du_e/ddram_clk_MGIOLI/CLK
add wave -noupdate /testbench/du_e/ddram_clk_MGIOLI/IOLDO
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/ddram_ras_n_MGIOLI/IOLDO
add wave -noupdate /testbench/du_e/ddram_ras_n_MGIOLI/TXDATA0
add wave -noupdate /testbench/du_e/ddram_ras_n_MGIOLI/LSR
add wave -noupdate /testbench/du_e/ddram_ras_n_MGIOLI/CLK
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/sdrphy_e_read_req_1
add wave -noupdate /testbench/du_e/sdrphy_e_read_rdy_1
add wave -noupdate /testbench/du_e/sdrphy_e_read_rdy_0
add wave -noupdate /testbench/du_e/sdrphy_e_read_req_0
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/ctlrphy_rlreq
add wave -noupdate /testbench/du_e/sdrphy_e_phy_rlrdy
add wave -noupdate /testbench/du_e/graphics_e_dmaso_irdy
add wave -noupdate /testbench/du_e/graphics_e_gnt_dv_1
add wave -noupdate -radix hexadecimal -childformat {{/testbench/du_e/data(63) -radix hexadecimal} {/testbench/du_e/data(62) -radix hexadecimal} {/testbench/du_e/data(61) -radix hexadecimal} {/testbench/du_e/data(60) -radix hexadecimal} {/testbench/du_e/data(59) -radix hexadecimal} {/testbench/du_e/data(58) -radix hexadecimal} {/testbench/du_e/data(57) -radix hexadecimal} {/testbench/du_e/data(56) -radix hexadecimal} {/testbench/du_e/data(55) -radix hexadecimal} {/testbench/du_e/data(54) -radix hexadecimal} {/testbench/du_e/data(53) -radix hexadecimal} {/testbench/du_e/data(52) -radix hexadecimal} {/testbench/du_e/data(51) -radix hexadecimal} {/testbench/du_e/data(50) -radix hexadecimal} {/testbench/du_e/data(49) -radix hexadecimal} {/testbench/du_e/data(48) -radix hexadecimal} {/testbench/du_e/data(47) -radix hexadecimal} {/testbench/du_e/data(46) -radix hexadecimal} {/testbench/du_e/data(45) -radix hexadecimal} {/testbench/du_e/data(44) -radix hexadecimal} {/testbench/du_e/data(43) -radix hexadecimal} {/testbench/du_e/data(42) -radix hexadecimal} {/testbench/du_e/data(41) -radix hexadecimal} {/testbench/du_e/data(40) -radix hexadecimal} {/testbench/du_e/data(39) -radix hexadecimal} {/testbench/du_e/data(38) -radix hexadecimal} {/testbench/du_e/data(37) -radix hexadecimal} {/testbench/du_e/data(36) -radix hexadecimal} {/testbench/du_e/data(35) -radix hexadecimal} {/testbench/du_e/data(34) -radix hexadecimal} {/testbench/du_e/data(33) -radix hexadecimal} {/testbench/du_e/data(32) -radix hexadecimal} {/testbench/du_e/data(31) -radix hexadecimal} {/testbench/du_e/data(30) -radix hexadecimal} {/testbench/du_e/data(29) -radix hexadecimal} {/testbench/du_e/data(28) -radix hexadecimal} {/testbench/du_e/data(27) -radix hexadecimal} {/testbench/du_e/data(26) -radix hexadecimal} {/testbench/du_e/data(25) -radix hexadecimal} {/testbench/du_e/data(24) -radix hexadecimal} {/testbench/du_e/data(23) -radix hexadecimal} {/testbench/du_e/data(22) -radix hexadecimal} {/testbench/du_e/data(21) -radix hexadecimal} {/testbench/du_e/data(20) -radix hexadecimal} {/testbench/du_e/data(19) -radix hexadecimal} {/testbench/du_e/data(18) -radix hexadecimal} {/testbench/du_e/data(17) -radix hexadecimal} {/testbench/du_e/data(16) -radix hexadecimal} {/testbench/du_e/data(15) -radix hexadecimal} {/testbench/du_e/data(14) -radix hexadecimal} {/testbench/du_e/data(13) -radix hexadecimal} {/testbench/du_e/data(12) -radix hexadecimal} {/testbench/du_e/data(11) -radix hexadecimal} {/testbench/du_e/data(10) -radix hexadecimal} {/testbench/du_e/data(9) -radix hexadecimal} {/testbench/du_e/data(8) -radix hexadecimal} {/testbench/du_e/data(7) -radix hexadecimal} {/testbench/du_e/data(6) -radix hexadecimal} {/testbench/du_e/data(5) -radix hexadecimal} {/testbench/du_e/data(4) -radix hexadecimal} {/testbench/du_e/data(3) -radix hexadecimal} {/testbench/du_e/data(2) -radix hexadecimal} {/testbench/du_e/data(1) -radix hexadecimal} {/testbench/du_e/data(0) -radix hexadecimal}} -subitemconfig {/testbench/du_e/graphics_e_dmaso_data_63 {-radix hexadecimal} /testbench/du_e/graphics_e_dmaso_data_62 {-radix hexadecimal} /testbench/du_e/graphics_e_dmaso_data_61 {-radix hexadecimal} /testbench/du_e/graphics_e_dmaso_data_60 {-radix hexadecimal} /testbench/du_e/graphics_e_dmaso_data_59 {-radix hexadecimal} /testbench/du_e/graphics_e_dmaso_data_58 {-radix hexadecimal} /testbench/du_e/graphics_e_dmaso_data_57 {-radix hexadecimal} /testbench/du_e/graphics_e_dmaso_data_56 {-radix hexadecimal} /testbench/du_e/graphics_e_dmaso_data_55 {-radix hexadecimal} /testbench/du_e/graphics_e_dmaso_data_54 {-radix hexadecimal} /testbench/du_e/graphics_e_dmaso_data_53 {-radix hexadecimal} /testbench/du_e/graphics_e_dmaso_data_52 {-radix hexadecimal} /testbench/du_e/graphics_e_dmaso_data_51 {-radix hexadecimal} /testbench/du_e/graphics_e_dmaso_data_50 {-radix hexadecimal} /testbench/du_e/graphics_e_dmaso_data_49 {-radix hexadecimal} /testbench/du_e/graphics_e_dmaso_data_48 {-radix hexadecimal} /testbench/du_e/graphics_e_dmaso_data_47 {-radix hexadecimal} /testbench/du_e/graphics_e_dmaso_data_46 {-radix hexadecimal} /testbench/du_e/graphics_e_dmaso_data_45 {-radix hexadecimal} /testbench/du_e/graphics_e_dmaso_data_44 {-radix hexadecimal} /testbench/du_e/graphics_e_dmaso_data_43 {-radix hexadecimal} /testbench/du_e/graphics_e_dmaso_data_42 {-radix hexadecimal} /testbench/du_e/graphics_e_dmaso_data_41 {-radix hexadecimal} /testbench/du_e/graphics_e_dmaso_data_40 {-radix hexadecimal} /testbench/du_e/graphics_e_dmaso_data_39 {-radix hexadecimal} /testbench/du_e/graphics_e_dmaso_data_38 {-radix hexadecimal} /testbench/du_e/graphics_e_dmaso_data_37 {-radix hexadecimal} /testbench/du_e/graphics_e_dmaso_data_36 {-radix hexadecimal} /testbench/du_e/graphics_e_dmaso_data_35 {-radix hexadecimal} /testbench/du_e/graphics_e_dmaso_data_34 {-radix hexadecimal} /testbench/du_e/graphics_e_dmaso_data_33 {-radix hexadecimal} /testbench/du_e/graphics_e_dmaso_data_32 {-radix hexadecimal} /testbench/du_e/graphics_e_dmaso_data_31 {-radix hexadecimal} /testbench/du_e/graphics_e_dmaso_data_30 {-radix hexadecimal} /testbench/du_e/graphics_e_dmaso_data_29 {-radix hexadecimal} /testbench/du_e/graphics_e_dmaso_data_28 {-radix hexadecimal} /testbench/du_e/graphics_e_dmaso_data_27 {-radix hexadecimal} /testbench/du_e/graphics_e_dmaso_data_26 {-radix hexadecimal} /testbench/du_e/graphics_e_dmaso_data_25 {-radix hexadecimal} /testbench/du_e/graphics_e_dmaso_data_24 {-radix hexadecimal} /testbench/du_e/graphics_e_dmaso_data_23 {-radix hexadecimal} /testbench/du_e/graphics_e_dmaso_data_22 {-radix hexadecimal} /testbench/du_e/graphics_e_dmaso_data_21 {-radix hexadecimal} /testbench/du_e/graphics_e_dmaso_data_20 {-radix hexadecimal} /testbench/du_e/graphics_e_dmaso_data_19 {-radix hexadecimal} /testbench/du_e/graphics_e_dmaso_data_18 {-radix hexadecimal} /testbench/du_e/graphics_e_dmaso_data_17 {-radix hexadecimal} /testbench/du_e/graphics_e_dmaso_data_16 {-radix hexadecimal} /testbench/du_e/graphics_e_dmaso_data_15 {-radix hexadecimal} /testbench/du_e/graphics_e_dmaso_data_14 {-radix hexadecimal} /testbench/du_e/graphics_e_dmaso_data_13 {-radix hexadecimal} /testbench/du_e/graphics_e_dmaso_data_12 {-radix hexadecimal} /testbench/du_e/graphics_e_dmaso_data_11 {-radix hexadecimal} /testbench/du_e/graphics_e_dmaso_data_10 {-radix hexadecimal} /testbench/du_e/graphics_e_dmaso_data_9 {-radix hexadecimal} /testbench/du_e/graphics_e_dmaso_data_8 {-radix hexadecimal} /testbench/du_e/graphics_e_dmaso_data_7 {-radix hexadecimal} /testbench/du_e/graphics_e_dmaso_data_6 {-radix hexadecimal} /testbench/du_e/graphics_e_dmaso_data_5 {-radix hexadecimal} /testbench/du_e/graphics_e_dmaso_data_4 {-radix hexadecimal} /testbench/du_e/graphics_e_dmaso_data_3 {-radix hexadecimal} /testbench/du_e/graphics_e_dmaso_data_2 {-radix hexadecimal} /testbench/du_e/graphics_e_dmaso_data_1 {-radix hexadecimal} /testbench/du_e/graphics_e_dmaso_data_0 {-radix hexadecimal}} /testbench/du_e/data
add wave -noupdate /testbench/du_e/graphics_e_q_Q_0_0
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix hexadecimal -childformat {{/testbench/du_e/timer_cntr0(5) -radix hexadecimal} {/testbench/du_e/timer_cntr0(4) -radix hexadecimal} {/testbench/du_e/timer_cntr0(3) -radix hexadecimal} {/testbench/du_e/timer_cntr0(2) -radix hexadecimal} {/testbench/du_e/timer_cntr0(1) -radix hexadecimal} {/testbench/du_e/timer_cntr0(0) -radix hexadecimal}} -expand -subitemconfig {/testbench/du_e/graphics_e_sdrctlr_b_sdrctlr_e_sdram_init_e_sdram_timer_b_timer_b_timer_e_cntr_0 {-radix hexadecimal} /testbench/du_e/graphics_e_sdrctlr_b_sdrctlr_e_sdram_init_e_sdram_timer_b_timer_b_timer_e_cntr_1 {-radix hexadecimal} /testbench/du_e/graphics_e_sdrctlr_b_sdrctlr_e_sdram_init_e_sdram_timer_b_timer_b_timer_e_cntr_2 {-radix hexadecimal} /testbench/du_e/graphics_e_sdrctlr_b_sdrctlr_e_sdram_init_e_sdram_timer_b_timer_b_timer_e_cntr_3 {-radix hexadecimal} /testbench/du_e/graphics_e_sdrctlr_b_sdrctlr_e_sdram_init_e_sdram_timer_b_timer_b_timer_e_cntr_4 {-radix hexadecimal} /testbench/du_e/graphics_e_sdrctlr_b_sdrctlr_e_sdram_init_e_sdram_timer_b_timer_b_timer_e_cntr_5 {-radix hexadecimal}} /testbench/du_e/timer_cntr0
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix hexadecimal -childformat {{/testbench/du_e/timer_cntr2001(4) -radix hexadecimal} {/testbench/du_e/timer_cntr2001(3) -radix hexadecimal} {/testbench/du_e/timer_cntr2001(2) -radix hexadecimal} {/testbench/du_e/timer_cntr2001(1) -radix hexadecimal} {/testbench/du_e/timer_cntr2001(0) -radix hexadecimal}} -expand -subitemconfig {/testbench/du_e/graphics_e_sdrctlr_b_sdrctlr_e_sdram_init_e_sdram_timer_b_timer_b_timer_e_cntr_0_0 {-radix hexadecimal} /testbench/du_e/graphics_e_sdrctlr_b_sdrctlr_e_sdram_init_e_sdram_timer_b_timer_b_timer_e_cntr_0_1 {-radix hexadecimal} /testbench/du_e/graphics_e_sdrctlr_b_sdrctlr_e_sdram_init_e_sdram_timer_b_timer_b_timer_e_cntr_0_2 {-radix hexadecimal} /testbench/du_e/graphics_e_sdrctlr_b_sdrctlr_e_sdram_init_e_sdram_timer_b_timer_b_timer_e_cntr_0_3 {-radix hexadecimal} /testbench/du_e/graphics_e_sdrctlr_b_sdrctlr_e_sdram_init_e_sdram_timer_b_timer_b_timer_e_cntr_0_4 {-radix hexadecimal}} /testbench/du_e/timer_cntr3
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {399189556350 fs} 0} {{Cursor 2} {1323771139350 fs} 0}
quietly wave cursor active 1
configure wave -namecolwidth 205
configure wave -valuecolwidth 90
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
WaveRestoreZoom {217920617650 fs} {1041162072760 fs}
