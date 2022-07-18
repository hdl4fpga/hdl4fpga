onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group ddr3 /testbench/du_e/ddr3_clk
add wave -noupdate -expand -group ddr3 /testbench/du_e/ddr3_rst
add wave -noupdate -expand -group ddr3 /testbench/du_e/ddr3_cke
add wave -noupdate -expand -group ddr3 /testbench/du_e/ddr3_cs
add wave -noupdate -expand -group ddr3 /testbench/du_e/ddr3_ras
add wave -noupdate -expand -group ddr3 /testbench/du_e/ddr3_cas
add wave -noupdate -expand -group ddr3 /testbench/du_e/ddr3_we
add wave -noupdate -expand -group ddr3 -radix hexadecimal /testbench/du_e/ddr3_ba
add wave -noupdate -expand -group ddr3 -radix hexadecimal /testbench/du_e/ddr3_a
add wave -noupdate -expand -group ddr3 /testbench/du_e/ddr3_dm
add wave -noupdate -expand -group ddr3 /testbench/du_e/ddr3_dqs
add wave -noupdate -expand -group ddr3 -radix hexadecimal /testbench/du_e/ddr3_dq
add wave -noupdate -expand -group ddr3 /testbench/du_e/ddr3_odt
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/grahics_e/ddr_tcp
add wave -noupdate /testbench/du_e/ddrphy_e/ddr3baphy_i/sclk
add wave -noupdate /testbench/du_e/ctlrpll_b/eclk_rpha
add wave -noupdate /testbench/du_e/ctlrpll_b/dfpa3
add wave -noupdate /testbench/du_e/ctlr_lck
add wave -noupdate /testbench/du_e/ctlrpll_b/dtct_req
add wave -noupdate /testbench/du_e/ctlrpll_b/dtct_rdy
add wave -noupdate /testbench/du_e/ctlrpll_b/step_req
add wave -noupdate /testbench/du_e/ctlrpll_b/step_rdy
add wave -noupdate /testbench/du_e/ddrphy_e/ddr3baphy_i/sclk2x
add wave -noupdate /testbench/du_e/ddr_eclk
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {25400328760 fs} 0} {{Cursor 2} {202737885 fs} 0}
quietly wave cursor active 2
configure wave -namecolwidth 183
configure wave -valuecolwidth 109
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
WaveRestoreZoom {94500 ps} {786944934 fs}
