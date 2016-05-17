onerror {resume}
quietly virtual signal -install /testbench { /testbench/dq(15 downto 0)} dq16
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider testbench
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/clk_p(0)
add wave -noupdate /testbench/cke
add wave -noupdate /testbench/cs_n
add wave -noupdate /testbench/ras_n
add wave -noupdate /testbench/cas_n
add wave -noupdate /testbench/we_n
add wave -noupdate /testbench/ba
add wave -noupdate -radix hexadecimal /testbench/addr
add wave -noupdate /testbench/dqs
add wave -noupdate -radix hexadecimal -childformat {{/testbench/dq(63) -radix hexadecimal} {/testbench/dq(62) -radix hexadecimal} {/testbench/dq(61) -radix hexadecimal} {/testbench/dq(60) -radix hexadecimal} {/testbench/dq(59) -radix hexadecimal} {/testbench/dq(58) -radix hexadecimal} {/testbench/dq(57) -radix hexadecimal} {/testbench/dq(56) -radix hexadecimal} {/testbench/dq(55) -radix hexadecimal} {/testbench/dq(54) -radix hexadecimal} {/testbench/dq(53) -radix hexadecimal} {/testbench/dq(52) -radix hexadecimal} {/testbench/dq(51) -radix hexadecimal} {/testbench/dq(50) -radix hexadecimal} {/testbench/dq(49) -radix hexadecimal} {/testbench/dq(48) -radix hexadecimal} {/testbench/dq(47) -radix hexadecimal} {/testbench/dq(46) -radix hexadecimal} {/testbench/dq(45) -radix hexadecimal} {/testbench/dq(44) -radix hexadecimal} {/testbench/dq(43) -radix hexadecimal} {/testbench/dq(42) -radix hexadecimal} {/testbench/dq(41) -radix hexadecimal} {/testbench/dq(40) -radix hexadecimal} {/testbench/dq(39) -radix hexadecimal} {/testbench/dq(38) -radix hexadecimal} {/testbench/dq(37) -radix hexadecimal} {/testbench/dq(36) -radix hexadecimal} {/testbench/dq(35) -radix hexadecimal} {/testbench/dq(34) -radix hexadecimal} {/testbench/dq(33) -radix hexadecimal} {/testbench/dq(32) -radix hexadecimal} {/testbench/dq(31) -radix hexadecimal} {/testbench/dq(30) -radix hexadecimal} {/testbench/dq(29) -radix hexadecimal} {/testbench/dq(28) -radix hexadecimal} {/testbench/dq(27) -radix hexadecimal} {/testbench/dq(26) -radix hexadecimal} {/testbench/dq(25) -radix hexadecimal} {/testbench/dq(24) -radix hexadecimal} {/testbench/dq(23) -radix hexadecimal} {/testbench/dq(22) -radix hexadecimal} {/testbench/dq(21) -radix hexadecimal} {/testbench/dq(20) -radix hexadecimal} {/testbench/dq(19) -radix hexadecimal} {/testbench/dq(18) -radix hexadecimal} {/testbench/dq(17) -radix hexadecimal} {/testbench/dq(16) -radix hexadecimal} {/testbench/dq(15) -radix hexadecimal} {/testbench/dq(14) -radix hexadecimal} {/testbench/dq(13) -radix hexadecimal} {/testbench/dq(12) -radix hexadecimal} {/testbench/dq(11) -radix hexadecimal} {/testbench/dq(10) -radix hexadecimal} {/testbench/dq(9) -radix hexadecimal} {/testbench/dq(8) -radix hexadecimal} {/testbench/dq(7) -radix hexadecimal} {/testbench/dq(6) -radix hexadecimal} {/testbench/dq(5) -radix hexadecimal} {/testbench/dq(4) -radix hexadecimal} {/testbench/dq(3) -radix hexadecimal} {/testbench/dq(2) -radix hexadecimal} {/testbench/dq(1) -radix hexadecimal} {/testbench/dq(0) -radix hexadecimal}} -subitemconfig {/testbench/dq(63) {-height 16 -radix hexadecimal} /testbench/dq(62) {-height 16 -radix hexadecimal} /testbench/dq(61) {-height 16 -radix hexadecimal} /testbench/dq(60) {-height 16 -radix hexadecimal} /testbench/dq(59) {-height 16 -radix hexadecimal} /testbench/dq(58) {-height 16 -radix hexadecimal} /testbench/dq(57) {-height 16 -radix hexadecimal} /testbench/dq(56) {-height 16 -radix hexadecimal} /testbench/dq(55) {-height 16 -radix hexadecimal} /testbench/dq(54) {-height 16 -radix hexadecimal} /testbench/dq(53) {-height 16 -radix hexadecimal} /testbench/dq(52) {-height 16 -radix hexadecimal} /testbench/dq(51) {-height 16 -radix hexadecimal} /testbench/dq(50) {-height 16 -radix hexadecimal} /testbench/dq(49) {-height 16 -radix hexadecimal} /testbench/dq(48) {-height 16 -radix hexadecimal} /testbench/dq(47) {-height 16 -radix hexadecimal} /testbench/dq(46) {-height 16 -radix hexadecimal} /testbench/dq(45) {-height 16 -radix hexadecimal} /testbench/dq(44) {-height 16 -radix hexadecimal} /testbench/dq(43) {-height 16 -radix hexadecimal} /testbench/dq(42) {-height 16 -radix hexadecimal} /testbench/dq(41) {-height 16 -radix hexadecimal} /testbench/dq(40) {-height 16 -radix hexadecimal} /testbench/dq(39) {-height 16 -radix hexadecimal} /testbench/dq(38) {-height 16 -radix hexadecimal} /testbench/dq(37) {-height 16 -radix hexadecimal} /testbench/dq(36) {-height 16 -radix hexadecimal} /testbench/dq(35) {-height 16 -radix hexadecimal} /testbench/dq(34) {-height 16 -radix hexadecimal} /testbench/dq(33) {-height 16 -radix hexadecimal} /testbench/dq(32) {-height 16 -radix hexadecimal} /testbench/dq(31) {-height 16 -radix hexadecimal} /testbench/dq(30) {-height 16 -radix hexadecimal} /testbench/dq(29) {-height 16 -radix hexadecimal} /testbench/dq(28) {-height 16 -radix hexadecimal} /testbench/dq(27) {-height 16 -radix hexadecimal} /testbench/dq(26) {-height 16 -radix hexadecimal} /testbench/dq(25) {-height 16 -radix hexadecimal} /testbench/dq(24) {-height 16 -radix hexadecimal} /testbench/dq(23) {-height 16 -radix hexadecimal} /testbench/dq(22) {-height 16 -radix hexadecimal} /testbench/dq(21) {-height 16 -radix hexadecimal} /testbench/dq(20) {-height 16 -radix hexadecimal} /testbench/dq(19) {-height 16 -radix hexadecimal} /testbench/dq(18) {-height 16 -radix hexadecimal} /testbench/dq(17) {-height 16 -radix hexadecimal} /testbench/dq(16) {-height 16 -radix hexadecimal} /testbench/dq(15) {-height 16 -radix hexadecimal} /testbench/dq(14) {-height 16 -radix hexadecimal} /testbench/dq(13) {-height 16 -radix hexadecimal} /testbench/dq(12) {-height 16 -radix hexadecimal} /testbench/dq(11) {-height 16 -radix hexadecimal} /testbench/dq(10) {-height 16 -radix hexadecimal} /testbench/dq(9) {-height 16 -radix hexadecimal} /testbench/dq(8) {-height 16 -radix hexadecimal} /testbench/dq(7) {-height 16 -radix hexadecimal} /testbench/dq(6) {-height 16 -radix hexadecimal} /testbench/dq(5) {-height 16 -radix hexadecimal} /testbench/dq(4) {-height 16 -radix hexadecimal} /testbench/dq(3) {-height 16 -radix hexadecimal} /testbench/dq(2) {-height 16 -radix hexadecimal} /testbench/dq(1) {-height 16 -radix hexadecimal} /testbench/dq(0) {-height 16 -radix hexadecimal}} /testbench/dq
add wave -noupdate /testbench/ml509_e/ddrs_clk0
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/ml509_e/phy_reset
add wave -noupdate -radix hexadecimal /testbench/ml509_e/phy_rxd
add wave -noupdate /testbench/ml509_e/phy_rxclk
add wave -noupdate /testbench/ml509_e/phy_rxctl_rxdv
add wave -noupdate /testbench/ml509_e/mii_rxd
add wave -noupdate /testbench/ml509_e/mii_rxdv
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 4} {1000000 ps} 0} {{Cursor 3} {5974774 ps} 0} {{Cursor 4} {6341749 ps} 0} {{Cursor 5} {9832500 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 189
configure wave -valuecolwidth 103
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
configure wave -timelineunits ps
update
WaveRestoreZoom {975122 ps} {1152074 ps}
