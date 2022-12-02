onerror {resume}
quietly virtual signal -install /testbench/du_e { (context /testbench/du_e )(graphics_e_dmaso_data_63 & graphics_e_dmaso_data_62 & graphics_e_dmaso_data_61 & graphics_e_dmaso_data_60 & graphics_e_dmaso_data_59 & graphics_e_dmaso_data_58 & graphics_e_dmaso_data_57 & graphics_e_dmaso_data_56 & graphics_e_dmaso_data_55 & graphics_e_dmaso_data_54 & graphics_e_dmaso_data_53 & graphics_e_dmaso_data_52 & graphics_e_dmaso_data_51 & graphics_e_dmaso_data_50 & graphics_e_dmaso_data_49 & graphics_e_dmaso_data_48 & graphics_e_dmaso_data_47 & graphics_e_dmaso_data_46 & graphics_e_dmaso_data_45 & graphics_e_dmaso_data_44 & graphics_e_dmaso_data_43 & graphics_e_dmaso_data_42 & graphics_e_dmaso_data_41 & graphics_e_dmaso_data_40 & graphics_e_dmaso_data_39 & graphics_e_dmaso_data_38 & graphics_e_dmaso_data_37 & graphics_e_dmaso_data_36 & graphics_e_dmaso_data_35 & graphics_e_dmaso_data_34 & graphics_e_dmaso_data_33 & graphics_e_dmaso_data_32 & graphics_e_dmaso_data_31 & graphics_e_dmaso_data_30 & graphics_e_dmaso_data_29 & graphics_e_dmaso_data_28 & graphics_e_dmaso_data_27 & graphics_e_dmaso_data_26 & graphics_e_dmaso_data_25 & graphics_e_dmaso_data_24 & graphics_e_dmaso_data_23 & graphics_e_dmaso_data_22 & graphics_e_dmaso_data_21 & graphics_e_dmaso_data_20 & graphics_e_dmaso_data_19 & graphics_e_dmaso_data_18 & graphics_e_dmaso_data_17 & graphics_e_dmaso_data_16 & graphics_e_dmaso_data_15 & graphics_e_dmaso_data_14 & graphics_e_dmaso_data_13 & graphics_e_dmaso_data_12 & graphics_e_dmaso_data_11 & graphics_e_dmaso_data_10 & graphics_e_dmaso_data_9 & graphics_e_dmaso_data_8 & graphics_e_dmaso_data_7 & graphics_e_dmaso_data_6 & graphics_e_dmaso_data_5 & graphics_e_dmaso_data_4 & graphics_e_dmaso_data_3 & graphics_e_dmaso_data_2 & graphics_e_dmaso_data_1 & graphics_e_dmaso_data_0 )} data
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/du_e/clk_25mhz
add wave -noupdate -group rgmii /testbench/du_e/rgmii_rx_clk
add wave -noupdate -group rgmii /testbench/du_e/rgmii_rx_dv
add wave -noupdate -group rgmii -radix hexadecimal -childformat {{/testbench/du_e/rgmii_rxd(0) -radix hexadecimal} {/testbench/du_e/rgmii_rxd(1) -radix hexadecimal} {/testbench/du_e/rgmii_rxd(2) -radix hexadecimal} {/testbench/du_e/rgmii_rxd(3) -radix hexadecimal}} -expand -subitemconfig {/testbench/du_e/rgmii_rxd(0) {-height 29 -radix hexadecimal} /testbench/du_e/rgmii_rxd(1) {-height 29 -radix hexadecimal} /testbench/du_e/rgmii_rxd(2) {-height 29 -radix hexadecimal} /testbench/du_e/rgmii_rxd(3) {-height 29 -radix hexadecimal}} /testbench/du_e/rgmii_rxd
add wave -noupdate -group rgmii /testbench/du_e/rgmii_tx_clk
add wave -noupdate -group rgmii /testbench/du_e/rgmii_tx_en
add wave -noupdate -group rgmii -radix hexadecimal /testbench/du_e/rgmii_txd
add wave -noupdate -group rgmii /testbench/du_e/rgmii_rx_clk
add wave -noupdate -group rgmii /testbench/du_e/rgmii_rx_dv
add wave -noupdate -group rgmii -radix hexadecimal -childformat {{/testbench/du_e/rgmii_rxd(0) -radix hexadecimal} {/testbench/du_e/rgmii_rxd(1) -radix hexadecimal} {/testbench/du_e/rgmii_rxd(2) -radix hexadecimal} {/testbench/du_e/rgmii_rxd(3) -radix hexadecimal}} -expand -subitemconfig {/testbench/du_e/rgmii_rxd(0) {-height 29 -radix hexadecimal} /testbench/du_e/rgmii_rxd(1) {-height 29 -radix hexadecimal} /testbench/du_e/rgmii_rxd(2) {-height 29 -radix hexadecimal} /testbench/du_e/rgmii_rxd(3) {-height 29 -radix hexadecimal}} /testbench/du_e/rgmii_rxd
add wave -noupdate -group rgmii /testbench/du_e/rgmii_tx_clk
add wave -noupdate -group rgmii /testbench/du_e/rgmii_tx_en
add wave -noupdate -group rgmii -radix hexadecimal /testbench/du_e/rgmii_txd
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
add wave -noupdate -expand -group ddram /testbench/du_e/ddram_dqs
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
add wave -noupdate -expand -group ddram /testbench/du_e/ddram_dqs
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/gpio17
add wave -noupdate /testbench/du_e/gpio9
add wave -noupdate /testbench/du_e/gpio11
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/gpio13
add wave -noupdate /testbench/du_e/gpio23
add wave -noupdate /testbench/du_e/gpio24
add wave -noupdate /testbench/du_e/led
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
add wave -noupdate /testbench/du_e/ctlr_clk
add wave -noupdate /testbench/du_e/ctlrpll_b_pll_iI/CLKOP
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/sdrphy_e_mem_sync_b_clkdivf_iI/CLKI
add wave -noupdate /testbench/du_e/sdrphy_e_mem_sync_b_clkdivf_iI/RST
add wave -noupdate /testbench/du_e/sdrphy_e_mem_sync_b_clkdivf_iI/CDIVX
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/clk_25mhz
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/gpio17
add wave -noupdate /testbench/du_e/gpio9
add wave -noupdate /testbench/du_e/gpio11
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/gpio13
add wave -noupdate /testbench/du_e/gpio23
add wave -noupdate /testbench/du_e/gpio24
add wave -noupdate /testbench/du_e/led
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
add wave -noupdate /testbench/du_e/ctlrpll_b_pll_iI/CLKOP
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/sdrphy_e_mem_sync_b_clkdivf_iI/CLKI
add wave -noupdate /testbench/du_e/sdrphy_e_mem_sync_b_clkdivf_iI/RST
add wave -noupdate /testbench/du_e/sdrphy_e_mem_sync_b_clkdivf_iI/CDIVX
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/ctlr_clk
add wave -noupdate /testbench/du_e/graphics_e_dmaso_irdy
add wave -noupdate -radix hexadecimal /testbench/du_e/data
add wave -noupdate /testbench/du_e/graphics_e_q_Q_0_0
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {63230483300 fs} 0} {{Cursor 2} {63222766140 fs} 0}
quietly wave cursor active 2
configure wave -namecolwidth 1080
configure wave -valuecolwidth 164
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
WaveRestoreZoom {62656264420 fs} {63804702180 fs}
