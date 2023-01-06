onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {New Divider}
add wave -noupdate -group phy1 /testbench/du_e/phy1_gtxclk
add wave -noupdate -group phy1 -radix hexadecimal /testbench/du_e/phy1_rx_dv
add wave -noupdate -group phy1 -radix hexadecimal /testbench/du_e/phy1_rx_d
add wave -noupdate -group phy1 /testbench/du_e/phy1_tx_en
add wave -noupdate -group phy1 /testbench/du_e/phy1_tx_d
add wave -noupdate -group ddr3 /testbench/du_e/ddr3_clk
add wave -noupdate -group ddr3 /testbench/du_e/ddr3_rst
add wave -noupdate -group ddr3 /testbench/du_e/ddr3_cke
add wave -noupdate -group ddr3 /testbench/du_e/ddr3_cs
add wave -noupdate -group ddr3 /testbench/du_e/ddr3_ras
add wave -noupdate -group ddr3 /testbench/du_e/ddr3_cas
add wave -noupdate -group ddr3 /testbench/du_e/ddr3_we
add wave -noupdate -group ddr3 -radix hexadecimal /testbench/du_e/ddr3_a
add wave -noupdate -group ddr3 /testbench/du_e/ddr3_dm
add wave -noupdate -group ddr3 -expand /testbench/du_e/ddr3_dqs
add wave -noupdate -group ddr3 -radix hexadecimal /testbench/du_e/ddr3_dq
add wave -noupdate -group ddr3 /testbench/du_e/ddr3_odt
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/sdrphy_b/sdrphy_e/sclk
add wave -noupdate /testbench/du_e/sdrphy_b/sdrphy_e/sclk2x
add wave -noupdate /testbench/du_e/sdrphy_b/sdrphy_e/eclk
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/sdrphy_b/rst
add wave -noupdate /testbench/du_e/sdrphy_b/sclk
add wave -noupdate /testbench/du_e/sdrphy_b/sclk2x
add wave -noupdate /testbench/du_e/sdrphy_b/eclk
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/ctlrpll_b/lock
add wave -noupdate /testbench/du_e/ctlrpll_b/dtct_req
add wave -noupdate /testbench/du_e/ctlrpll_b/dtct_rdy
add wave -noupdate /testbench/du_e/ctlrpll_b/step_req
add wave -noupdate /testbench/du_e/ctlrpll_b/step_rdy
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/ctlrpll_b/line__393/state
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/ctlrpll_b/phadctor_e/line__70/sy_step_rdy
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {191583 ps} 0} {{Cursor 2} {25722515 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 194
configure wave -valuecolwidth 78
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
WaveRestoreZoom {0 ps} {1050 ns}
