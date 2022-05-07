onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/du_e/clk_25mhz
add wave -noupdate /testbench/du_e/rgmii_rx_clk
add wave -noupdate /testbench/du_e/rgmii_rx_dv
add wave -noupdate -radix hexadecimal /testbench/du_e/rgmii_rxd
add wave -noupdate /testbench/du_e/rgmii_tx_clk
add wave -noupdate /testbench/du_e/rgmii_tx_en
add wave -noupdate -radix hexadecimal /testbench/du_e/rgmii_txd
add wave -noupdate -radix hexadecimal /testbench/du_e/ddr_ba
add wave -noupdate -radix hexadecimal /testbench/du_e/ddr_a
add wave -noupdate -expand -group ddr3 /testbench/mt_u/ck
add wave -noupdate -expand -group ddr3 /testbench/mt_u/rst_n
add wave -noupdate -expand -group ddr3 /testbench/mt_u/cke
add wave -noupdate -expand -group ddr3 /testbench/mt_u/cs_n
add wave -noupdate -expand -group ddr3 /testbench/mt_u/ras_n
add wave -noupdate -expand -group ddr3 /testbench/mt_u/cas_n
add wave -noupdate -expand -group ddr3 /testbench/mt_u/we_n
add wave -noupdate -expand -group ddr3 -radix hexadecimal /testbench/mt_u/ba
add wave -noupdate -expand -group ddr3 -radix hexadecimal /testbench/mt_u/addr
add wave -noupdate -expand -group ddr3 /testbench/mt_u/dq
add wave -noupdate -expand -group ddr3 /testbench/mt_u/dqs
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {7100552490 fs} 0}
quietly wave cursor active 1
configure wave -namecolwidth 221
configure wave -valuecolwidth 135
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
WaveRestoreZoom {0 fs} {21 us}
