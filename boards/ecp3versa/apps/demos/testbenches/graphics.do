onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {New Divider}
add wave -noupdate -expand -group phy1 /testbench/du_e/phy1_gtxclk
add wave -noupdate -expand -group phy1 -radix hexadecimal /testbench/du_e/phy1_rx_dv
add wave -noupdate -expand -group phy1 -radix hexadecimal /testbench/du_e/phy1_rx_d
add wave -noupdate -expand -group phy1 /testbench/du_e/phy1_tx_en
add wave -noupdate -expand -group phy1 -radix hexadecimal /testbench/du_e/phy1_tx_d
add wave -noupdate -expand -group ddr3 /testbench/du_e/ddr3_clk
add wave -noupdate -expand -group ddr3 /testbench/du_e/ddr3_rst
add wave -noupdate -expand -group ddr3 /testbench/du_e/ddr3_cke
add wave -noupdate -expand -group ddr3 /testbench/du_e/ddr3_cs
add wave -noupdate -expand -group ddr3 /testbench/du_e/ddr3_ras
add wave -noupdate -expand -group ddr3 /testbench/du_e/ddr3_cas
add wave -noupdate -expand -group ddr3 /testbench/du_e/ddr3_we
add wave -noupdate -expand -group ddr3 -radix hexadecimal /testbench/du_e/ddr3_a
add wave -noupdate -expand -group ddr3 /testbench/du_e/ddr3_dm
add wave -noupdate -expand -group ddr3 -expand /testbench/du_e/ddr3_dqs
add wave -noupdate -expand -group ddr3 -radix hexadecimal /testbench/du_e/ddr3_dq
add wave -noupdate -expand -group ddr3 /testbench/du_e/ddr3_odt
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/grahics_e/ctlr_inirdy
add wave -noupdate /testbench/du_e/sdrphy_b/sdrphy_e/byte_g(0)/sdr3phy_i/dqsbufd_i/eclk_quarter_period
add wave -noupdate /testbench/du_e/ddr_tcp
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix hexadecimal /testbench/du_e/sdrphy_b/sdrphy_e/byte_g(0)/sdr3phy_i/rl_b/adjsto_b/line__171/cntr
add wave -noupdate /testbench/du_e/sdrphy_b/sdrphy_e/byte_g(0)/sdr3phy_i/phy_wlreq
add wave -noupdate /testbench/du_e/sdrphy_b/sdrphy_e/byte_g(0)/sdr3phy_i/phy_wlrdy
add wave -noupdate /testbench/du_e/sdrphy_b/sdrphy_e/byte_g(0)/sdr3phy_i/phy_rlreq
add wave -noupdate /testbench/du_e/sdrphy_b/sdrphy_e/byte_g(0)/sdr3phy_i/phy_rlrdy
add wave -noupdate /testbench/du_e/sdrphy_b/sdrphy_e/byte_g(0)/sdr3phy_i/read_rdy
add wave -noupdate /testbench/du_e/sdrphy_b/sdrphy_e/byte_g(0)/sdr3phy_i/read_req
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/sdrphy_b/sdrphy_e/byte_g(1)/sdr3phy_i/dqsbufd_i/prmbdet
add wave -noupdate /testbench/du_e/sdrphy_b/sdrphy_e/byte_g(1)/sdr3phy_i/dqsbufd_i/datavalid
add wave -noupdate /testbench/du_e/sdrphy_b/sdrphy_e/sclk
add wave -noupdate /testbench/du_e/sdrphy_b/sdrphy_e/byte_g(1)/sdr3phy_i/dqsbufd_i/eclkdqsr
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {51799906 ps} 0} {{Cursor 2} {41154269 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 227
configure wave -valuecolwidth 171
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
WaveRestoreZoom {51738434 ps} {51840978 ps}
