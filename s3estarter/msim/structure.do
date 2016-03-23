onerror {resume}
quietly virtual signal -install /testbench {/testbench/dq  } dq16
quietly virtual signal -install /testbench/nuhs3dsp_e { (context /testbench/nuhs3dsp_e )(scope_e_ddr_e_wrfifo_i_xdr_fifo_g_0_outbyte_i_aser_q0_0_Q & scope_e_ddr_e_wrfifo_i_xdr_fifo_g_0_outbyte_i_aser_q0_1_Q & scope_e_ddr_e_wrfifo_i_xdr_fifo_g_0_outbyte_i_aser_q0_2_Q & scope_e_ddr_e_wrfifo_i_xdr_fifo_g_0_outbyte_i_aser_q0_3_Q )} serq00
quietly virtual signal -install /testbench/nuhs3dsp_e { (context /testbench/nuhs3dsp_e )(scope_e_ddr_e_wrfifo_i_xdr_fifo_g_0_outbyte_i_aser_q_0_Q & scope_e_ddr_e_wrfifo_i_xdr_fifo_g_0_outbyte_i_aser_q_1_Q & scope_e_ddr_e_wrfifo_i_xdr_fifo_g_0_outbyte_i_aser_q_2_Q & scope_e_ddr_e_wrfifo_i_xdr_fifo_g_0_outbyte_i_aser_q_3_Q )} serq90
quietly virtual signal -install /testbench/nuhs3dsp_e { (context /testbench/nuhs3dsp_e )(scope_e_ddr_e_wrfifo_i_xdr_fifo_g_1_outbyte_i_aser_q0_0_Q & scope_e_ddr_e_wrfifo_i_xdr_fifo_g_1_outbyte_i_aser_q0_1_Q & scope_e_ddr_e_wrfifo_i_xdr_fifo_g_1_outbyte_i_aser_q0_2_Q & scope_e_ddr_e_wrfifo_i_xdr_fifo_g_1_outbyte_i_aser_q0_3_Q )} serq100
quietly virtual signal -install /testbench/nuhs3dsp_e { (context /testbench/nuhs3dsp_e )(scope_e_ddr_e_wrfifo_i_xdr_fifo_g_1_outbyte_i_aser_q_0_Q & scope_e_ddr_e_wrfifo_i_xdr_fifo_g_1_outbyte_i_aser_q_1_Q & scope_e_ddr_e_wrfifo_i_xdr_fifo_g_1_outbyte_i_aser_q_2_Q & scope_e_ddr_e_wrfifo_i_xdr_fifo_g_1_outbyte_i_aser_q_3_Q )} serq190
quietly virtual signal -install /testbench/nuhs3dsp_e { (context /testbench/nuhs3dsp_e )(scope_e_ddr_e_wrfifo_i_xdr_fifo_g_0_outbyte_i_apll_q_0_Q & scope_e_ddr_e_wrfifo_i_xdr_fifo_g_0_outbyte_i_apll_q_1_Q & scope_e_ddr_e_wrfifo_i_xdr_fifo_g_0_outbyte_i_apll_q_2_Q & scope_e_ddr_e_wrfifo_i_xdr_fifo_g_0_outbyte_i_apll_q_3_Q )} pllq0
quietly virtual signal -install /testbench/nuhs3dsp_e { (context /testbench/nuhs3dsp_e )(scope_e_ddr_e_wrfifo_i_xdr_fifo_g_1_outbyte_i_apll_q_0_Q & scope_e_ddr_e_wrfifo_i_xdr_fifo_g_1_outbyte_i_apll_q_1_Q & scope_e_ddr_e_wrfifo_i_xdr_fifo_g_1_outbyte_i_apll_q_2_Q & scope_e_ddr_e_wrfifo_i_xdr_fifo_g_1_outbyte_i_apll_q_3_Q )} pllq1
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/rst
add wave -noupdate /testbench/clk_p
add wave -noupdate /testbench/cke
add wave -noupdate /testbench/cs_n
add wave -noupdate /testbench/ras_n
add wave -noupdate /testbench/cas_n
add wave -noupdate /testbench/we_n
add wave -noupdate /testbench/ba
add wave -noupdate -radix hexadecimal /testbench/addr
add wave -noupdate -expand /testbench/dqs
add wave -noupdate -radix hexadecimal /testbench/dq
add wave -noupdate /testbench/dm
add wave -noupdate /testbench/nuhs3dsp_e/scope_e_ddrs_do_rdy(0)
add wave -noupdate /testbench/nuhs3dsp_e/ddrs_clk0
add wave -noupdate -radix hexadecimal /testbench/nuhs3dsp_e/scope_e_ddrs_do
add wave -noupdate /testbench/nuhs3dsp_e/txd
add wave -noupdate /testbench/nuhs3dsp_e/ddr_st_dqs
add wave -noupdate /testbench/nuhs3dsp_e/ddr_st_lp_dqs
add wave -noupdate /testbench/nuhs3dsp_e/ddr_st_lp_dqs_IBUF_0
add wave -noupdate /testbench/nuhs3dsp_e/scope_e_ddr_e_rdfifo_i_bytes_g_1_data_phases_g_0_inbyte_i_aser_q_1_CEINV_12585
add wave -noupdate /testbench/nuhs3dsp_e/ddrphy_dqsi
add wave -noupdate /testbench/nuhs3dsp_e/ddrphy_dqsi_2_0
add wave -noupdate /testbench/nuhs3dsp_e/ddrphy_dqsi_3_0
add wave -noupdate /testbench/nuhs3dsp_e/ddrphy_dqsi_0_0
add wave -noupdate /testbench/nuhs3dsp_e/ddrphy_dqsi_1_0
add wave -noupdate -divider {write fifo}
add wave -noupdate /testbench/nuhs3dsp_e/scope_e_ddrs_di_rdy
add wave -noupdate -radix hexadecimal -childformat {{/testbench/nuhs3dsp_e/ddrphy_dqo(31) -radix hexadecimal} {/testbench/nuhs3dsp_e/ddrphy_dqo(30) -radix hexadecimal} {/testbench/nuhs3dsp_e/ddrphy_dqo(29) -radix hexadecimal} {/testbench/nuhs3dsp_e/ddrphy_dqo(28) -radix hexadecimal} {/testbench/nuhs3dsp_e/ddrphy_dqo(27) -radix hexadecimal} {/testbench/nuhs3dsp_e/ddrphy_dqo(26) -radix hexadecimal} {/testbench/nuhs3dsp_e/ddrphy_dqo(25) -radix hexadecimal} {/testbench/nuhs3dsp_e/ddrphy_dqo(24) -radix hexadecimal} {/testbench/nuhs3dsp_e/ddrphy_dqo(23) -radix hexadecimal} {/testbench/nuhs3dsp_e/ddrphy_dqo(22) -radix hexadecimal} {/testbench/nuhs3dsp_e/ddrphy_dqo(21) -radix hexadecimal} {/testbench/nuhs3dsp_e/ddrphy_dqo(20) -radix hexadecimal} {/testbench/nuhs3dsp_e/ddrphy_dqo(19) -radix hexadecimal} {/testbench/nuhs3dsp_e/ddrphy_dqo(18) -radix hexadecimal} {/testbench/nuhs3dsp_e/ddrphy_dqo(17) -radix hexadecimal} {/testbench/nuhs3dsp_e/ddrphy_dqo(16) -radix hexadecimal} {/testbench/nuhs3dsp_e/ddrphy_dqo(15) -radix hexadecimal} {/testbench/nuhs3dsp_e/ddrphy_dqo(14) -radix hexadecimal} {/testbench/nuhs3dsp_e/ddrphy_dqo(13) -radix hexadecimal} {/testbench/nuhs3dsp_e/ddrphy_dqo(12) -radix hexadecimal} {/testbench/nuhs3dsp_e/ddrphy_dqo(11) -radix hexadecimal} {/testbench/nuhs3dsp_e/ddrphy_dqo(10) -radix hexadecimal} {/testbench/nuhs3dsp_e/ddrphy_dqo(9) -radix hexadecimal} {/testbench/nuhs3dsp_e/ddrphy_dqo(8) -radix hexadecimal} {/testbench/nuhs3dsp_e/ddrphy_dqo(7) -radix hexadecimal} {/testbench/nuhs3dsp_e/ddrphy_dqo(6) -radix hexadecimal} {/testbench/nuhs3dsp_e/ddrphy_dqo(5) -radix hexadecimal} {/testbench/nuhs3dsp_e/ddrphy_dqo(4) -radix hexadecimal} {/testbench/nuhs3dsp_e/ddrphy_dqo(3) -radix hexadecimal} {/testbench/nuhs3dsp_e/ddrphy_dqo(2) -radix hexadecimal} {/testbench/nuhs3dsp_e/ddrphy_dqo(1) -radix hexadecimal} {/testbench/nuhs3dsp_e/ddrphy_dqo(0) -radix hexadecimal}} -subitemconfig {/testbench/nuhs3dsp_e/ddrphy_dqo(31) {-height 16 -radix hexadecimal} /testbench/nuhs3dsp_e/ddrphy_dqo(30) {-height 16 -radix hexadecimal} /testbench/nuhs3dsp_e/ddrphy_dqo(29) {-height 16 -radix hexadecimal} /testbench/nuhs3dsp_e/ddrphy_dqo(28) {-height 16 -radix hexadecimal} /testbench/nuhs3dsp_e/ddrphy_dqo(27) {-height 16 -radix hexadecimal} /testbench/nuhs3dsp_e/ddrphy_dqo(26) {-height 16 -radix hexadecimal} /testbench/nuhs3dsp_e/ddrphy_dqo(25) {-height 16 -radix hexadecimal} /testbench/nuhs3dsp_e/ddrphy_dqo(24) {-height 16 -radix hexadecimal} /testbench/nuhs3dsp_e/ddrphy_dqo(23) {-height 16 -radix hexadecimal} /testbench/nuhs3dsp_e/ddrphy_dqo(22) {-height 16 -radix hexadecimal} /testbench/nuhs3dsp_e/ddrphy_dqo(21) {-height 16 -radix hexadecimal} /testbench/nuhs3dsp_e/ddrphy_dqo(20) {-height 16 -radix hexadecimal} /testbench/nuhs3dsp_e/ddrphy_dqo(19) {-height 16 -radix hexadecimal} /testbench/nuhs3dsp_e/ddrphy_dqo(18) {-height 16 -radix hexadecimal} /testbench/nuhs3dsp_e/ddrphy_dqo(17) {-height 16 -radix hexadecimal} /testbench/nuhs3dsp_e/ddrphy_dqo(16) {-height 16 -radix hexadecimal} /testbench/nuhs3dsp_e/ddrphy_dqo(15) {-height 16 -radix hexadecimal} /testbench/nuhs3dsp_e/ddrphy_dqo(14) {-height 16 -radix hexadecimal} /testbench/nuhs3dsp_e/ddrphy_dqo(13) {-height 16 -radix hexadecimal} /testbench/nuhs3dsp_e/ddrphy_dqo(12) {-height 16 -radix hexadecimal} /testbench/nuhs3dsp_e/ddrphy_dqo(11) {-height 16 -radix hexadecimal} /testbench/nuhs3dsp_e/ddrphy_dqo(10) {-height 16 -radix hexadecimal} /testbench/nuhs3dsp_e/ddrphy_dqo(9) {-height 16 -radix hexadecimal} /testbench/nuhs3dsp_e/ddrphy_dqo(8) {-height 16 -radix hexadecimal} /testbench/nuhs3dsp_e/ddrphy_dqo(7) {-height 16 -radix hexadecimal} /testbench/nuhs3dsp_e/ddrphy_dqo(6) {-height 16 -radix hexadecimal} /testbench/nuhs3dsp_e/ddrphy_dqo(5) {-height 16 -radix hexadecimal} /testbench/nuhs3dsp_e/ddrphy_dqo(4) {-height 16 -radix hexadecimal} /testbench/nuhs3dsp_e/ddrphy_dqo(3) {-height 16 -radix hexadecimal} /testbench/nuhs3dsp_e/ddrphy_dqo(2) {-height 16 -radix hexadecimal} /testbench/nuhs3dsp_e/ddrphy_dqo(1) {-height 16 -radix hexadecimal} /testbench/nuhs3dsp_e/ddrphy_dqo(0) {-height 16 -radix hexadecimal}} /testbench/nuhs3dsp_e/ddrphy_dqo
add wave -noupdate -radix hexadecimal /testbench/nuhs3dsp_e/pllq0
add wave -noupdate /testbench/nuhs3dsp_e/ddrs_clk90
add wave -noupdate -radix hexadecimal -childformat {{/testbench/nuhs3dsp_e/serq90(3) -radix hexadecimal} {/testbench/nuhs3dsp_e/serq90(2) -radix hexadecimal} {/testbench/nuhs3dsp_e/serq90(1) -radix hexadecimal} {/testbench/nuhs3dsp_e/serq90(0) -radix hexadecimal}} -subitemconfig {/testbench/nuhs3dsp_e/scope_e_ddr_e_wrfifo_i_xdr_fifo_g_0_outbyte_i_aser_q_0_Q {-radix hexadecimal} /testbench/nuhs3dsp_e/scope_e_ddr_e_wrfifo_i_xdr_fifo_g_0_outbyte_i_aser_q_1_Q {-radix hexadecimal} /testbench/nuhs3dsp_e/scope_e_ddr_e_wrfifo_i_xdr_fifo_g_0_outbyte_i_aser_q_2_Q {-radix hexadecimal} /testbench/nuhs3dsp_e/scope_e_ddr_e_wrfifo_i_xdr_fifo_g_0_outbyte_i_aser_q_3_Q {-radix hexadecimal}} /testbench/nuhs3dsp_e/serq90
add wave -noupdate -label serq270 -radix hexadecimal -childformat {{/testbench/nuhs3dsp_e/serq00(3) -radix hexadecimal} {/testbench/nuhs3dsp_e/serq00(2) -radix hexadecimal} {/testbench/nuhs3dsp_e/serq00(1) -radix hexadecimal} {/testbench/nuhs3dsp_e/serq00(0) -radix hexadecimal}} -expand -subitemconfig {/testbench/nuhs3dsp_e/scope_e_ddr_e_wrfifo_i_xdr_fifo_g_0_outbyte_i_aser_q0_0_Q {-radix hexadecimal} /testbench/nuhs3dsp_e/scope_e_ddr_e_wrfifo_i_xdr_fifo_g_0_outbyte_i_aser_q0_1_Q {-radix hexadecimal} /testbench/nuhs3dsp_e/scope_e_ddr_e_wrfifo_i_xdr_fifo_g_0_outbyte_i_aser_q0_2_Q {-radix hexadecimal} /testbench/nuhs3dsp_e/scope_e_ddr_e_wrfifo_i_xdr_fifo_g_0_outbyte_i_aser_q0_3_Q {-radix hexadecimal}} /testbench/nuhs3dsp_e/serq00
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix hexadecimal /testbench/nuhs3dsp_e/pllq1
add wave -noupdate -radix hexadecimal /testbench/nuhs3dsp_e/serq190
add wave -noupdate -label serq1270 -radix hexadecimal /testbench/nuhs3dsp_e/serq100
add wave -noupdate /testbench/nuhs3dsp_e/scope_e_ddr_e_rdfifo_i_bytes_g_0_data_phases_g_0_inbyte_i_aser_q_1_CEINV_23698
add wave -noupdate /testbench/nuhs3dsp_e/scope_e_ddr_e_rdfifo_i_bytes_g_0_data_phases_g_1_inbyte_i_aser_q_3_CEINV_23651
add wave -noupdate /testbench/nuhs3dsp_e/scope_e_ddrs_do_23_SRINV_21890
add wave -noupdate /testbench/nuhs3dsp_e/scope_e_ddrs_do_23_DIF_MUX_21911
add wave -noupdate /testbench/nuhs3dsp_e/scope_e_ddrs_do_23_CLKINV_21896
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 7} {6090936 ps} 0} {{Cursor 8} {25236960 ps} 0}
quietly wave cursor active 2
configure wave -namecolwidth 218
configure wave -valuecolwidth 100
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
WaveRestoreZoom {25209074 ps} {25304786 ps}
