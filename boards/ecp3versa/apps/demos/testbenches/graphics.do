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
add wave -noupdate -expand -group ddr3 /testbench/du_e/ddr3_dq
add wave -noupdate -expand -group ddr3 /testbench/du_e/ddr3_odt
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/clk
add wave -noupdate /testbench/du_e/ctlrpll_b/pll_i/clki
add wave -noupdate /testbench/du_e/ctlrpll_b/pll_i/clkfb
add wave -noupdate /testbench/du_e/ctlrpll_b/pll_i/lock
add wave -noupdate /testbench/du_e/ctlrpll_b/pll_i/t_vco
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {187484520 fs} 0} {{Cursor 2} {8938686874 fs} 0}
quietly wave cursor active 2
configure wave -namecolwidth 238
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
WaveRestoreZoom {8701476655 fs} {9005588177 fs}
