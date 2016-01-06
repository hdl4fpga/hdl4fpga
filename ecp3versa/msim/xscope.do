onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/xtal
add wave -noupdate /testbench/reset_n
add wave -noupdate /testbench/ddr_clk_p
add wave -noupdate /testbench/rst_n
add wave -noupdate /testbench/cke
add wave -noupdate /testbench/cs_n
add wave -noupdate /testbench/ras_n
add wave -noupdate /testbench/ecp3versa_e/scope_e/ddr_e/tcp
add wave -noupdate /testbench/cas_n
add wave -noupdate /testbench/we_n
add wave -noupdate /testbench/ba
add wave -noupdate /testbench/addr
add wave -noupdate /testbench/ecp3versa_e/scope_e/ddr_e/xdr_mpu_e/gear
add wave -noupdate -expand /testbench/dqs_p
add wave -noupdate /testbench/dm
add wave -noupdate -radix hexadecimal /testbench/dq
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/ecp3versa_e/ddrphy_e/byte_g(0)/ddr3phy_i/dqsbufd_i/read
add wave -noupdate /testbench/ecp3versa_e/ddrphy_e/byte_g(0)/ddr3phy_i/dqsbufd_i/A
add wave -noupdate /testbench/ecp3versa_e/ddrphy_e/byte_g(0)/ddr3phy_i/dqsbufd_i/B
add wave -noupdate /testbench/ecp3versa_e/ddrphy_e/byte_g(0)/ddr3phy_i/dqsbufd_i/C
add wave -noupdate /testbench/ecp3versa_e/ddrphy_e/byte_g(0)/ddr3phy_i/dqsbufd_i/D
add wave -noupdate /testbench/ecp3versa_e/ddrphy_e/byte_g(0)/ddr3phy_i/dqsbufd_i/rst
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/ecp3versa_e/scope_e/ddr_e/rdfifo_i/xdr_fifo_g(1)/inbyte_i/ser_clk(0)
add wave -noupdate /testbench/ecp3versa_e/scope_e/ddr_e/rdfifo_i/xdr_fifo_g(1)/inbyte_i/ser_ena(0)
add wave -noupdate -radix hexadecimal /testbench/ecp3versa_e/scope_e/ddr_e/rdfifo_i/xdr_fifo_g(1)/inbyte_i/di
add wave -noupdate /testbench/ecp3versa_e/scope_e/ddr_e/rdfifo_i/xdr_fifo_g(1)/inbyte_i/phases_g(0)/ram_b/we
add wave -noupdate -expand /testbench/ecp3versa_e/scope_e/ddr_e/rdfifo_i/sys_rdy
add wave -noupdate /testbench/ecp3versa_e/scope_e/ddr_e/rdfifo_i/xdr_fifo_g(1)/inbyte_i/phases_g(0)/aser_q
add wave -noupdate /testbench/ecp3versa_e/scope_e/ddr_e/rdfifo_i/xdr_fifo_g(1)/inbyte_i/apll_q
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {20192020 ps} 0} {{Cursor 2} {20349000 ps} 0}
quietly wave cursor active 2
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
WaveRestoreZoom {20326279 ps} {20403881 ps}
