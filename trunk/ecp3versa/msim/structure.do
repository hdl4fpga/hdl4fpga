onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/rst_n
add wave -noupdate /testbench/ddr_clk_p
add wave -noupdate /testbench/cke
add wave -noupdate /testbench/addr
add wave -noupdate /testbench/ras_n
add wave -noupdate /testbench/cas_n
add wave -noupdate /testbench/we_n
add wave -noupdate /testbench/cs_n
add wave -noupdate /testbench/dm
add wave -noupdate /testbench/dqs_p(1)
add wave -noupdate -radix hexadecimal -childformat {{/testbench/dq(15) -radix hexadecimal} {/testbench/dq(14) -radix hexadecimal} {/testbench/dq(13) -radix hexadecimal} {/testbench/dq(12) -radix hexadecimal} {/testbench/dq(11) -radix hexadecimal} {/testbench/dq(10) -radix hexadecimal} {/testbench/dq(9) -radix hexadecimal} {/testbench/dq(8) -radix hexadecimal} {/testbench/dq(7) -radix hexadecimal} {/testbench/dq(6) -radix hexadecimal} {/testbench/dq(5) -radix hexadecimal} {/testbench/dq(4) -radix hexadecimal} {/testbench/dq(3) -radix hexadecimal} {/testbench/dq(2) -radix hexadecimal} {/testbench/dq(1) -radix hexadecimal} {/testbench/dq(0) -radix hexadecimal}} -subitemconfig {/testbench/dq(15) {-height 16 -radix hexadecimal} /testbench/dq(14) {-height 16 -radix hexadecimal} /testbench/dq(13) {-height 16 -radix hexadecimal} /testbench/dq(12) {-height 16 -radix hexadecimal} /testbench/dq(11) {-height 16 -radix hexadecimal} /testbench/dq(10) {-height 16 -radix hexadecimal} /testbench/dq(9) {-height 16 -radix hexadecimal} /testbench/dq(8) {-height 16 -radix hexadecimal} /testbench/dq(7) {-height 16 -radix hexadecimal} /testbench/dq(6) {-height 16 -radix hexadecimal} /testbench/dq(5) {-height 16 -radix hexadecimal} /testbench/dq(4) {-height 16 -radix hexadecimal} /testbench/dq(3) {-height 16 -radix hexadecimal} /testbench/dq(2) {-height 16 -radix hexadecimal} /testbench/dq(1) {-height 16 -radix hexadecimal} /testbench/dq(0) {-height 16 -radix hexadecimal}} /testbench/dq
add wave -noupdate /testbench/dqs_p(0)
add wave -noupdate -divider ddr3_dqs_0
add wave -noupdate /testbench/ecp3versa_e/ddrphy_e_byte_g_0_ddr3phy_i_dqsbufd_iI/DATAVALID
add wave -noupdate /testbench/ecp3versa_e/ddrphy_e_byte_g_0_ddr3phy_i_dqsbufd_iI/DDRCLKPOL
add wave -noupdate /testbench/ecp3versa_e/ddrphy_e_byte_g_0_ddr3phy_i_dqsbufd_iI/DDRLAT
add wave -noupdate /testbench/ecp3versa_e/ddrphy_e_byte_g_0_ddr3phy_i_dqsbufd_iI/DQCLK0
add wave -noupdate /testbench/ecp3versa_e/ddrphy_e_byte_g_0_ddr3phy_i_dqsbufd_iI/DQCLK1
add wave -noupdate /testbench/ecp3versa_e/ddrphy_e_byte_g_0_ddr3phy_i_dqsbufd_iI/DQSDEL
add wave -noupdate /testbench/ecp3versa_e/ddrphy_e_byte_g_0_ddr3phy_i_dqsbufd_iI/DQSI
add wave -noupdate /testbench/ecp3versa_e/ddrphy_e_byte_g_0_ddr3phy_i_dqsbufd_iI/DQSW
add wave -noupdate /testbench/ecp3versa_e/ddrphy_e_byte_g_0_ddr3phy_i_dqsbufd_iI/ECLK
add wave -noupdate /testbench/ecp3versa_e/ddrphy_e_byte_g_0_ddr3phy_i_dqsbufd_iI/ECLKDQSR
add wave -noupdate /testbench/ecp3versa_e/ddrphy_e_byte_g_0_ddr3phy_i_dqsbufd_iI/ECLKW
add wave -noupdate /testbench/ecp3versa_e/ddrphy_e_byte_g_0_ddr3phy_i_dqsbufd_iI/READ
add wave -noupdate /testbench/ecp3versa_e/ddrphy_e_byte_g_0_ddr3phy_i_dqsbufd_iI/RST
add wave -noupdate /testbench/ecp3versa_e/ddrphy_e_byte_g_0_ddr3phy_i_dqsbufd_iI/SCLK
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/ecp3versa_e/ddr3_dqs_0_MGIOLI/CLK
add wave -noupdate /testbench/ecp3versa_e/ddr3_dqs_0_MGIOLI/DQCLK0
add wave -noupdate /testbench/ecp3versa_e/ddr3_dqs_0_MGIOLI/DQCLK1
add wave -noupdate /testbench/ecp3versa_e/ddr3_dqs_0_MGIOLI/DQSTCLKI
add wave -noupdate /testbench/ecp3versa_e/ddr3_dqs_0_MGIOLI/DQSW
add wave -noupdate /testbench/ecp3versa_e/ddr3_dqs_0_MGIOLI/OPOSA
add wave -noupdate /testbench/ecp3versa_e/ddr3_dqs_0_MGIOLI/OPOSB
add wave -noupdate /testbench/ecp3versa_e/ddr3_dqs_0_MGIOLI/ONEGB
add wave -noupdate /testbench/ecp3versa_e/ddr3_dqs_0_MGIOLI/TS
add wave -noupdate /testbench/ecp3versa_e/ddr3_dqs_0_MGIOLI/DQSTCLKO
add wave -noupdate /testbench/ecp3versa_e/ddr3_dqs_0_MGIOLI/IOLTO
add wave -noupdate /testbench/ecp3versa_e/ddr3_dqs_0_MGIOLI/IOLDO
add wave -noupdate -divider ddr3_dqs_1
add wave -noupdate /testbench/ecp3versa_e/ddrphy_e_byte_g_1_ddr3phy_i_dqsbufd_iI/DDRCLKPOL
add wave -noupdate /testbench/ecp3versa_e/ddrphy_e_byte_g_1_ddr3phy_i_dqsbufd_iI/DDRLAT
add wave -noupdate /testbench/ecp3versa_e/ddrphy_e_byte_g_1_ddr3phy_i_dqsbufd_iI/DQCLK0
add wave -noupdate /testbench/ecp3versa_e/ddrphy_e_byte_g_1_ddr3phy_i_dqsbufd_iI/DQCLK1
add wave -noupdate /testbench/ecp3versa_e/ddrphy_e_byte_g_1_ddr3phy_i_dqsbufd_iI/DQSDEL
add wave -noupdate /testbench/ecp3versa_e/ddrphy_e_byte_g_1_ddr3phy_i_dqsbufd_iI/DQSI
add wave -noupdate /testbench/ecp3versa_e/ddrphy_e_byte_g_1_ddr3phy_i_dqsbufd_iI/DQSW
add wave -noupdate /testbench/ecp3versa_e/ddrphy_e_byte_g_1_ddr3phy_i_dqsbufd_iI/ECLK
add wave -noupdate /testbench/ecp3versa_e/ddrphy_e_byte_g_1_ddr3phy_i_dqsbufd_iI/ECLKDQSR
add wave -noupdate /testbench/ecp3versa_e/ddrphy_e_byte_g_1_ddr3phy_i_dqsbufd_iI/ECLKW
add wave -noupdate /testbench/ecp3versa_e/ddrphy_e_byte_g_1_ddr3phy_i_dqsbufd_iI/READ
add wave -noupdate /testbench/ecp3versa_e/ddrphy_e_byte_g_1_ddr3phy_i_dqsbufd_iI/RST
add wave -noupdate /testbench/ecp3versa_e/ddrphy_e_byte_g_1_ddr3phy_i_dqsbufd_iI/SCLK
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/ecp3versa_e/ddr3_dqs_1_MGIOLI/CLK
add wave -noupdate /testbench/ecp3versa_e/ddr3_dqs_1_MGIOLI/DQCLK0
add wave -noupdate /testbench/ecp3versa_e/ddr3_dqs_1_MGIOLI/DQCLK1
add wave -noupdate /testbench/ecp3versa_e/ddr3_dqs_1_MGIOLI/DQSTCLKI
add wave -noupdate /testbench/ecp3versa_e/ddr3_dqs_1_MGIOLI/DQSW
add wave -noupdate /testbench/ecp3versa_e/ddr3_dqs_1_MGIOLI/OPOSA
add wave -noupdate /testbench/ecp3versa_e/ddr3_dqs_1_MGIOLI/OPOSB
add wave -noupdate /testbench/ecp3versa_e/ddr3_dqs_1_MGIOLI/ONEGB
add wave -noupdate /testbench/ecp3versa_e/ddr3_dqs_1_MGIOLI/TS
add wave -noupdate /testbench/ecp3versa_e/ddr3_dqs_1_MGIOLI/DQSTCLKO
add wave -noupdate /testbench/ecp3versa_e/ddr3_dqs_1_MGIOLI/IOLTO
add wave -noupdate /testbench/ecp3versa_e/ddr3_dqs_1_MGIOLI/IOLDO
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/ecp3versa_e/dcms_e_eclk
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
WaveRestoreCursors {{Cursor 1} {8585578 ps} 0} {{Cursor 2} {6498703 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
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
WaveRestoreZoom {8561404 ps} {8679766 ps}
