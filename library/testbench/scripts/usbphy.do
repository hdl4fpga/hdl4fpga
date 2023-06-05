onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /testbench/data
add wave -noupdate /testbench/txc
add wave -noupdate /testbench/txen
add wave -noupdate /testbench/txd
add wave -noupdate /testbench/tx_d/busy
add wave -noupdate /testbench/tx_d/tx_stuffedbit
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/dp
add wave -noupdate /testbench/dn
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/rx_d/rxc
add wave -noupdate /testbench/rx_d/k
add wave -noupdate /testbench/rx_d/ena
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/rx_d/frm
add wave -noupdate /testbench/rx_d/dv
add wave -noupdate /testbench/rx_d/data
add wave -noupdate /testbench/rx_d/rx_stuffedbit
add wave -noupdate -radix hexadecimal -childformat {{/testbench/datao(0) -radix hexadecimal} {/testbench/datao(1) -radix hexadecimal} {/testbench/datao(2) -radix hexadecimal} {/testbench/datao(3) -radix hexadecimal} {/testbench/datao(4) -radix hexadecimal} {/testbench/datao(5) -radix hexadecimal} {/testbench/datao(6) -radix hexadecimal} {/testbench/datao(7) -radix hexadecimal} {/testbench/datao(8) -radix hexadecimal} {/testbench/datao(9) -radix hexadecimal} {/testbench/datao(10) -radix hexadecimal} {/testbench/datao(11) -radix hexadecimal} {/testbench/datao(12) -radix hexadecimal} {/testbench/datao(13) -radix hexadecimal} {/testbench/datao(14) -radix hexadecimal} {/testbench/datao(15) -radix hexadecimal} {/testbench/datao(16) -radix hexadecimal} {/testbench/datao(17) -radix hexadecimal} {/testbench/datao(18) -radix hexadecimal} {/testbench/datao(19) -radix hexadecimal} {/testbench/datao(20) -radix hexadecimal} {/testbench/datao(21) -radix hexadecimal} {/testbench/datao(22) -radix hexadecimal} {/testbench/datao(23) -radix hexadecimal} {/testbench/datao(24) -radix hexadecimal} {/testbench/datao(25) -radix hexadecimal} {/testbench/datao(26) -radix hexadecimal} {/testbench/datao(27) -radix hexadecimal} {/testbench/datao(28) -radix hexadecimal} {/testbench/datao(29) -radix hexadecimal} {/testbench/datao(30) -radix hexadecimal} {/testbench/datao(31) -radix hexadecimal} {/testbench/datao(32) -radix hexadecimal} {/testbench/datao(33) -radix hexadecimal} {/testbench/datao(34) -radix hexadecimal} {/testbench/datao(35) -radix hexadecimal} {/testbench/datao(36) -radix hexadecimal} {/testbench/datao(37) -radix hexadecimal} {/testbench/datao(38) -radix hexadecimal} {/testbench/datao(39) -radix hexadecimal} {/testbench/datao(40) -radix hexadecimal} {/testbench/datao(41) -radix hexadecimal} {/testbench/datao(42) -radix hexadecimal} {/testbench/datao(43) -radix hexadecimal} {/testbench/datao(44) -radix hexadecimal} {/testbench/datao(45) -radix hexadecimal} {/testbench/datao(46) -radix hexadecimal} {/testbench/datao(47) -radix hexadecimal} {/testbench/datao(48) -radix hexadecimal} {/testbench/datao(49) -radix hexadecimal} {/testbench/datao(50) -radix hexadecimal} {/testbench/datao(51) -radix hexadecimal} {/testbench/datao(52) -radix hexadecimal} {/testbench/datao(53) -radix hexadecimal} {/testbench/datao(54) -radix hexadecimal} {/testbench/datao(55) -radix hexadecimal} {/testbench/datao(56) -radix hexadecimal} {/testbench/datao(57) -radix hexadecimal} {/testbench/datao(58) -radix hexadecimal} {/testbench/datao(59) -radix hexadecimal} {/testbench/datao(60) -radix hexadecimal} {/testbench/datao(61) -radix hexadecimal} {/testbench/datao(62) -radix hexadecimal} {/testbench/datao(63) -radix hexadecimal}} -subitemconfig {/testbench/datao(0) {-height 29 -radix hexadecimal} /testbench/datao(1) {-height 29 -radix hexadecimal} /testbench/datao(2) {-height 29 -radix hexadecimal} /testbench/datao(3) {-height 29 -radix hexadecimal} /testbench/datao(4) {-height 29 -radix hexadecimal} /testbench/datao(5) {-height 29 -radix hexadecimal} /testbench/datao(6) {-height 29 -radix hexadecimal} /testbench/datao(7) {-height 29 -radix hexadecimal} /testbench/datao(8) {-height 29 -radix hexadecimal} /testbench/datao(9) {-height 29 -radix hexadecimal} /testbench/datao(10) {-height 29 -radix hexadecimal} /testbench/datao(11) {-height 29 -radix hexadecimal} /testbench/datao(12) {-height 29 -radix hexadecimal} /testbench/datao(13) {-height 29 -radix hexadecimal} /testbench/datao(14) {-height 29 -radix hexadecimal} /testbench/datao(15) {-height 29 -radix hexadecimal} /testbench/datao(16) {-height 29 -radix hexadecimal} /testbench/datao(17) {-height 29 -radix hexadecimal} /testbench/datao(18) {-height 29 -radix hexadecimal} /testbench/datao(19) {-height 29 -radix hexadecimal} /testbench/datao(20) {-height 29 -radix hexadecimal} /testbench/datao(21) {-height 29 -radix hexadecimal} /testbench/datao(22) {-height 29 -radix hexadecimal} /testbench/datao(23) {-height 29 -radix hexadecimal} /testbench/datao(24) {-height 29 -radix hexadecimal} /testbench/datao(25) {-height 29 -radix hexadecimal} /testbench/datao(26) {-height 29 -radix hexadecimal} /testbench/datao(27) {-height 29 -radix hexadecimal} /testbench/datao(28) {-height 29 -radix hexadecimal} /testbench/datao(29) {-height 29 -radix hexadecimal} /testbench/datao(30) {-height 29 -radix hexadecimal} /testbench/datao(31) {-height 29 -radix hexadecimal} /testbench/datao(32) {-height 29 -radix hexadecimal} /testbench/datao(33) {-height 29 -radix hexadecimal} /testbench/datao(34) {-height 29 -radix hexadecimal} /testbench/datao(35) {-height 29 -radix hexadecimal} /testbench/datao(36) {-height 29 -radix hexadecimal} /testbench/datao(37) {-height 29 -radix hexadecimal} /testbench/datao(38) {-height 29 -radix hexadecimal} /testbench/datao(39) {-height 29 -radix hexadecimal} /testbench/datao(40) {-height 29 -radix hexadecimal} /testbench/datao(41) {-height 29 -radix hexadecimal} /testbench/datao(42) {-height 29 -radix hexadecimal} /testbench/datao(43) {-height 29 -radix hexadecimal} /testbench/datao(44) {-height 29 -radix hexadecimal} /testbench/datao(45) {-height 29 -radix hexadecimal} /testbench/datao(46) {-height 29 -radix hexadecimal} /testbench/datao(47) {-height 29 -radix hexadecimal} /testbench/datao(48) {-height 29 -radix hexadecimal} /testbench/datao(49) {-height 29 -radix hexadecimal} /testbench/datao(50) {-height 29 -radix hexadecimal} /testbench/datao(51) {-height 29 -radix hexadecimal} /testbench/datao(52) {-height 29 -radix hexadecimal} /testbench/datao(53) {-height 29 -radix hexadecimal} /testbench/datao(54) {-height 29 -radix hexadecimal} /testbench/datao(55) {-height 29 -radix hexadecimal} /testbench/datao(56) {-height 29 -radix hexadecimal} /testbench/datao(57) {-height 29 -radix hexadecimal} /testbench/datao(58) {-height 29 -radix hexadecimal} /testbench/datao(59) {-height 29 -radix hexadecimal} /testbench/datao(60) {-height 29 -radix hexadecimal} /testbench/datao(61) {-height 29 -radix hexadecimal} /testbench/datao(62) {-height 29 -radix hexadecimal} /testbench/datao(63) {-height 29 -radix hexadecimal}} /testbench/datao
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {477602 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 279
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
WaveRestoreZoom {0 ps} {31500 ns}
