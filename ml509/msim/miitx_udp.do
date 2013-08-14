onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/rst
add wave -noupdate /testbench/clk
add wave -noupdate /testbench/phy_reset
add wave -noupdate /testbench/phy_col
add wave -noupdate /testbench/phy_crs
add wave -noupdate /testbench/phy_int
add wave -noupdate /testbench/phy_mdc
add wave -noupdate /testbench/phy_mdio
add wave -noupdate /testbench/phy_rxclk
add wave -noupdate /testbench/phy_rxctl_rxdv
add wave -noupdate -radix hexadecimal /testbench/phy_rxd
add wave -noupdate /testbench/phy_rxer
add wave -noupdate /testbench/phy_txc_gtxclk
add wave -noupdate /testbench/phy_txclk
add wave -noupdate /testbench/phy_txctl_txen
add wave -noupdate -radix hexadecimal /testbench/phy_txd
add wave -noupdate /testbench/phy_txer
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {845 ps}
