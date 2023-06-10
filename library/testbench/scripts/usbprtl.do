onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/txc
add wave -noupdate /testbench/txen
add wave -noupdate /testbench/txd
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/dp
add wave -noupdate /testbench/dn
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix hexadecimal /testbench/data
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/usbprtl_d/usbcrc_e/crc5
add wave -noupdate -radix hexadecimal /testbench/usbprtl_d/usbcrc_e/crc16
add wave -noupdate /testbench/usbprtl_d/clk
add wave -noupdate /testbench/usbprtl_d/cken
add wave -noupdate /testbench/usbprtl_d/dv
add wave -noupdate /testbench/usbprtl_d/txd
add wave -noupdate /testbench/usbprtl_d/txen
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/usbprtl_d/usbcrc_e/clk
add wave -noupdate /testbench/usbprtl_d/usbcrc_e/cken
add wave -noupdate /testbench/txen
add wave -noupdate /testbench/txd
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/usbprtl_d/phy_txen
add wave -noupdate /testbench/usbprtl_d/phy_txd
add wave -noupdate /testbench/usbprtl_d/phy_txbs
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/usbprtl_d/usbphy_e/tx_d/line__25/cnt1
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/usbprtl_d/usbphy_e/tx_d/line__25/cnt1
add wave -noupdate /testbench/usbprtl_d/line__96/cntr
add wave -noupdate /testbench/usbprtl_d/line__96/cntr
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix hexadecimal /testbench/line__129/rx_data
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/usbprtl_d/usbcrc_e/dv
add wave -noupdate /testbench/usbprtl_d/usbcrc_e/data
add wave -noupdate -radix hexadecimal /testbench/usbprtl_d/usbcrc_e/ncrc5
add wave -noupdate -radix hexadecimal /testbench/usbprtl_d/usbcrc_e/ncrc16
add wave -noupdate /testbench/usbprtl_d/crcen
add wave -noupdate /testbench/usbprtl_d/crcdv
add wave -noupdate /testbench/tp(1)
add wave -noupdate /testbench/tp(2)
add wave -noupdate /testbench/tp(3)
add wave -noupdate /testbench/usbprtl_d/line__96/cntr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {7458393 ps} 1} {{Cursor 5} {17547202 ps} 0}
quietly wave cursor active 2
configure wave -namecolwidth 150
configure wave -valuecolwidth 336
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
WaveRestoreZoom {0 ps} {29400 ns}
