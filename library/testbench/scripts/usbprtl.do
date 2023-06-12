onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/usb_clk
add wave -noupdate /testbench/dp
add wave -noupdate /testbench/dn
add wave -noupdate -divider du_block
add wave -noupdate -divider usbphy
add wave -noupdate /testbench/du_b/du/usbphy_e/j
add wave -noupdate /testbench/du_b/du/usbphy_e/k
add wave -noupdate /testbench/du_b/du/usbphy_e/se0
add wave -noupdate -group usbphy_rx /testbench/du_b/du/usbphy_e/rx_d/clk
add wave -noupdate -group usbphy_rx /testbench/du_b/du/usbphy_e/rx_d/cken
add wave -noupdate -group usbphy_rx /testbench/du_b/du/usbphy_e/rx_d/j
add wave -noupdate -group usbphy_rx /testbench/du_b/du/usbphy_e/rx_d/k
add wave -noupdate -group usbphy_rx /testbench/du_b/du/usbphy_e/rx_d/se0
add wave -noupdate -group usbphy_rx /testbench/du_b/du/usbphy_e/rx_d/rxdv
add wave -noupdate -group usbphy_rx /testbench/du_b/du/usbphy_e/rx_d/rxbs
add wave -noupdate -group usbphy_rx /testbench/du_b/du/usbphy_e/rx_d/rxd
add wave -noupdate -group usbphy_rx /testbench/du_b/du/usbphy_e/rx_d/err
add wave -noupdate -group usbphy_tx /testbench/du_b/du/usbphy_e/tx_d/line__25/state
add wave -noupdate -group usbphy_tx /testbench/du_b/du/usbphy_e/tx_d/cken
add wave -noupdate -group usbphy_tx /testbench/du_b/du/usbphy_e/tx_d/txen
add wave -noupdate -group usbphy_tx /testbench/du_b/du/usbphy_e/tx_d/txd
add wave -noupdate -group usbphy_tx /testbench/du_b/du/usbphy_e/tx_d/txbs
add wave -noupdate -group usbphy_tx /testbench/du_b/du/usbphy_e/tx_d/txdp
add wave -noupdate -group usbphy_tx /testbench/du_b/du/usbphy_e/tx_d/txdn
add wave -noupdate -divider du_usbprtl
add wave -noupdate -radix hexadecimal -childformat {{/testbench/du_b/rx_p/data(0) -radix hexadecimal} {/testbench/du_b/rx_p/data(1) -radix hexadecimal} {/testbench/du_b/rx_p/data(2) -radix hexadecimal} {/testbench/du_b/rx_p/data(3) -radix hexadecimal} {/testbench/du_b/rx_p/data(4) -radix hexadecimal} {/testbench/du_b/rx_p/data(5) -radix hexadecimal} {/testbench/du_b/rx_p/data(6) -radix hexadecimal} {/testbench/du_b/rx_p/data(7) -radix hexadecimal} {/testbench/du_b/rx_p/data(8) -radix hexadecimal} {/testbench/du_b/rx_p/data(9) -radix hexadecimal} {/testbench/du_b/rx_p/data(10) -radix hexadecimal} {/testbench/du_b/rx_p/data(11) -radix hexadecimal} {/testbench/du_b/rx_p/data(12) -radix hexadecimal} {/testbench/du_b/rx_p/data(13) -radix hexadecimal} {/testbench/du_b/rx_p/data(14) -radix hexadecimal} {/testbench/du_b/rx_p/data(15) -radix hexadecimal} {/testbench/du_b/rx_p/data(16) -radix hexadecimal} {/testbench/du_b/rx_p/data(17) -radix hexadecimal} {/testbench/du_b/rx_p/data(18) -radix hexadecimal} {/testbench/du_b/rx_p/data(19) -radix hexadecimal} {/testbench/du_b/rx_p/data(20) -radix hexadecimal} {/testbench/du_b/rx_p/data(21) -radix hexadecimal} {/testbench/du_b/rx_p/data(22) -radix hexadecimal} {/testbench/du_b/rx_p/data(23) -radix hexadecimal} {/testbench/du_b/rx_p/data(24) -radix hexadecimal} {/testbench/du_b/rx_p/data(25) -radix hexadecimal} {/testbench/du_b/rx_p/data(26) -radix hexadecimal} {/testbench/du_b/rx_p/data(27) -radix hexadecimal} {/testbench/du_b/rx_p/data(28) -radix hexadecimal} {/testbench/du_b/rx_p/data(29) -radix hexadecimal} {/testbench/du_b/rx_p/data(30) -radix hexadecimal} {/testbench/du_b/rx_p/data(31) -radix hexadecimal} {/testbench/du_b/rx_p/data(32) -radix hexadecimal} {/testbench/du_b/rx_p/data(33) -radix hexadecimal} {/testbench/du_b/rx_p/data(34) -radix hexadecimal} {/testbench/du_b/rx_p/data(35) -radix hexadecimal} {/testbench/du_b/rx_p/data(36) -radix hexadecimal} {/testbench/du_b/rx_p/data(37) -radix hexadecimal} {/testbench/du_b/rx_p/data(38) -radix hexadecimal} {/testbench/du_b/rx_p/data(39) -radix hexadecimal} {/testbench/du_b/rx_p/data(40) -radix hexadecimal} {/testbench/du_b/rx_p/data(41) -radix hexadecimal} {/testbench/du_b/rx_p/data(42) -radix hexadecimal} {/testbench/du_b/rx_p/data(43) -radix hexadecimal} {/testbench/du_b/rx_p/data(44) -radix hexadecimal} {/testbench/du_b/rx_p/data(45) -radix hexadecimal} {/testbench/du_b/rx_p/data(46) -radix hexadecimal} {/testbench/du_b/rx_p/data(47) -radix hexadecimal} {/testbench/du_b/rx_p/data(48) -radix hexadecimal} {/testbench/du_b/rx_p/data(49) -radix hexadecimal} {/testbench/du_b/rx_p/data(50) -radix hexadecimal} {/testbench/du_b/rx_p/data(51) -radix hexadecimal} {/testbench/du_b/rx_p/data(52) -radix hexadecimal} {/testbench/du_b/rx_p/data(53) -radix hexadecimal} {/testbench/du_b/rx_p/data(54) -radix hexadecimal} {/testbench/du_b/rx_p/data(55) -radix hexadecimal} {/testbench/du_b/rx_p/data(56) -radix hexadecimal} {/testbench/du_b/rx_p/data(57) -radix hexadecimal} {/testbench/du_b/rx_p/data(58) -radix hexadecimal} {/testbench/du_b/rx_p/data(59) -radix hexadecimal} {/testbench/du_b/rx_p/data(60) -radix hexadecimal} {/testbench/du_b/rx_p/data(61) -radix hexadecimal} {/testbench/du_b/rx_p/data(62) -radix hexadecimal} {/testbench/du_b/rx_p/data(63) -radix hexadecimal} {/testbench/du_b/rx_p/data(64) -radix hexadecimal} {/testbench/du_b/rx_p/data(65) -radix hexadecimal} {/testbench/du_b/rx_p/data(66) -radix hexadecimal} {/testbench/du_b/rx_p/data(67) -radix hexadecimal} {/testbench/du_b/rx_p/data(68) -radix hexadecimal} {/testbench/du_b/rx_p/data(69) -radix hexadecimal} {/testbench/du_b/rx_p/data(70) -radix hexadecimal} {/testbench/du_b/rx_p/data(71) -radix hexadecimal} {/testbench/du_b/rx_p/data(72) -radix hexadecimal} {/testbench/du_b/rx_p/data(73) -radix hexadecimal} {/testbench/du_b/rx_p/data(74) -radix hexadecimal} {/testbench/du_b/rx_p/data(75) -radix hexadecimal} {/testbench/du_b/rx_p/data(76) -radix hexadecimal} {/testbench/du_b/rx_p/data(77) -radix hexadecimal} {/testbench/du_b/rx_p/data(78) -radix hexadecimal} {/testbench/du_b/rx_p/data(79) -radix hexadecimal} {/testbench/du_b/rx_p/data(80) -radix hexadecimal} {/testbench/du_b/rx_p/data(81) -radix hexadecimal} {/testbench/du_b/rx_p/data(82) -radix hexadecimal} {/testbench/du_b/rx_p/data(83) -radix hexadecimal} {/testbench/du_b/rx_p/data(84) -radix hexadecimal} {/testbench/du_b/rx_p/data(85) -radix hexadecimal} {/testbench/du_b/rx_p/data(86) -radix hexadecimal} {/testbench/du_b/rx_p/data(87) -radix hexadecimal} {/testbench/du_b/rx_p/data(88) -radix hexadecimal} {/testbench/du_b/rx_p/data(89) -radix hexadecimal} {/testbench/du_b/rx_p/data(90) -radix hexadecimal} {/testbench/du_b/rx_p/data(91) -radix hexadecimal} {/testbench/du_b/rx_p/data(92) -radix hexadecimal} {/testbench/du_b/rx_p/data(93) -radix hexadecimal} {/testbench/du_b/rx_p/data(94) -radix hexadecimal} {/testbench/du_b/rx_p/data(95) -radix hexadecimal} {/testbench/du_b/rx_p/data(96) -radix hexadecimal} {/testbench/du_b/rx_p/data(97) -radix hexadecimal} {/testbench/du_b/rx_p/data(98) -radix hexadecimal} {/testbench/du_b/rx_p/data(99) -radix hexadecimal} {/testbench/du_b/rx_p/data(100) -radix hexadecimal} {/testbench/du_b/rx_p/data(101) -radix hexadecimal} {/testbench/du_b/rx_p/data(102) -radix hexadecimal} {/testbench/du_b/rx_p/data(103) -radix hexadecimal} {/testbench/du_b/rx_p/data(104) -radix hexadecimal} {/testbench/du_b/rx_p/data(105) -radix hexadecimal} {/testbench/du_b/rx_p/data(106) -radix hexadecimal} {/testbench/du_b/rx_p/data(107) -radix hexadecimal} {/testbench/du_b/rx_p/data(108) -radix hexadecimal} {/testbench/du_b/rx_p/data(109) -radix hexadecimal} {/testbench/du_b/rx_p/data(110) -radix hexadecimal} {/testbench/du_b/rx_p/data(111) -radix hexadecimal} {/testbench/du_b/rx_p/data(112) -radix hexadecimal} {/testbench/du_b/rx_p/data(113) -radix hexadecimal} {/testbench/du_b/rx_p/data(114) -radix hexadecimal} {/testbench/du_b/rx_p/data(115) -radix hexadecimal} {/testbench/du_b/rx_p/data(116) -radix hexadecimal} {/testbench/du_b/rx_p/data(117) -radix hexadecimal} {/testbench/du_b/rx_p/data(118) -radix hexadecimal} {/testbench/du_b/rx_p/data(119) -radix hexadecimal} {/testbench/du_b/rx_p/data(120) -radix hexadecimal} {/testbench/du_b/rx_p/data(121) -radix hexadecimal} {/testbench/du_b/rx_p/data(122) -radix hexadecimal} {/testbench/du_b/rx_p/data(123) -radix hexadecimal} {/testbench/du_b/rx_p/data(124) -radix hexadecimal} {/testbench/du_b/rx_p/data(125) -radix hexadecimal} {/testbench/du_b/rx_p/data(126) -radix hexadecimal} {/testbench/du_b/rx_p/data(127) -radix hexadecimal}} -subitemconfig {/testbench/du_b/rx_p/data(0) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(1) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(2) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(3) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(4) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(5) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(6) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(7) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(8) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(9) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(10) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(11) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(12) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(13) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(14) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(15) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(16) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(17) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(18) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(19) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(20) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(21) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(22) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(23) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(24) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(25) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(26) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(27) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(28) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(29) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(30) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(31) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(32) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(33) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(34) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(35) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(36) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(37) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(38) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(39) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(40) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(41) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(42) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(43) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(44) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(45) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(46) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(47) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(48) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(49) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(50) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(51) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(52) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(53) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(54) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(55) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(56) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(57) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(58) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(59) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(60) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(61) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(62) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(63) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(64) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(65) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(66) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(67) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(68) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(69) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(70) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(71) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(72) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(73) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(74) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(75) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(76) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(77) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(78) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(79) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(80) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(81) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(82) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(83) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(84) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(85) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(86) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(87) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(88) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(89) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(90) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(91) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(92) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(93) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(94) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(95) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(96) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(97) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(98) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(99) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(100) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(101) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(102) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(103) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(104) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(105) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(106) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(107) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(108) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(109) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(110) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(111) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(112) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(113) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(114) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(115) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(116) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(117) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(118) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(119) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(120) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(121) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(122) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(123) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(124) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(125) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(126) {-height 29 -radix hexadecimal} /testbench/du_b/rx_p/data(127) {-height 29 -radix hexadecimal}} /testbench/du_b/rx_p/data
add wave -noupdate -divider {New Divider}
add wave -noupdate -expand -group tbusbphy_rx /testbench/tb_b/tb_e/usbphy_e/rx_d/rxdv
add wave -noupdate -expand -group tbusbphy_rx /testbench/tb_b/tb_e/usbphy_e/rx_d/rxbs
add wave -noupdate -expand -group tbusbphy_rx /testbench/tb_b/tb_e/usbphy_e/rx_d/rxd
add wave -noupdate -expand -group tbusbphy_rx /testbench/tb_b/tb_e/usbphy_e/rx_d/line__49/state
add wave -noupdate -expand -group tbusbphy_rx /testbench/tb_b/tb_e/usbphy_e/rx_d/line__49/statekj
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/tb_b/tb_e/usbcrc_e/ncrc16
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {9787729 ps} 0} {{Cursor 2} {1329448 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 181
configure wave -valuecolwidth 451
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
WaveRestoreZoom {511586 ps} {10499391 ps}
