onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/txc
add wave -noupdate /testbench/txen
add wave -noupdate /testbench/txd
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/dp
add wave -noupdate /testbench/dn
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du/usbcrc_e/crc5
add wave -noupdate -radix hexadecimal /testbench/du/usbcrc_e/crc16
add wave -noupdate /testbench/du/clk
add wave -noupdate /testbench/du/cken
add wave -noupdate /testbench/du/dv
add wave -noupdate /testbench/du/txd
add wave -noupdate /testbench/du/txen
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du/usbcrc_e/clk
add wave -noupdate /testbench/du/usbcrc_e/cken
add wave -noupdate /testbench/txen
add wave -noupdate /testbench/txd
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du/phy_txen
add wave -noupdate /testbench/du/phy_txd
add wave -noupdate /testbench/du/phy_txbs
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du/usbphy_e/tx_d/line__25/cnt1
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du/usbphy_e/tx_d/line__25/cnt1
add wave -noupdate /testbench/du/line__96/cntr
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix hexadecimal /testbench/line__122/data
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du/usbcrc_e/crc16(0)
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du/usbcrc_e/dv
add wave -noupdate /testbench/du/usbcrc_e/data
add wave -noupdate -radix hexadecimal /testbench/du/usbcrc_e/ncrc5
add wave -noupdate -radix hexadecimal /testbench/du/usbcrc_e/ncrc16
add wave -noupdate /testbench/du/crcen
add wave -noupdate /testbench/du/crcdv
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/tp(1)
add wave -noupdate /testbench/tp(2)
add wave -noupdate /testbench/tp(3)
add wave -noupdate /testbench/line__122/cntr
add wave -noupdate /testbench/du/line__96/cntr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {9009053 ps} 0} {{Cursor 5} {17468367 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 382
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
WaveRestoreZoom {7226821 ps} {10145957 ps}
