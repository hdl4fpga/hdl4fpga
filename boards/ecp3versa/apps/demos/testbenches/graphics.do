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
add wave -noupdate -group csa /testbench/du_e/sdrphy_b/ecp3_csa_e/reset
add wave -noupdate -group csa /testbench/du_e/sdrphy_b/ecp3_csa_e/reset_datapath
add wave -noupdate -group csa /testbench/du_e/sdrphy_b/ecp3_csa_e/refclk
add wave -noupdate -group csa /testbench/du_e/sdrphy_b/ecp3_csa_e/eclk
add wave -noupdate -group csa /testbench/du_e/sdrphy_b/ecp3_csa_e/sclk
add wave -noupdate -group csa /testbench/du_e/sdrphy_b/ecp3_csa_e/sclk2x
add wave -noupdate -group csa /testbench/du_e/sdrphy_b/ecp3_csa_e/all_lock
add wave -noupdate -group csa -radix hexadecimal /testbench/du_e/sdrphy_b/ecp3_csa_e/pll_control/retry_cnt
add wave -noupdate -group csa -radix hexadecimal /testbench/du_e/sdrphy_b/ecp3_csa_e/pll_control/timer
add wave -noupdate -group csa /testbench/du_e/sdrphy_b/ecp3_csa_e/pll_control/state
add wave -noupdate -group csa /testbench/du_e/sdrphy_b/ecp3_csa_e/clk_phase/reset
add wave -noupdate -group csa /testbench/du_e/sdrphy_b/ecp3_csa_e/clk_phase/eclk
add wave -noupdate -group csa /testbench/du_e/sdrphy_b/ecp3_csa_e/clk_phase/eclksync
add wave -noupdate -group csa /testbench/du_e/sdrphy_b/ecp3_csa_e/clk_phase/sclk
add wave -noupdate -group csa /testbench/du_e/sdrphy_b/ecp3_csa_e/clk_phase/align_status
add wave -noupdate -group csa /testbench/du_e/sdrphy_b/ecp3_csa_e/clk_phase/dqclk1bar_ff
add wave -noupdate -group csa /testbench/du_e/sdrphy_b/ecp3_csa_e/clk_phase/phase_ff_1
add wave -noupdate -group csa /testbench/du_e/sdrphy_b/ecp3_csa_e/clk_phase/phase_ff_0
add wave -noupdate -group csa /testbench/du_e/sdrphy_b/ecp3_csa_e/good
add wave -noupdate -group csa /testbench/du_e/sdrphy_b/ecp3_csa_e/err
add wave -noupdate /testbench/du_e/sdrphy_b/sdrphy_e/byte_g(0)/sdr3phy_i/rl_b/adjsto_b/det
add wave -noupdate /testbench/du_e/sdrphy_b/sdrphy_e/byte_g(0)/sdr3phy_i/locked
add wave -noupdate /testbench/du_e/sdrphy_b/sdrphy_e/locked
add wave -noupdate /testbench/du_e/seg_a
add wave -noupdate /testbench/du_e/sdrphy_b/sdrphy_e/byte_g(0)/sdr3phy_i/rl_b/adjsto_b/line__170/cntr
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/videoio_clk
add wave -noupdate /testbench/du_e/video_shift_clk
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix hexadecimal /testbench/du_e/sdrphy_b/sdrphy_e/byte_g(1)/sdr3phy_i/dyndelay
add wave -noupdate /testbench/du_e/sdrphy_b/sdrphy_e/byte_g(0)/sdr3phy_i/dqclk1
add wave -noupdate /testbench/du_e/sdrphy_b/sdrphy_e/byte_g(0)/sdr3phy_i/dqclk0
add wave -noupdate /testbench/du_e/sdrphy_b/sdrphy_e/byte_g(0)/sdr3phy_i/dqsw
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/sdrphy_b/sdrphy_e/byte_g(0)/sdr3phy_i/sclk
add wave -noupdate /testbench/du_e/sdrphy_b/sdrphy_e/byte_g(0)/sdr3phy_i/eclk
add wave -noupdate /testbench/du_e/sdrphy_b/sdrphy_e/byte_g(0)/sdr3phy_i/dqclk1
add wave -noupdate /testbench/du_e/sdrphy_b/sdrphy_e/byte_g(0)/sdr3phy_i/dqclk0
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {17642276 ps} 0} {{Cursor 2} {101032388 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 237
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
WaveRestoreZoom {0 ps} {105 us}
