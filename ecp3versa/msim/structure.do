onerror {resume}
quietly virtual signal -install /testbench/ecp3versa_e { (context /testbench/ecp3versa_e )(ddrphy_dqi_7 & ddrphy_dqi_6 & ddrphy_dqi_5 & ddrphy_dqi_4 & ddrphy_dqi_3 & ddrphy_dqi_2 & ddrphy_dqi_1 & ddrphy_dqi_0 )} dqi_0
quietly virtual signal -install /testbench/ecp3versa_e { (context /testbench/ecp3versa_e )(ddrphy_dqi_15 & ddrphy_dqi_14 & ddrphy_dqi_13 & ddrphy_dqi_12 & ddrphy_dqi_11 & ddrphy_dqi_10 & ddrphy_dqi_9 & ddrphy_dqi_8 )} dq_2
quietly virtual signal -install /testbench/ecp3versa_e {/testbench/ecp3versa_e/dq_2  } dqi_2
quietly virtual signal -install /testbench/ecp3versa_e { (context /testbench/ecp3versa_e )(ddrphy_dqi_23 & ddrphy_dqi_22 & ddrphy_dqi_21 & ddrphy_dqi_20 & ddrphy_dqi_19 & ddrphy_dqi_18 & ddrphy_dqi_17 & ddrphy_dqi_16 )} dqi_3
quietly virtual signal -install /testbench/ecp3versa_e { (context /testbench/ecp3versa_e )(ddrphy_dqi_23 & ddrphy_dqi_22 & ddrphy_dqi_21 & ddrphy_dqi_20 & ddrphy_dqi_19 & ddrphy_dqi_18 & ddrphy_dqi_17 & ddrphy_dqi_16 )} dqi_4
quietly virtual signal -install /testbench/ecp3versa_e { (context /testbench/ecp3versa_e )(ddrphy_dqi_23 & ddrphy_dqi_22 & ddrphy_dqi_21 & ddrphy_dqi_20 & ddrphy_dqi_19 & ddrphy_dqi_18 & ddrphy_dqi_17 & ddrphy_dqi_16 )} dqi_5
quietly virtual signal -install /testbench/ecp3versa_e { (context /testbench/ecp3versa_e )(ddrphy_dqi_31 & ddrphy_dqi_30 & ddrphy_dqi_29 & ddrphy_dqi_28 & ddrphy_dqi_27 & ddrphy_dqi_26 & ddrphy_dqi_25 & ddrphy_dqi_24 )} dqi_6
quietly virtual signal -install /testbench/ecp3versa_e {/testbench/ecp3versa_e/dqi_2  } dqi_1
quietly virtual signal -install /testbench/ecp3versa_e {/testbench/ecp3versa_e/dqi_3  } dqi_2001
quietly virtual signal -install /testbench/ecp3versa_e {/testbench/ecp3versa_e/dqi_2001  } dqi_2002
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/rst_n
add wave -noupdate /testbench/cke
add wave -noupdate -radix hexadecimal /testbench/addr
add wave -noupdate /testbench/ras_n
add wave -noupdate /testbench/cas_n
add wave -noupdate /testbench/we_n
add wave -noupdate /testbench/cs_n
add wave -noupdate /testbench/dm
add wave -noupdate /testbench/ddr_clk_p
add wave -noupdate /testbench/dqs_p(1)
add wave -noupdate /testbench/dqs_p(0)
add wave -noupdate -radix hexadecimal -childformat {{/testbench/dq(15) -radix hexadecimal} {/testbench/dq(14) -radix hexadecimal} {/testbench/dq(13) -radix hexadecimal} {/testbench/dq(12) -radix hexadecimal} {/testbench/dq(11) -radix hexadecimal} {/testbench/dq(10) -radix hexadecimal} {/testbench/dq(9) -radix hexadecimal} {/testbench/dq(8) -radix hexadecimal} {/testbench/dq(7) -radix hexadecimal} {/testbench/dq(6) -radix hexadecimal} {/testbench/dq(5) -radix hexadecimal} {/testbench/dq(4) -radix hexadecimal} {/testbench/dq(3) -radix hexadecimal} {/testbench/dq(2) -radix hexadecimal} {/testbench/dq(1) -radix hexadecimal} {/testbench/dq(0) -radix hexadecimal}} -subitemconfig {/testbench/dq(15) {-height 16 -radix hexadecimal} /testbench/dq(14) {-height 16 -radix hexadecimal} /testbench/dq(13) {-height 16 -radix hexadecimal} /testbench/dq(12) {-height 16 -radix hexadecimal} /testbench/dq(11) {-height 16 -radix hexadecimal} /testbench/dq(10) {-height 16 -radix hexadecimal} /testbench/dq(9) {-height 16 -radix hexadecimal} /testbench/dq(8) {-height 16 -radix hexadecimal} /testbench/dq(7) {-height 16 -radix hexadecimal} /testbench/dq(6) {-height 16 -radix hexadecimal} /testbench/dq(5) {-height 16 -radix hexadecimal} /testbench/dq(4) {-height 16 -radix hexadecimal} /testbench/dq(3) {-height 16 -radix hexadecimal} /testbench/dq(2) {-height 16 -radix hexadecimal} /testbench/dq(1) {-height 16 -radix hexadecimal} /testbench/dq(0) {-height 16 -radix hexadecimal}} /testbench/dq
add wave -noupdate /testbench/ecp3versa_e/ddr_sclk
add wave -noupdate /testbench/ecp3versa_e/ddr_sclk2x
add wave -noupdate /testbench/ecp3versa_e/ddr_eclk
add wave -noupdate -divider ddr3_dqs_0
add wave -noupdate -radix hexadecimal /testbench/ecp3versa_e/dqi_0
add wave -noupdate -radix hexadecimal /testbench/ecp3versa_e/dqi_1
add wave -noupdate -radix hexadecimal /testbench/ecp3versa_e/dqi_3
add wave -noupdate -radix hexadecimal /testbench/ecp3versa_e/dqi_6
add wave -noupdate /testbench/ecp3versa_e/rsts_b_rsts_1
add wave -noupdate /testbench/ecp3versa_e/ddrphy_rst_1
add wave -noupdate /testbench/ecp3versa_e/ddrphy_e_eclk_stop
add wave -noupdate /testbench/ecp3versa_e/ddrphy_e_dqsdll_lock
add wave -noupdate /testbench/ecp3versa_e/ddrphy_e_lock
add wave -noupdate /testbench/ecp3versa_e/ddrphy_e_rst
add wave -noupdate /testbench/ecp3versa_e/ddrphy_e_dqsdel
add wave -noupdate /testbench/ecp3versa_e/ddrphy_e_dqsdll_lock
add wave -noupdate /testbench/ecp3versa_e/ddrphy_e_dqsdll_uddcntln
add wave -noupdate -expand -group datavalid_0 /testbench/ecp3versa_e/ddrphy_e_byte_g_0_ddr3phy_i_dqsbufd_iI/ddrphy_e_byte_g_0_ddr3phy_i_dqsbufd_i_DQSBUFD/INST10/datavalid
add wave -noupdate -expand -group datavalid_0 /testbench/ecp3versa_e/ddrphy_e_byte_g_0_ddr3phy_i_dqsbufd_iI/ddrphy_e_byte_g_0_ddr3phy_i_dqsbufd_i_DQSBUFD/INST10/datavalid_int1
add wave -noupdate -expand -group datavalid_0 /testbench/ecp3versa_e/ddrphy_e_byte_g_0_ddr3phy_i_dqsbufd_iI/ddrphy_e_byte_g_0_ddr3phy_i_dqsbufd_i_DQSBUFD/INST10/datavalid_int2
add wave -noupdate -expand -group datavalid_0 /testbench/ecp3versa_e/ddrphy_e_byte_g_0_ddr3phy_i_dqsbufd_iI/ddrphy_e_byte_g_0_ddr3phy_i_dqsbufd_i_DQSBUFD/INST10/datavalid_int3
add wave -noupdate -expand -group datavalid_0 /testbench/ecp3versa_e/ddrphy_e_byte_g_0_ddr3phy_i_dqsbufd_iI/ddrphy_e_byte_g_0_ddr3phy_i_dqsbufd_i_DQSBUFD/INST10/datavalid_int4
add wave -noupdate -expand -group datavalid_0 /testbench/ecp3versa_e/ddrphy_e_byte_g_0_ddr3phy_i_dqsbufd_iI/ddrphy_e_byte_g_0_ddr3phy_i_dqsbufd_i_DQSBUFD/INST10/datavalid_int5
add wave -noupdate -expand -group datavalid_0 /testbench/ecp3versa_e/ddrphy_e_byte_g_0_ddr3phy_i_dqsbufd_iI/ddrphy_e_byte_g_0_ddr3phy_i_dqsbufd_i_DQSBUFD/INST10/datavalid_int6
add wave -noupdate -expand -group datavalid_0 /testbench/ecp3versa_e/ddrphy_e_byte_g_0_ddr3phy_i_dqsbufd_iI/ddrphy_e_byte_g_0_ddr3phy_i_dqsbufd_i_DQSBUFD/INST10/datavalid_int_n
add wave -noupdate -expand -group datavalid_0 /testbench/ecp3versa_e/ddrphy_e_byte_g_0_ddr3phy_i_dqsbufd_iI/ddrphy_e_byte_g_0_ddr3phy_i_dqsbufd_i_DQSBUFD/INST10/reset_data_valid_regs
add wave -noupdate -expand -group datavalid_0 /testbench/ecp3versa_e/ddrphy_e_byte_g_0_ddr3phy_i_dqsbufd_iI/ddrphy_e_byte_g_0_ddr3phy_i_dqsbufd_i_DQSBUFD/INST10/reset_prmbdet_clean
add wave -noupdate -expand -group datavalid_0 /testbench/ecp3versa_e/ddrphy_e_byte_g_0_ddr3phy_i_dqsbufd_iI/ddrphy_e_byte_g_0_ddr3phy_i_dqsbufd_i_DQSBUFD/INST10/read
add wave -noupdate -expand -group datavalid_0 /testbench/ecp3versa_e/ddrphy_e_byte_g_0_ddr3phy_i_dqsbufd_iI/ddrphy_e_byte_g_0_ddr3phy_i_dqsbufd_i_DQSBUFD/INST10/prmbdet
add wave -noupdate -expand -group datavalid_0 /testbench/ecp3versa_e/ddrphy_e_byte_g_0_ddr3phy_i_dqsbufd_iI/ddrphy_e_byte_g_0_ddr3phy_i_dqsbufd_i_DQSBUFD/INST10/prmbdet_raw
add wave -noupdate -expand -group datavalid_0 /testbench/ecp3versa_e/ddrphy_e_byte_g_0_ddr3phy_i_dqsbufd_iI/ddrphy_e_byte_g_0_ddr3phy_i_dqsbufd_i_DQSBUFD/INST10/prmbdet_clean
add wave -noupdate -expand -group datavalid_0 /testbench/ecp3versa_e/ddrphy_e_byte_g_0_ddr3phy_i_dqsbufd_iI/ddrphy_e_byte_g_0_ddr3phy_i_dqsbufd_i_DQSBUFD/INST10/PRMBDET_int
add wave -noupdate -expand -group dlldqs_0 /testbench/ecp3versa_e/ddrphy_e_byte_g_0_ddr3phy_i_dqsbufd_iI/RST
add wave -noupdate -expand -group dlldqs_0 -group dyndelay /testbench/ecp3versa_e/ddrphy_e_byte_g_0_ddr3phy_i_dqsbufd_iI/DYNDELAY0
add wave -noupdate -expand -group dlldqs_0 -group dyndelay /testbench/ecp3versa_e/ddrphy_e_byte_g_0_ddr3phy_i_dqsbufd_iI/DYNDELAY1
add wave -noupdate -expand -group dlldqs_0 -group dyndelay /testbench/ecp3versa_e/ddrphy_e_byte_g_0_ddr3phy_i_dqsbufd_iI/DYNDELAY2
add wave -noupdate -expand -group dlldqs_0 -group dyndelay /testbench/ecp3versa_e/ddrphy_e_byte_g_0_ddr3phy_i_dqsbufd_iI/DYNDELAY3
add wave -noupdate -expand -group dlldqs_0 -group dyndelay /testbench/ecp3versa_e/ddrphy_e_byte_g_0_ddr3phy_i_dqsbufd_iI/DYNDELAY4
add wave -noupdate -expand -group dlldqs_0 -group dyndelay /testbench/ecp3versa_e/ddrphy_e_byte_g_0_ddr3phy_i_dqsbufd_iI/DYNDELAY5
add wave -noupdate -expand -group dlldqs_0 -group dyndelay /testbench/ecp3versa_e/ddrphy_e_byte_g_0_ddr3phy_i_dqsbufd_iI/DYNDELAY6
add wave -noupdate -expand -group dlldqs_0 -group dyndelay /testbench/ecp3versa_e/ddrphy_e_byte_g_0_ddr3phy_i_dqsbufd_iI/DYNDELAY7
add wave -noupdate -expand -group dlldqs_0 /testbench/ecp3versa_e/ddrphy_e_byte_g_1_ddr3phy_i_dqsbufd_iI/SCLK
add wave -noupdate -expand -group dlldqs_0 /testbench/ecp3versa_e/ddrphy_e_byte_g_0_ddr3phy_i_dqsbufd_iI/DQSDEL
add wave -noupdate -expand -group dlldqs_0 /testbench/ecp3versa_e/ddrphy_e_byte_g_0_ddr3phy_i_dqsbufd_iI/READ
add wave -noupdate -expand -group dlldqs_0 /testbench/ecp3versa_e/ddrphy_e_byte_g_0_ddr3phy_i_dqsbufd_iI/DQSI
add wave -noupdate -expand -group dlldqs_0 /testbench/ecp3versa_e/ddrphy_e_byte_g_1_ddr3phy_i_dqsbufd_iI/ECLK
add wave -noupdate -expand -group dlldqs_0 /testbench/ecp3versa_e/ddrphy_e_byte_g_1_ddr3phy_i_dqsbufd_iI/ECLKW
add wave -noupdate -expand -group dlldqs_0 /testbench/ecp3versa_e/ddrphy_e_byte_g_0_ddr3phy_i_dqsbufd_iI/DATAVALID
add wave -noupdate -expand -group dlldqs_0 /testbench/ecp3versa_e/ddrphy_e_byte_g_0_ddr3phy_i_dqsbufd_iI/DDRCLKPOL
add wave -noupdate -expand -group dlldqs_0 /testbench/ecp3versa_e/ddrphy_e_byte_g_0_ddr3phy_i_dqsbufd_iI/DDRLAT
add wave -noupdate -expand -group dlldqs_0 /testbench/ecp3versa_e/ddrphy_e_byte_g_0_ddr3phy_i_dqsbufd_iI/DQSW
add wave -noupdate -expand -group dlldqs_0 /testbench/ecp3versa_e/ddrphy_e_byte_g_0_ddr3phy_i_dqsbufd_iI/ECLKDQSR
add wave -noupdate -expand -group dlldqs_0 /testbench/ecp3versa_e/ddrphy_e_byte_g_0_ddr3phy_i_dqsbufd_iI/DQCLK1
add wave -noupdate -expand -group dlldqs_0 /testbench/ecp3versa_e/ddrphy_e_byte_g_0_ddr3phy_i_dqsbufd_iI/DQCLK0
add wave -noupdate -divider {New Divider}
add wave -noupdate -group dqs_0 /testbench/ecp3versa_e/ddr3_dqs_0_MGIOLI/CLK
add wave -noupdate -group dqs_0 /testbench/ecp3versa_e/ddr3_dqs_0_MGIOLI/DQSW
add wave -noupdate -group dqs_0 /testbench/ecp3versa_e/ddr3_dqs_0_MGIOLI/DQCLK1
add wave -noupdate -group dqs_0 /testbench/ecp3versa_e/ddr3_dqs_0_MGIOLI/DQCLK0
add wave -noupdate -group dqs_0 /testbench/ecp3versa_e/ddr3_dqs_0_MGIOLI/DQSTCLKI
add wave -noupdate -group dqs_0 /testbench/ecp3versa_e/ddr3_dqs_0_MGIOLI/OPOSA
add wave -noupdate -group dqs_0 /testbench/ecp3versa_e/ddr3_dqs_0_MGIOLI/OPOSB
add wave -noupdate -group dqs_0 /testbench/ecp3versa_e/ddr3_dqs_0_MGIOLI/TS
add wave -noupdate -group dqs_0 /testbench/ecp3versa_e/ddr3_dqs_0_MGIOLI/ONEGB
add wave -noupdate -group dqs_0 /testbench/ecp3versa_e/ddr3_dqs_0_MGIOLI/DQSTCLKO
add wave -noupdate -group dqs_0 /testbench/ecp3versa_e/ddr3_dqs_0_MGIOLI/IOLTO
add wave -noupdate -group dqs_0 /testbench/ecp3versa_e/ddr3_dqs_0_MGIOLI/IOLDO
add wave -noupdate -divider ddr3_dqs_1
add wave -noupdate -expand -group dlldqs_1 /testbench/ecp3versa_e/ddrphy_e_byte_g_1_ddr3phy_i_dqsbufd_iI/RST
add wave -noupdate -expand -group dlldqs_1 -group dyndelay1 /testbench/ecp3versa_e/ddrphy_e_byte_g_1_ddr3phy_i_dqsbufd_iI/DYNDELAY0
add wave -noupdate -expand -group dlldqs_1 -group dyndelay1 /testbench/ecp3versa_e/ddrphy_e_byte_g_1_ddr3phy_i_dqsbufd_iI/DYNDELAY1
add wave -noupdate -expand -group dlldqs_1 -group dyndelay1 /testbench/ecp3versa_e/ddrphy_e_byte_g_1_ddr3phy_i_dqsbufd_iI/DYNDELAY2
add wave -noupdate -expand -group dlldqs_1 -group dyndelay1 /testbench/ecp3versa_e/ddrphy_e_byte_g_1_ddr3phy_i_dqsbufd_iI/DYNDELAY3
add wave -noupdate -expand -group dlldqs_1 -group dyndelay1 /testbench/ecp3versa_e/ddrphy_e_byte_g_1_ddr3phy_i_dqsbufd_iI/DYNDELAY4
add wave -noupdate -expand -group dlldqs_1 -group dyndelay1 /testbench/ecp3versa_e/ddrphy_e_byte_g_1_ddr3phy_i_dqsbufd_iI/DYNDELAY5
add wave -noupdate -expand -group dlldqs_1 -group dyndelay1 /testbench/ecp3versa_e/ddrphy_e_byte_g_1_ddr3phy_i_dqsbufd_iI/DYNDELAY6
add wave -noupdate -expand -group dlldqs_1 -group dyndelay1 /testbench/ecp3versa_e/ddrphy_e_byte_g_1_ddr3phy_i_dqsbufd_iI/DYNDELAY7
add wave -noupdate -expand -group dlldqs_1 /testbench/ecp3versa_e/ddrphy_e_byte_g_1_ddr3phy_i_dqsbufd_iI/SCLK
add wave -noupdate -expand -group dlldqs_1 /testbench/ecp3versa_e/ddrphy_e_byte_g_1_ddr3phy_i_dqsbufd_iI/DQSDEL
add wave -noupdate -expand -group dlldqs_1 /testbench/ecp3versa_e/ddrphy_e_byte_g_1_ddr3phy_i_dqsbufd_iI/READ
add wave -noupdate -expand -group dlldqs_1 /testbench/ecp3versa_e/ddrphy_e_byte_g_1_ddr3phy_i_dqsbufd_iI/DQSI
add wave -noupdate -expand -group dlldqs_1 /testbench/ecp3versa_e/ddrphy_e_byte_g_1_ddr3phy_i_dqsbufd_iI/ECLK
add wave -noupdate -expand -group dlldqs_1 /testbench/ecp3versa_e/ddrphy_e_byte_g_1_ddr3phy_i_dqsbufd_iI/ECLKW
add wave -noupdate -expand -group dlldqs_1 /testbench/ecp3versa_e/ddrphy_e_byte_g_1_ddr3phy_i_dqsbufd_iI/DDRCLKPOL
add wave -noupdate -expand -group dlldqs_1 /testbench/ecp3versa_e/ddrphy_e_byte_g_1_ddr3phy_i_dqsbufd_iI/DDRLAT
add wave -noupdate -expand -group dlldqs_1 /testbench/ecp3versa_e/ddrphy_e_byte_g_1_ddr3phy_i_dqsbufd_iI/DQSW
add wave -noupdate -expand -group dlldqs_1 /testbench/ecp3versa_e/ddrphy_e_byte_g_1_ddr3phy_i_dqsbufd_iI/ECLKDQSR
add wave -noupdate -expand -group dlldqs_1 /testbench/ecp3versa_e/ddrphy_e_byte_g_1_ddr3phy_i_dqsbufd_iI/DQCLK1
add wave -noupdate -expand -group dlldqs_1 /testbench/ecp3versa_e/ddrphy_e_byte_g_1_ddr3phy_i_dqsbufd_iI/DQCLK0
add wave -noupdate -divider {New Divider}
add wave -noupdate -expand -group dqs_1 /testbench/ecp3versa_e/ddr3_dqs_1_MGIOLI/CLK
add wave -noupdate -expand -group dqs_1 /testbench/ecp3versa_e/ddr3_dqs_1_MGIOLI/DQCLK0
add wave -noupdate -expand -group dqs_1 /testbench/ecp3versa_e/ddr3_dqs_1_MGIOLI/DQCLK1
add wave -noupdate -expand -group dqs_1 /testbench/ecp3versa_e/ddr3_dqs_1_MGIOLI/DQSTCLKI
add wave -noupdate -expand -group dqs_1 /testbench/ecp3versa_e/ddr3_dqs_1_MGIOLI/DQSW
add wave -noupdate -expand -group dqs_1 /testbench/ecp3versa_e/ddr3_dqs_1_MGIOLI/OPOSA
add wave -noupdate -expand -group dqs_1 /testbench/ecp3versa_e/ddr3_dqs_1_MGIOLI/OPOSB
add wave -noupdate -expand -group dqs_1 /testbench/ecp3versa_e/ddr3_dqs_1_MGIOLI/TS
add wave -noupdate -expand -group dqs_1 /testbench/ecp3versa_e/ddr3_dqs_1_MGIOLI/ONEGB
add wave -noupdate -expand -group dqs_1 /testbench/ecp3versa_e/ddr3_dqs_1_MGIOLI/DQSTCLKO
add wave -noupdate -expand -group dqs_1 /testbench/ecp3versa_e/ddr3_dqs_1_MGIOLI/IOLTO
add wave -noupdate -expand -group dqs_1 /testbench/ecp3versa_e/ddr3_dqs_1_MGIOLI/IOLDO
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/ecp3versa_e/ddr3_cke
add wave -noupdate /testbench/ecp3versa_e/ddr3_cke_c
add wave -noupdate /testbench/ecp3versa_e/ddr3_dqs_0_MGIOLI/DQSW
add wave -noupdate /testbench/ecp3versa_e/ddrphy_cke_0
add wave -noupdate /testbench/ecp3versa_e/ddr3_rst
add wave -noupdate /testbench/ecp3versa_e/ddr_sclk
add wave -noupdate /testbench/ecp3versa_e/ddrphy_rst_1
add wave -noupdate /testbench/ecp3versa_e/scope_e_ddr_e_rst
add wave -noupdate /testbench/ecp3versa_e/phy1_rst_c
add wave -noupdate /testbench/ecp3versa_e/dcms_e_dcm_rst
add wave -noupdate /testbench/ecp3versa_e/fpga_gsrn
add wave -noupdate /testbench/ecp3versa_e/clk_c
add wave -noupdate /testbench/ecp3versa_e/fpga_gsrn_c
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {8716078 ps} 0} {{Cursor 2} {67921 ps} 0} {{Cursor 3} {65424 ps} 0} {{Cursor 4} {1172409 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 167
configure wave -valuecolwidth 55
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
configure wave -timelineunits ps
update
WaveRestoreZoom {8682055 ps} {8745813 ps}
