onerror {resume}
quietly virtual signal -install /testbench { /testbench/dq(15 downto 0)} dq16
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/rst
add wave -noupdate /testbench/clk
add wave -noupdate /testbench/clk_p(0)
add wave -noupdate -radix hexadecimal /testbench/ba
add wave -noupdate -radix hexadecimal /testbench/addr
add wave -noupdate /testbench/cke
add wave -noupdate /testbench/cs_n
add wave -noupdate /testbench/ras_n
add wave -noupdate /testbench/cas_n
add wave -noupdate /testbench/we_n
add wave -noupdate /testbench/dqs(1)
add wave -noupdate /testbench/dqs(0)
add wave -noupdate /testbench/dm(1)
add wave -noupdate /testbench/dm(0)
add wave -noupdate -radix hexadecimal /testbench/dq16
add wave -noupdate /testbench/ml509_e/phy_reset
add wave -noupdate /testbench/ml509_e/phy_rxclk
add wave -noupdate /testbench/ml509_e/phy_txc_gtxclk
add wave -noupdate /testbench/ml509_e/phy_rxctl_rxdv
add wave -noupdate /testbench/ml509_e/phy_txclk
add wave -noupdate -radix hexadecimal /testbench/ml509_e/phy_rxd
add wave -noupdate -radix hexadecimal /testbench/ml509_e/mii_rxd
add wave -noupdate /testbench/ml509_e/mii_rxdv
add wave -noupdate /testbench/ml509_e/scope_e_miitx_udprdy
add wave -noupdate /testbench/ml509_e/phy_rxclk_BUFGP
add wave -noupdate -radix hexadecimal /testbench/ml509_e/ddr2_dqo
add wave -noupdate -radix hexadecimal /testbench/ml509_e/ddr2_dqi
add wave -noupdate /testbench/rst
add wave -noupdate /testbench/clk
add wave -noupdate /testbench/clk_p(0)
add wave -noupdate -radix hexadecimal /testbench/ba
add wave -noupdate -radix hexadecimal /testbench/addr
add wave -noupdate /testbench/cke
add wave -noupdate /testbench/cs_n
add wave -noupdate /testbench/ras_n
add wave -noupdate /testbench/cas_n
add wave -noupdate /testbench/we_n
add wave -noupdate /testbench/dqs(1)
add wave -noupdate /testbench/dqs(0)
add wave -noupdate /testbench/dm(1)
add wave -noupdate /testbench/dm(0)
add wave -noupdate -radix hexadecimal /testbench/dq16
add wave -noupdate /testbench/ml509_e/phy_reset
add wave -noupdate /testbench/ml509_e/phy_rxclk
add wave -noupdate /testbench/ml509_e/phy_txc_gtxclk
add wave -noupdate /testbench/ml509_e/phy_rxctl_rxdv
add wave -noupdate /testbench/ml509_e/phy_txclk
add wave -noupdate -radix hexadecimal /testbench/ml509_e/phy_rxd
add wave -noupdate -radix hexadecimal /testbench/ml509_e/mii_rxd
add wave -noupdate /testbench/ml509_e/mii_rxdv
add wave -noupdate /testbench/ml509_e/scope_e_miitx_udprdy
add wave -noupdate /testbench/ml509_e/phy_rxclk_BUFGP
add wave -noupdate -radix hexadecimal /testbench/ml509_e/ddr2_dqo
add wave -noupdate /testbench/ml509_e/ddr_sti_1_Q
add wave -noupdate /testbench/ml509_e/ddr_sti_3_Q
add wave -noupdate /testbench/ml509_e/ddrphy_dqsi(3)
add wave -noupdate /testbench/ml509_e/ddrphy_dqsi(1)
add wave -noupdate -radix hexadecimal /testbench/ml509_e/ddr2_dqi
add wave -noupdate /testbench/ml509_e/ddrphy_dqsi(2)
add wave -noupdate /testbench/ml509_e/ddrphy_dqsi(0)
add wave -noupdate /testbench/ml509_e/scope_e_ddr_e_sys_do_rdy(1)
add wave -noupdate -radix hexadecimal /testbench/ml509_e/scope_e_ddrs_do
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {12365799 ps} 0} {{Cursor 2} {12315737 ps} 0}
quietly wave cursor active 1
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
configure wave -timelineunits ns
update
WaveRestoreZoom {12269479 ps} {12427159 ps}
