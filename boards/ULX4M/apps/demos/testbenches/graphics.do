onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/du_e/clk_25mhz
add wave -noupdate -expand -group rgmii /testbench/du_e/rgmii_rx_clk
add wave -noupdate -expand -group rgmii /testbench/du_e/rgmii_rx_dv
add wave -noupdate -expand -group rgmii -radix hexadecimal /testbench/du_e/rgmii_rxd
add wave -noupdate -expand -group rgmii /testbench/du_e/rgmii_tx_clk
add wave -noupdate -expand -group rgmii /testbench/du_e/rgmii_tx_en
add wave -noupdate -expand -group rgmii -radix hexadecimal /testbench/du_e/rgmii_txd
add wave -noupdate -expand -group ddram /testbench/du_e/ddram_clk
add wave -noupdate -expand -group ddram /testbench/du_e/ddram_reset_n
add wave -noupdate -expand -group ddram /testbench/du_e/ddram_cke
add wave -noupdate -expand -group ddram /testbench/du_e/ddram_cs_n
add wave -noupdate -expand -group ddram /testbench/du_e/ddram_ras_n
add wave -noupdate -expand -group ddram /testbench/du_e/ddram_cas_n
add wave -noupdate -expand -group ddram /testbench/du_e/ddram_we_n
add wave -noupdate -expand -group ddram /testbench/du_e/ddram_odt
add wave -noupdate -expand -group ddram -radix hexadecimal /testbench/du_e/ddram_a
add wave -noupdate -expand -group ddram -radix hexadecimal /testbench/du_e/ddram_ba
add wave -noupdate -expand -group ddram -radix hexadecimal /testbench/du_e/ddram_dm
add wave -noupdate -expand -group ddram /testbench/du_e/ddram_dqs
add wave -noupdate -expand -group ddram -radix hexadecimal /testbench/du_e/ddram_dq
add wave -noupdate /testbench/du_e/ddrphy_e/phy_sti
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/dqsr90
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/sclk
add wave -noupdate /testbench/du_e/ddrphy_e/phy_sti(0)
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/wl_b/dqsbufm_i/BURSTDET
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/wl_b/dqsbufm_i/DATAVALID
add wave -noupdate -radix hexadecimal /testbench/du_e/ddrphy_e/phy_dqo
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {23751770410 fs} 0}
quietly wave cursor active 1
configure wave -namecolwidth 192
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
WaveRestoreZoom {23745900160 fs} {23757640660 fs}
