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
add wave -noupdate -group tb_usbphy_rx /testbench/tb_b/tb_e/usbphy_e/rx_d/rxdv
add wave -noupdate -group tb_usbphy_rx /testbench/tb_b/tb_e/usbphy_e/rx_d/rxbs
add wave -noupdate -group tb_usbphy_rx /testbench/tb_b/tb_e/usbphy_e/rx_d/rxd
add wave -noupdate -group tb_usbphy_rx /testbench/tb_b/tb_e/usbphy_e/rx_d/line__49/state
add wave -noupdate -group tb_usbphy_rx /testbench/tb_b/tb_e/usbphy_e/rx_d/line__49/statekj
add wave -noupdate -divider {New Divider}
add wave -noupdate -expand -group tb_usbphy_tx /testbench/tb_b/tb_e/usbphy_e/tx_d/clk
add wave -noupdate -expand -group tb_usbphy_tx /testbench/tb_b/tb_e/usbphy_e/tx_d/cken
add wave -noupdate -expand -group tb_usbphy_tx /testbench/tb_b/tb_e/usbphy_e/tx_d/txen
add wave -noupdate -expand -group tb_usbphy_tx /testbench/tb_b/tb_e/usbphy_e/tx_d/txd
add wave -noupdate -expand -group tb_usbphy_tx /testbench/tb_b/tb_e/usbphy_e/tx_d/txbs
add wave -noupdate -expand -group tb_usbphy_tx /testbench/tb_b/tb_e/usbphy_e/tx_d/txdp
add wave -noupdate -expand -group tb_usbphy_tx /testbench/tb_b/tb_e/usbphy_e/tx_d/txdn
add wave -noupdate -radix hexadecimal /testbench/tb_b/line__57/data
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/tb_b/tb_e/usbcrc_e/cken
add wave -noupdate /testbench/tb_b/tb_e/usbcrc_e/dv
add wave -noupdate /testbench/tb_b/tb_e/usbcrc_e/data
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/tb_b/tb_e/usbcrc_e/crc5
add wave -noupdate /testbench/tb_b/tb_e/usbcrc_e/ncrc5
add wave -noupdate -radix hexadecimal /testbench/tb_b/tb_e/usbcrc_e/ncrc16
add wave -noupdate -radix hexadecimal /testbench/tb_b/tb_e/usbcrc_e/crc16
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {7180380 ps} 0} {{Cursor 2} {2791689 ps} 0}
quietly wave cursor active 2
configure wave -namecolwidth 397
configure wave -valuecolwidth 171
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
WaveRestoreZoom {0 ps} {5250 ns}
