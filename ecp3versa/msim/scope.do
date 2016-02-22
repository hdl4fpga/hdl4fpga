onerror {resume}
quietly virtual signal -install /testbench/ecp3versa_e/scope_e/ddr_e/xdr_pgm_e { (context /testbench/ecp3versa_e/scope_e/ddr_e/xdr_pgm_e )(xdr_pgm_ref & xdr_pgm_rrdy & xdr_pgm_req )} pgm_cmd2
quietly virtual signal -install /testbench/ecp3versa_e {/testbench/ecp3versa_e/phy1_tx_d  } iii
quietly virtual signal -install /testbench/ecp3versa_e {/testbench/ecp3versa_e/phy1_tx_d  } sss
quietly virtual signal -install /testbench/ecp3versa_e { (context /testbench/ecp3versa_e )( phy1_tx_d(7) & phy1_tx_d(6) & phy1_tx_d(5) & phy1_tx_d(4) & phy1_tx_d(3) & phy1_tx_d(2) & phy1_tx_d(1) & phy1_tx_d(0) )} sss001
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/xtal
add wave -noupdate /testbench/ddr_clk_p
add wave -noupdate /testbench/rst_n
add wave -noupdate /testbench/cke
add wave -noupdate /testbench/cs_n
add wave -noupdate /testbench/ras_n
add wave -noupdate /testbench/cas_n
add wave -noupdate /testbench/we_n
add wave -noupdate -radix hexadecimal /testbench/ba
add wave -noupdate -radix hexadecimal /testbench/addr
add wave -noupdate -radix hexadecimal /testbench/dq
add wave -noupdate -expand /testbench/dqs_p
add wave -noupdate -radix hexadecimal /testbench/ecp3versa_e/scope_e/ddr_dqo
add wave -noupdate /testbench/ecp3versa_e/scope_e/ddr_e/sys_di_rdy
add wave -noupdate -radix hexadecimal /testbench/ecp3versa_e/scope_e/ddr_e/sys_di
add wave -noupdate /testbench/ecp3versa_e/ddrphy_e/byte_g(0)/ddr3phy_i/oddr_g(0)/oddrtdqa_i/sclk
add wave -noupdate /testbench/ecp3versa_e/ddrphy_e/byte_g(0)/ddr3phy_i/oddr_g(0)/oddrtdqa_i/dqclk1
add wave -noupdate /testbench/ecp3versa_e/ddrphy_e/byte_g(0)/ddr3phy_i/oddr_g(0)/oddrtdqa_i/dqclk0
add wave -noupdate /testbench/ecp3versa_e/ddrphy_e/byte_g(0)/ddr3phy_i/oddr_g(0)/oddrtdqa_i/ta
add wave -noupdate /testbench/ecp3versa_e/ddrphy_e/byte_g(0)/ddr3phy_i/oddr_g(0)/oddrtdqa_i/QB
add wave -noupdate /testbench/ecp3versa_e/ddrphy_e/byte_g(0)/ddr3phy_i/oddr_g(0)/oddrtdqa_i/QT1
add wave -noupdate /testbench/ecp3versa_e/ddrphy_e/byte_g(0)/ddr3phy_i/oddr_g(0)/oddrtdqa_i/q
add wave -noupdate /testbench/ecp3versa_e/ddrphy_e/eclksynca_i/ECLKO
add wave -noupdate /testbench/ecp3versa_e/ddrphy_e/eclksynca_i/ECLKI
add wave -noupdate /testbench/ecp3versa_e/ddrphy_e/eclksynca_i/STOP
add wave -noupdate /testbench/ecp3versa_e/ddrphy_e/byte_g(0)/ddr3phy_i/dqsbufd_i/rst
add wave -noupdate /testbench/ecp3versa_e/ddrphy_e/byte_g(0)/ddr3phy_i/dqsbufd_i/sclk
add wave -noupdate /testbench/ecp3versa_e/ddrphy_e/byte_g(0)/ddr3phy_i/dqsbufd_i/dqclk1
add wave -noupdate /testbench/ecp3versa_e/ddrphy_e/dqclk_b/dqclk1bar_ff_q
add wave -noupdate /testbench/ecp3versa_e/ddrphy_e/byte_g(0)/ddr3phy_i/dqsbufd_i/eclkwb_int1
add wave -noupdate /testbench/ecp3versa_e/ddrphy_e/dqsdll_b/lock
add wave -noupdate /testbench/ecp3versa_e/ddrphy_e/dqsdll_b/rst
add wave -noupdate /testbench/ecp3versa_e/ddrphy_e/dqsdll_b/uddcntln
add wave -noupdate /testbench/ecp3versa_e/ddrphy_e/dqsbufd_rst
add wave -noupdate /testbench/ecp3versa_e/ddrphy_e/sys_sclk
add wave -noupdate /testbench/ecp3versa_e/ddrphy_e/sys_sclk2x
add wave -noupdate /testbench/ecp3versa_e/ddrphy_e/sys_eclk
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2074500 ps} 0} {{Cursor 2} {17323469 ps} 0}
quietly wave cursor active 2
configure wave -namecolwidth 129
configure wave -valuecolwidth 92
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
configure wave -timelineunits ns
update
WaveRestoreZoom {17310396 ps} {17368199 ps}
