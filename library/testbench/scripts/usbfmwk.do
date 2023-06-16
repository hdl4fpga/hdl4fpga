onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/usb_clk
add wave -noupdate /testbench/dp
add wave -noupdate /testbench/dn
add wave -noupdate -divider host_usbphy
add wave -noupdate -expand -group host_rx_p /testbench/host_b/rx_p/cntr
add wave -noupdate -expand -group host_rx_p -radix hexadecimal /testbench/host_b/rx_p/msb
add wave -noupdate -expand -group host_usbprtcl /testbench/host_b/host_e/cken
add wave -noupdate -expand -group host_usbprtcl /testbench/host_b/host_e/txen
add wave -noupdate -expand -group host_usbprtcl /testbench/host_b/host_e/idle
add wave -noupdate -expand -group host_usbprtcl /testbench/host_b/host_e/txbs
add wave -noupdate -expand -group host_usbprtcl /testbench/host_b/host_e/pktfmt_p/state
add wave -noupdate -expand -group host_usbprtcl /testbench/host_b/host_e/txd
add wave -noupdate -expand -group host_usbprtcl /testbench/host_b/host_e/rxdv
add wave -noupdate -expand -group host_usbprtcl /testbench/host_b/host_e/rxd
add wave -noupdate -expand -group host_usbprtcl /testbench/host_b/host_e/rxbs
add wave -noupdate -expand -group host_usbprtcl -expand -group host_usbphy_tx /testbench/host_b/host_e/usbphy_e/tx_d/clk
add wave -noupdate -expand -group host_usbprtcl -expand -group host_usbphy_tx /testbench/host_b/host_e/usbphy_e/tx_d/cken
add wave -noupdate -expand -group host_usbprtcl -expand -group host_usbphy_tx /testbench/host_b/host_e/usbphy_e/tx_d/txen
add wave -noupdate -expand -group host_usbprtcl -expand -group host_usbphy_tx /testbench/host_b/host_e/usbphy_e/tx_d/txd
add wave -noupdate -expand -group host_usbprtcl -expand -group host_usbphy_tx /testbench/host_b/host_e/usbphy_e/tx_d/txbs
add wave -noupdate -expand -group host_usbprtcl -expand -group host_usbphy_tx /testbench/host_b/host_e/usbphy_e/tx_d/bit_stuffing
add wave -noupdate -expand -group host_usbprtcl -group host_usbphy_rx /testbench/host_b/host_e/usbphy_e/rx_d/rxdv
add wave -noupdate -expand -group host_usbprtcl -group host_usbphy_rx /testbench/host_b/host_e/usbphy_e/rx_d/rxbs
add wave -noupdate -expand -group host_usbprtcl -group host_usbphy_rx /testbench/host_b/host_e/usbphy_e/rx_d/rxd
add wave -noupdate -expand -group host_usbprtcl -group host_usbphy_rx /testbench/host_b/host_e/usbphy_e/rx_d/line__49/state
add wave -noupdate -expand -group host_usbprtcl -group host_usbphy_rx /testbench/host_b/host_e/usbphy_e/rx_d/line__49/statekj
add wave -noupdate -expand -group host_usbprtcl -expand -group host_usbcrcglue /testbench/host_b/host_e/crcglue_e/clk
add wave -noupdate -expand -group host_usbprtcl -expand -group host_usbcrcglue /testbench/host_b/host_e/crcglue_e/mealy_p/state
add wave -noupdate -expand -group host_usbprtcl -expand -group host_usbcrcglue /testbench/host_b/host_e/crcglue_e/cken
add wave -noupdate -expand -group host_usbprtcl -expand -group host_usbcrcglue /testbench/host_b/host_e/crcglue_e/bitstff
add wave -noupdate -expand -group host_usbprtcl -expand -group host_usbcrcglue /testbench/host_b/host_e/crcglue_e/crcdv
add wave -noupdate -expand -group host_usbprtcl -expand -group host_usbcrcglue /testbench/host_b/host_e/crcglue_e/crcact
add wave -noupdate -expand -group host_usbprtcl -expand -group host_usbcrcglue /testbench/host_b/host_e/crcglue_e/crcen
add wave -noupdate -expand -group host_usbprtcl -expand -group host_usbcrcglue /testbench/host_b/host_e/crcglue_e/crcd
add wave -noupdate -expand -group host_usbprtcl -expand -group host_usbcrcglue /testbench/host_b/host_e/crcglue_e/txen
add wave -noupdate -expand -group host_usbprtcl -expand -group host_usbcrcglue /testbench/host_b/host_e/crcglue_e/txbs
add wave -noupdate -expand -group host_usbprtcl -expand -group host_usbcrcglue /testbench/host_b/host_e/crcglue_e/txd
add wave -noupdate -expand -group host_usbprtcl -expand -group host_usbcrcglue /testbench/host_b/host_e/crcglue_e/phy_txen
add wave -noupdate -expand -group host_usbprtcl -expand -group host_usbcrcglue /testbench/host_b/host_e/crcglue_e/phy_txbs
add wave -noupdate -expand -group host_usbprtcl -expand -group host_usbcrcglue /testbench/host_b/host_e/crcglue_e/phy_txd
add wave -noupdate -expand -group host_usbprtcl -expand -group host_usbcrcglue /testbench/host_b/host_e/crcglue_e/rxdv
add wave -noupdate -expand -group host_usbprtcl -expand -group host_usbcrcglue /testbench/host_b/host_e/crcglue_e/rxbs
add wave -noupdate -expand -group host_usbprtcl -expand -group host_usbcrcglue /testbench/host_b/host_e/crcglue_e/rxd
add wave -noupdate -expand -group host_usbprtcl -expand -group host_usbcrcglue /testbench/host_b/host_e/crcglue_e/phy_rxdv
add wave -noupdate -expand -group host_usbprtcl -expand -group host_usbcrcglue /testbench/host_b/host_e/crcglue_e/phy_rxbs
add wave -noupdate -expand -group host_usbprtcl -expand -group host_usbcrcglue /testbench/host_b/host_e/crcglue_e/phy_rxd
add wave -noupdate -expand -group host_usbprtcl -expand -group host_usbcrc /testbench/host_b/host_e/usbcrc_e/clk
add wave -noupdate -expand -group host_usbprtcl -expand -group host_usbcrc /testbench/host_b/host_e/usbcrc_e/cken
add wave -noupdate -expand -group host_usbprtcl -expand -group host_usbcrc /testbench/host_b/host_e/usbcrc_e/dv
add wave -noupdate -expand -group host_usbprtcl -expand -group host_usbcrc /testbench/host_b/host_e/usbcrc_e/data
add wave -noupdate -expand -group host_usbprtcl -expand -group host_usbcrc /testbench/host_b/host_e/usbcrc_e/crc5
add wave -noupdate -expand -group host_usbprtcl -expand -group host_usbcrc /testbench/host_b/host_e/usbcrc_e/ncrc5
add wave -noupdate -expand -group host_usbprtcl -expand -group host_usbcrc -radix binary /testbench/host_b/host_e/usbcrc_e/crc16
add wave -noupdate -expand -group host_usbprtcl -expand -group host_usbcrc -radix hexadecimal /testbench/host_b/host_e/usbcrc_e/ncrc16
add wave -noupdate -divider dvc_usbphy
add wave -noupdate -expand -group dev_usbprtcl /testbench/dev_b/dev_e/cken
add wave -noupdate -expand -group dev_usbprtcl /testbench/dev_b/dev_e/txen
add wave -noupdate -expand -group dev_usbprtcl /testbench/dev_b/dev_e/txbs
add wave -noupdate -expand -group dev_usbprtcl /testbench/dev_b/dev_e/txd
add wave -noupdate -expand -group dev_usbprtcl /testbench/dev_b/dev_e/rxdv
add wave -noupdate -expand -group dev_usbprtcl /testbench/dev_b/dev_e/rxbs
add wave -noupdate -expand -group dev_usbprtcl /testbench/dev_b/dev_e/rxd
add wave -noupdate -expand -group dev_usbprtcl /testbench/dev_b/dev_e/usbprtl_e/usbphy_e/k
add wave -noupdate -expand -group dev_usbprtcl /testbench/dev_b/dev_e/usbprtl_e/usbphy_e/j
add wave -noupdate -expand -group dev_usbprtcl /testbench/dev_b/dev_e/usbprtl_e/usbphy_e/se0
add wave -noupdate -expand -group dev_usbprtcl -group dev_usbphy_tx /testbench/dev_b/dev_e/usbprtl_e/usbphy_e/tx_d/cken
add wave -noupdate -expand -group dev_usbprtcl -group dev_usbphy_tx /testbench/dev_b/dev_e/usbprtl_e/usbphy_e/tx_d/txen
add wave -noupdate -expand -group dev_usbprtcl -group dev_usbphy_tx /testbench/dev_b/dev_e/usbprtl_e/usbphy_e/tx_d/txd
add wave -noupdate -expand -group dev_usbprtcl -group dev_usbphy_tx /testbench/dev_b/dev_e/usbprtl_e/usbphy_e/tx_d/txbs
add wave -noupdate -expand -group dev_usbprtcl -group dev_usbphy_tx /testbench/dev_b/dev_e/usbprtl_e/usbphy_e/tx_d/txdp
add wave -noupdate -expand -group dev_usbprtcl -group dev_usbphy_tx /testbench/dev_b/dev_e/usbprtl_e/usbphy_e/tx_d/txdn
add wave -noupdate -expand -group dev_usbprtcl -expand -group dev_usbphy_rx /testbench/dev_b/dev_e/usbprtl_e/usbphy_e/rx_d/clk
add wave -noupdate -expand -group dev_usbprtcl -expand -group dev_usbphy_rx /testbench/dev_b/dev_e/usbprtl_e/usbphy_e/rx_d/cken
add wave -noupdate -expand -group dev_usbprtcl -expand -group dev_usbphy_rx /testbench/dev_b/dev_e/usbprtl_e/usbphy_e/rx_d/j
add wave -noupdate -expand -group dev_usbprtcl -expand -group dev_usbphy_rx /testbench/dev_b/dev_e/usbprtl_e/usbphy_e/rx_d/k
add wave -noupdate -expand -group dev_usbprtcl -expand -group dev_usbphy_rx /testbench/dev_b/dev_e/usbprtl_e/usbphy_e/rx_d/se0
add wave -noupdate -expand -group dev_usbprtcl -expand -group dev_usbphy_rx /testbench/dev_b/dev_e/usbprtl_e/usbphy_e/rx_d/rxdv
add wave -noupdate -expand -group dev_usbprtcl -expand -group dev_usbphy_rx /testbench/dev_b/dev_e/usbprtl_e/usbphy_e/rx_d/rxbs
add wave -noupdate -expand -group dev_usbprtcl -expand -group dev_usbphy_rx /testbench/dev_b/dev_e/usbprtl_e/usbphy_e/rx_d/rxd
add wave -noupdate -expand -group dev_usbprtcl -expand -group dev_usbphy_rx /testbench/dev_b/dev_e/usbprtl_e/usbphy_e/rx_d/line__49/state
add wave -noupdate -expand -group dev_usbprtcl -expand -group dev_usbphy_rx /testbench/dev_b/dev_e/usbprtl_e/usbphy_e/rx_d/line__49/statekj
add wave -noupdate -expand -group dev_usbprtcl -expand -group dev_usbphy_rx /testbench/dev_b/dev_e/usbprtl_e/usbphy_e/rx_d/line__49/cnt1
add wave -noupdate -expand -group dev_usbprtcl -expand -group dev_usbphy_rx /testbench/dev_b/dev_e/usbprtl_e/usbphy_e/rx_d/err
add wave -noupdate -expand -group dev_usbprtcl -group dev_usbcrcglue /testbench/dev_b/dev_e/usbprtl_e/crcglue_e/clk
add wave -noupdate -expand -group dev_usbprtcl -group dev_usbcrcglue /testbench/dev_b/dev_e/usbprtl_e/crcglue_e/cken
add wave -noupdate -expand -group dev_usbprtcl -group dev_usbcrcglue /testbench/dev_b/dev_e/usbprtl_e/crcglue_e/bitstff
add wave -noupdate -expand -group dev_usbprtcl -group dev_usbcrcglue /testbench/dev_b/dev_e/usbprtl_e/crcglue_e/crcdv
add wave -noupdate -expand -group dev_usbprtcl -group dev_usbcrcglue /testbench/dev_b/dev_e/usbprtl_e/crcglue_e/crcact
add wave -noupdate -expand -group dev_usbprtcl -group dev_usbcrcglue /testbench/dev_b/dev_e/usbprtl_e/crcglue_e/crcen
add wave -noupdate -expand -group dev_usbprtcl -group dev_usbcrcglue /testbench/dev_b/dev_e/usbprtl_e/crcglue_e/crcd
add wave -noupdate -expand -group dev_usbprtcl -group dev_usbcrcglue /testbench/dev_b/dev_e/usbprtl_e/crcglue_e/txen
add wave -noupdate -expand -group dev_usbprtcl -group dev_usbcrcglue /testbench/dev_b/dev_e/usbprtl_e/crcglue_e/txbs
add wave -noupdate -expand -group dev_usbprtcl -group dev_usbcrcglue /testbench/dev_b/dev_e/usbprtl_e/crcglue_e/txd
add wave -noupdate -expand -group dev_usbprtcl -group dev_usbcrcglue /testbench/dev_b/dev_e/usbprtl_e/crcglue_e/phy_txen
add wave -noupdate -expand -group dev_usbprtcl -group dev_usbcrcglue /testbench/dev_b/dev_e/usbprtl_e/crcglue_e/phy_txbs
add wave -noupdate -expand -group dev_usbprtcl -group dev_usbcrcglue /testbench/dev_b/dev_e/usbprtl_e/crcglue_e/phy_txd
add wave -noupdate -expand -group dev_usbprtcl -group dev_usbcrcglue /testbench/dev_b/dev_e/usbprtl_e/crcglue_e/rxdv
add wave -noupdate -expand -group dev_usbprtcl -group dev_usbcrcglue /testbench/dev_b/dev_e/usbprtl_e/crcglue_e/rxbs
add wave -noupdate -expand -group dev_usbprtcl -group dev_usbcrcglue /testbench/dev_b/dev_e/usbprtl_e/crcglue_e/rxd
add wave -noupdate -expand -group dev_usbprtcl -group dev_usbcrcglue /testbench/dev_b/dev_e/usbprtl_e/crcglue_e/phy_rxdv
add wave -noupdate -expand -group dev_usbprtcl -group dev_usbcrcglue /testbench/dev_b/dev_e/usbprtl_e/crcglue_e/phy_rxbs
add wave -noupdate -expand -group dev_usbprtcl -group dev_usbcrcglue /testbench/dev_b/dev_e/usbprtl_e/crcglue_e/phy_rxd
add wave -noupdate -expand -group dev_usbprtcl -expand -group dev_usbrcr /testbench/dev_b/dev_e/usbprtl_e/usbcrc_e/clk
add wave -noupdate -expand -group dev_usbprtcl -expand -group dev_usbrcr /testbench/dev_b/dev_e/usbprtl_e/crcglue_e/mealy_p/state
add wave -noupdate -expand -group dev_usbprtcl -expand -group dev_usbrcr /testbench/dev_b/dev_e/usbprtl_e/usbcrc_e/cken
add wave -noupdate -expand -group dev_usbprtcl -expand -group dev_usbrcr /testbench/dev_b/dev_e/usbprtl_e/usbcrc_e/dv
add wave -noupdate -expand -group dev_usbprtcl -expand -group dev_usbrcr /testbench/dev_b/dev_e/usbprtl_e/usbcrc_e/data
add wave -noupdate -expand -group dev_usbprtcl -expand -group dev_usbrcr /testbench/dev_b/dev_e/usbprtl_e/usbcrc_e/crc5
add wave -noupdate -expand -group dev_usbprtcl -expand -group dev_usbrcr /testbench/dev_b/dev_e/usbprtl_e/usbcrc_e/crc16
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/dev_b/dev_e/txen
add wave -noupdate /testbench/dev_b/dev_e/usbprtl_e/crcglue_e/rxdv
add wave -noupdate /testbench/dev_b/dev_e/usbprtl_e/rxdv
add wave -noupdate /testbench/dev_b/dev_e/phy_rxdv
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/dev_b/dev_e/frwk_e/in_p/state
add wave -noupdate /testbench/dev_b/dev_e/usbprtl_e/idle
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -group dev_tp_p /testbench/dev_b/dev_e/tp(1)
add wave -noupdate -group dev_tp_p /testbench/dev_b/dev_e/tp(2)
add wave -noupdate -group dev_tp_p /testbench/dev_b/dev_e/tp(3)
add wave -noupdate -group dev_tp_p -radix hexadecimal /testbench/dev_b/tp_p/msb
add wave -noupdate -group dev_tp_p /testbench/dev_b/tp_p/cntr
add wave -noupdate -divider {New Divider}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3464763 ps} 1} {{Cursor 2} {6401145 ps} 1}
quietly wave cursor active 1
configure wave -namecolwidth 275
configure wave -valuecolwidth 274
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
WaveRestoreZoom {0 ps} {8400 ns}
