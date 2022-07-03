onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/du_e/dcm_b/ddr_b/ddr_clk0
add wave -noupdate /testbench/du_e/dcm_b/ddr_b/ddr_clk90
add wave -noupdate -expand /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_clks
add wave -noupdate /testbench/du_e/ddr2_clk_p(0)
add wave -noupdate /testbench/du_e/ddr2_cs
add wave -noupdate /testbench/du_e/ddr2_cke
add wave -noupdate /testbench/du_e/ddr2_ras
add wave -noupdate /testbench/du_e/ddr2_cas
add wave -noupdate /testbench/du_e/ddr2_we
add wave -noupdate /testbench/du_e/ddr2_a
add wave -noupdate /testbench/du_e/ddr2_ba
add wave -noupdate /testbench/du_e/ddr2_dqs_p(0)
add wave -noupdate -radix hexadecimal /testbench/du_e/ddr2_d
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {10133320 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 170
configure wave -valuecolwidth 185
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
WaveRestoreZoom {10127426 ps} {10139214 ps}
