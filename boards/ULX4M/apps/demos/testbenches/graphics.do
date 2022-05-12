onerror {resume}
quietly virtual signal -install /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/wl_b/dqsbufm_i { (context /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/wl_b/dqsbufm_i )&{READCLKSEL2 , READCLKSEL1 , READCLKSEL0 }} readclksel
quietly virtual signal -install /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/wl_b/dqsbufm_i { (context /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/wl_b/dqsbufm_i )&{READ1 , READ0 }} read
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
add wave -noupdate -expand -group dqsbufm_0 /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/wl_b/dqsbufm_i/DQSI
add wave -noupdate -expand -group dqsbufm_0 -expand /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/wl_b/dqsbufm_i/read
add wave -noupdate -expand -group dqsbufm_0 /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/wl_b/dqsbufm_i/readclksel
add wave -noupdate -expand -group dqsbufm_0 /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/wl_b/dqsbufm_i/DDRDEL
add wave -noupdate -expand -group dqsbufm_0 /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/wl_b/dqsbufm_i/ECLK
add wave -noupdate -expand -group dqsbufm_0 /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/wl_b/dqsbufm_i/SCLK
add wave -noupdate -expand -group dqsbufm_0 /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/wl_b/dqsbufm_i/DQSR90
add wave -noupdate -expand -group dqsbufm_0 /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/wl_b/dqsbufm_i/BURSTDET
add wave -noupdate -expand -group dqsbufm_0 /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/wl_b/dqsbufm_i/DATAVALID
add wave -noupdate -radix hexadecimal /testbench/du_e/ddrphy_e/phy_dqo
add wave -noupdate -radix hexadecimal /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/wrpntr
add wave -noupdate -radix hexadecimal /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/rdpntr
add wave -noupdate -radix hexadecimal /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/phy_dqo
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/wl_b/dqsbufm_i/read_q
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/wl_b/dqsbufm_i/read_ena
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/wl_b/dqsbufm_i/dqs_clean
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/wl_b/dqsbufm_i/dqs_ena
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {23752126010 fs} 0} {{Cursor 2} {23736243390 fs} 0} {{Cursor 3} {23768185100 fs} 0}
quietly wave cursor active 1
configure wave -namecolwidth 181
configure wave -valuecolwidth 236
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
WaveRestoreZoom {23726184400 fs} {23782832400 fs}
