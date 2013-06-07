onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/mii_req
add wave -noupdate /testbench/mii_txc
add wave -noupdate -radix hexadecimal /testbench/mii_txd
add wave -noupdate /testbench/mii_txen
add wave -noupdate -expand /testbench/miitx_udp_e/txrdy
add wave -noupdate /testbench/miitx_udp_e/miitx_pre_e_mii_txen/O
add wave -noupdate /testbench/miitx_udp_e/miitx_pre_e_mii_txen/CLK
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/miitx_udp_e/miitx_pre_e_mii_txen_CLKINV_1203
add wave -noupdate /testbench/miitx_udp_e/miitx_pre_e_mii_txen_SRINV_1204
add wave -noupdate /testbench/miitx_udp_e/miitx_pre_e_mii_txen_DYMUX_1214
add wave -noupdate /testbench/miitx_udp_e/miitx_pre_e_mii_txen_465
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix hexadecimal -childformat {{/testbench/miitx_udp_e/miitx_pre_e_cntr(4) -radix hexadecimal} {/testbench/miitx_udp_e/miitx_pre_e_cntr(3) -radix hexadecimal} {/testbench/miitx_udp_e/miitx_pre_e_cntr(2) -radix hexadecimal} {/testbench/miitx_udp_e/miitx_pre_e_cntr(1) -radix hexadecimal} {/testbench/miitx_udp_e/miitx_pre_e_cntr(0) -radix hexadecimal}} -subitemconfig {/testbench/miitx_udp_e/miitx_pre_e_cntr(4) {-height 16 -radix hexadecimal} /testbench/miitx_udp_e/miitx_pre_e_cntr(3) {-height 16 -radix hexadecimal} /testbench/miitx_udp_e/miitx_pre_e_cntr(2) {-height 16 -radix hexadecimal} /testbench/miitx_udp_e/miitx_pre_e_cntr(1) {-height 16 -radix hexadecimal} /testbench/miitx_udp_e/miitx_pre_e_cntr(0) {-height 16 -radix hexadecimal}} /testbench/miitx_udp_e/miitx_pre_e_cntr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1114859 ps} 0} {{Cursor 2} {278554 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 281
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
WaveRestoreZoom {983607 ps} {1246111 ps}
