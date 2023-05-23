onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group uart -label uart_rxd /testbench/du_e/gpio(0)
add wave -noupdate -expand -group uart -label uart_txd /testbench/du_e/gpio(1)
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
add wave -noupdate -expand -group ddram -expand /testbench/du_e/ddram_dqs
add wave -noupdate -expand -group ddram -radix hexadecimal -childformat {{/testbench/du_e/ddram_dq(15) -radix hexadecimal} {/testbench/du_e/ddram_dq(14) -radix hexadecimal} {/testbench/du_e/ddram_dq(13) -radix hexadecimal} {/testbench/du_e/ddram_dq(12) -radix hexadecimal} {/testbench/du_e/ddram_dq(11) -radix hexadecimal} {/testbench/du_e/ddram_dq(10) -radix hexadecimal} {/testbench/du_e/ddram_dq(9) -radix hexadecimal} {/testbench/du_e/ddram_dq(8) -radix hexadecimal} {/testbench/du_e/ddram_dq(7) -radix hexadecimal} {/testbench/du_e/ddram_dq(6) -radix hexadecimal} {/testbench/du_e/ddram_dq(5) -radix hexadecimal} {/testbench/du_e/ddram_dq(4) -radix hexadecimal} {/testbench/du_e/ddram_dq(3) -radix hexadecimal} {/testbench/du_e/ddram_dq(2) -radix hexadecimal} {/testbench/du_e/ddram_dq(1) -radix hexadecimal} {/testbench/du_e/ddram_dq(0) -radix hexadecimal}} -subitemconfig {/testbench/du_e/ddram_dq(15) {-height 29 -radix hexadecimal} /testbench/du_e/ddram_dq(14) {-height 29 -radix hexadecimal} /testbench/du_e/ddram_dq(13) {-height 29 -radix hexadecimal} /testbench/du_e/ddram_dq(12) {-height 29 -radix hexadecimal} /testbench/du_e/ddram_dq(11) {-height 29 -radix hexadecimal} /testbench/du_e/ddram_dq(10) {-height 29 -radix hexadecimal} /testbench/du_e/ddram_dq(9) {-height 29 -radix hexadecimal} /testbench/du_e/ddram_dq(8) {-height 29 -radix hexadecimal} /testbench/du_e/ddram_dq(7) {-height 29 -radix hexadecimal} /testbench/du_e/ddram_dq(6) {-height 29 -radix hexadecimal} /testbench/du_e/ddram_dq(5) {-height 29 -radix hexadecimal} /testbench/du_e/ddram_dq(4) {-height 29 -radix hexadecimal} /testbench/du_e/ddram_dq(3) {-height 29 -radix hexadecimal} /testbench/du_e/ddram_dq(2) {-height 29 -radix hexadecimal} /testbench/du_e/ddram_dq(1) {-height 29 -radix hexadecimal} /testbench/du_e/ddram_dq(0) {-height 29 -radix hexadecimal}} /testbench/du_e/ddram_dq
add wave -noupdate -divider {New Divider}
add wave -noupdate -expand -group sdrphy_e /testbench/du_e/sdrphy_e/sclk
add wave -noupdate -expand -group sdrphy_e /testbench/du_e/sdrphy_e/eclk
add wave -noupdate -expand -group sdrphy_e /testbench/du_e/sdrphy_e/phy_locked
add wave -noupdate -expand -group sdrphy_e /testbench/du_e/sdrphy_e/sys_dmi
add wave -noupdate -expand -group sdrphy_e -expand /testbench/du_e/sdrphy_e/sys_dqt
add wave -noupdate -expand -group sdrphy_e -radix hexadecimal /testbench/du_e/sdrphy_e/sys_dqi
add wave -noupdate -expand -group sdrphy_e /testbench/du_e/sdrphy_e/sys_dqsi
add wave -noupdate -expand -group sdrphy_e /testbench/du_e/sdrphy_e/sys_dqst
add wave -noupdate -expand -group sdrphy_e -expand /testbench/du_e/sdrphy_e/sys_dqv
add wave -noupdate -expand -group sdrphy_e /testbench/du_e/sdrphy_e/sys_sti
add wave -noupdate -expand -group sdrphy_e -radix hexadecimal /testbench/du_e/sdrphy_e/sys_sto
add wave -noupdate -expand -group sdrphy_e -radix hexadecimal /testbench/du_e/sdrphy_e/sys_dqo
add wave -noupdate -expand -group sdrphy_e -expand -group byte_g0 /testbench/du_e/sdrphy_e/byte_g(0)/sdrphy_i/burstdet
add wave -noupdate -expand -group sdrphy_e -expand -group byte_g0 /testbench/du_e/sdrphy_e/byte_g(0)/sdrphy_i/datavalid
add wave -noupdate -expand -group sdrphy_e -expand -group byte_g0 -radix hexadecimal /testbench/du_e/sdrphy_e/byte_g(0)/sdrphy_i/dqi
add wave -noupdate -expand -group sdrphy_e -expand -group byte_g0 /testbench/du_e/sdrphy_e/byte_g(0)/sdrphy_i/sys_sti
add wave -noupdate -expand -group sdrphy_e -expand -group byte_g0 /testbench/du_e/sdrphy_e/byte_g(0)/sdrphy_i/sys_dqo
add wave -noupdate -expand -group sdrphy_e -expand -group byte_g0 -radix hexadecimal /testbench/du_e/sdrphy_e/byte_g(0)/sdrphy_i/sys_dqi
add wave -noupdate -expand -group sdrphy_e -expand -group byte_g0 /testbench/du_e/sdrphy_e/byte_g(0)/sdrphy_i/dqsw270
add wave -noupdate -expand -group sdrphy_e -expand -group byte_g0 /testbench/du_e/sdrphy_e/byte_g(0)/sdrphy_i/dqsw
add wave -noupdate -expand -group sdrphy_e -expand -group byte_g0 -radix hexadecimal /testbench/du_e/sdrphy_e/byte_g(0)/sdrphy_i/sdram_dq
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {43711692669 fs} 0} {{Cursor 2} {43699841982 fs} 0}
quietly wave cursor active 1
configure wave -namecolwidth 214
configure wave -valuecolwidth 99
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
WaveRestoreZoom {43696473568 fs} {43718929624 fs}
