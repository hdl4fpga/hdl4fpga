onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/mii_req
add wave -noupdate /testbench/du_e/mii_rxc
add wave -noupdate /testbench/du_e/mii_rxdv
add wave -noupdate -radix hexadecimal /testbench/du_e/mii_rxd
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/mii_txc
add wave -noupdate /testbench/du_e/mii_txen
add wave -noupdate -radix hexadecimal /testbench/du_e/mii_txd
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/ddr_ckp
add wave -noupdate /testbench/du_e/ddr_ras
add wave -noupdate /testbench/du_e/ddr_cas
add wave -noupdate /testbench/du_e/ddr_we
add wave -noupdate /testbench/du_e/ddr_ba
add wave -noupdate -radix hexadecimal /testbench/du_e/ddr_a
add wave -noupdate -expand /testbench/du_e/ddr_dqs
add wave -noupdate -radix hexadecimal -childformat {{/testbench/du_e/ddr_dq(15) -radix hexadecimal} {/testbench/du_e/ddr_dq(14) -radix hexadecimal} {/testbench/du_e/ddr_dq(13) -radix hexadecimal} {/testbench/du_e/ddr_dq(12) -radix hexadecimal} {/testbench/du_e/ddr_dq(11) -radix hexadecimal} {/testbench/du_e/ddr_dq(10) -radix hexadecimal} {/testbench/du_e/ddr_dq(9) -radix hexadecimal} {/testbench/du_e/ddr_dq(8) -radix hexadecimal} {/testbench/du_e/ddr_dq(7) -radix hexadecimal} {/testbench/du_e/ddr_dq(6) -radix hexadecimal} {/testbench/du_e/ddr_dq(5) -radix hexadecimal} {/testbench/du_e/ddr_dq(4) -radix hexadecimal} {/testbench/du_e/ddr_dq(3) -radix hexadecimal} {/testbench/du_e/ddr_dq(2) -radix hexadecimal} {/testbench/du_e/ddr_dq(1) -radix hexadecimal} {/testbench/du_e/ddr_dq(0) -radix hexadecimal}} -subitemconfig {/testbench/du_e/ddr_dq(15) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_dq(14) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_dq(13) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_dq(12) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_dq(11) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_dq(10) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_dq(9) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_dq(8) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_dq(7) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_dq(6) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_dq(5) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_dq(4) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_dq(3) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_dq(2) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_dq(1) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_dq(0) {-height 29 -radix hexadecimal}} /testbench/du_e/ddr_dq
add wave -noupdate /testbench/du_e/ddr_st_dqs
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {217684728 ps} 0}
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
WaveRestoreZoom {217458424 ps} {217911032 ps}
