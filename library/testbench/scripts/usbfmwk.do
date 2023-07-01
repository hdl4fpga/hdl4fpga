onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/usb_clk
add wave -noupdate /testbench/dp
add wave -noupdate /testbench/dn
add wave -noupdate -divider host_usbphy
add wave -noupdate -expand -group host_usbphycrc /testbench/host_b/host_e/cken
add wave -noupdate -expand -group host_usbphycrc /testbench/host_b/host_e/txen
add wave -noupdate -expand -group host_usbphycrc /testbench/host_b/host_e/txbs
add wave -noupdate -expand -group host_usbphycrc /testbench/host_b/host_e/pktfmt_p/state
add wave -noupdate -expand -group host_usbphycrc /testbench/host_b/host_e/txd
add wave -noupdate -expand -group host_usbphycrc /testbench/host_b/host_e/rxdv
add wave -noupdate -expand -group host_usbphycrc /testbench/host_b/host_e/rxd
add wave -noupdate -expand -group host_usbphycrc /testbench/host_b/host_e/rxbs
add wave -noupdate -expand -group host_usbphycrc -group host_usbphy_tx /testbench/host_b/host_e/usbphy_e/usbphytx_e/clk
add wave -noupdate -expand -group host_usbphycrc -group host_usbphy_tx /testbench/host_b/host_e/usbphy_e/usbphytx_e/cken
add wave -noupdate -expand -group host_usbphycrc -group host_usbphy_tx /testbench/host_b/host_e/usbphy_e/usbphytx_e/txen
add wave -noupdate -expand -group host_usbphycrc -group host_usbphy_tx /testbench/host_b/host_e/usbphy_e/usbphytx_e/txd
add wave -noupdate -expand -group host_usbphycrc -group host_usbphy_tx /testbench/host_b/host_e/usbphy_e/usbphytx_e/txbs
add wave -noupdate -expand -group host_usbphycrc -group host_usbphy_tx /testbench/host_b/host_e/usbphy_e/usbphytx_e/bit_stuffing
add wave -noupdate -expand -group host_usbphycrc -group host_usbphy_rx /testbench/host_b/host_e/usbphy_e/usbphyrx_e/rxdv
add wave -noupdate -expand -group host_usbphycrc -group host_usbphy_rx /testbench/host_b/host_e/usbphy_e/usbphyrx_e/rxbs
add wave -noupdate -expand -group host_usbphycrc -group host_usbphy_rx /testbench/host_b/host_e/usbphy_e/usbphyrx_e/rxd
add wave -noupdate -expand -group host_usbphycrc -group host_usbphy_rx /testbench/host_b/host_e/usbphy_e/usbphyrx_e/line__49/state
add wave -noupdate -expand -group host_usbphycrc -group host_usbphy_rx /testbench/host_b/host_e/usbphy_e/usbphyrx_e/line__49/statekj
add wave -noupdate -expand -group host_usbphycrc -group host_usbcrc /testbench/host_b/host_e/usbcrc_e/clk
add wave -noupdate -expand -group host_usbphycrc -group host_usbcrc /testbench/host_b/host_e/usbcrc_e/cken
add wave -noupdate -expand -group host_usbphycrc -group host_usbcrc /testbench/host_b/host_e/usbcrc_e/dv
add wave -noupdate -expand -group host_usbphycrc -group host_usbcrc /testbench/host_b/host_e/usbcrc_e/data
add wave -noupdate -expand -group host_usbphycrc -group host_usbcrc /testbench/host_b/host_e/crcact_tx
add wave -noupdate -expand -group host_usbphycrc -group host_usbcrc /testbench/host_b/host_e/usbcrc_e/usbcrc_g(0)/crc_b/crc_p/state
add wave -noupdate -expand -group host_usbphycrc -group host_usbcrc /testbench/host_b/host_e/usbcrc_e/crc5
add wave -noupdate -expand -group host_usbphycrc -group host_usbcrc /testbench/host_b/host_e/usbcrc_e/ncrc5
add wave -noupdate -expand -group host_usbphycrc -group host_usbcrc -radix binary /testbench/host_b/host_e/usbcrc_e/crc16
add wave -noupdate -expand -group host_usbphycrc -group host_usbcrc -radix hexadecimal /testbench/host_b/host_e/usbcrc_e/ncrc16
add wave -noupdate -expand -group host_rx_p /testbench/host_b/host_e/tp(1)
add wave -noupdate -expand -group host_rx_p /testbench/host_b/host_e/tp(2)
add wave -noupdate -expand -group host_rx_p /testbench/host_b/host_e/tp(3)
add wave -noupdate -expand -group host_rx_p /testbench/host_b/rx_p/cntr
add wave -noupdate -expand -group host_rx_p -radix hexadecimal /testbench/host_b/rx_p/msb
add wave -noupdate -divider dev_usbphy
add wave -noupdate -expand -group usbdev_e /testbench/dev_b/dev_e/rx_req
add wave -noupdate -expand -group usbdev_e /testbench/dev_b/dev_e/rx_rdy
add wave -noupdate -expand -group usbdev_e /testbench/dev_b/dev_e/tx_req
add wave -noupdate -expand -group usbdev_e /testbench/dev_b/dev_e/tx_rdy
add wave -noupdate -expand -group usbdev_e -radix hexadecimal /testbench/dev_b/dev_e/usbrqst_e/rxpid
add wave -noupdate -expand -group usbdev_e /testbench/dev_b/dev_e/usbrqst_e/usbrqst_p/setup_rdy
add wave -noupdate -expand -group usbdev_e /testbench/dev_b/dev_e/usbrqst_e/usbrqst_p/setup_req
add wave -noupdate -expand -group usbdev_e -radix hexadecimal /testbench/dev_b/dev_e/usbrqst_e/rxtoken
add wave -noupdate -expand -group usbdev_e -radix hexadecimal /testbench/dev_b/dev_e/usbrqst_e/rxrqst
add wave -noupdate -expand -group usbdev_e /testbench/dev_b/dev_e/usbrqst_e/usbrqst_p/shr
add wave -noupdate -expand -group usbdev_e /testbench/dev_b/dev_e/usbrqst_e/tp_state
add wave -noupdate -expand -group usbdev_e /testbench/dev_b/dev_e/usbrqst_e/txpid
add wave -noupdate -expand -group usbdev_e -divider {New Divider}
add wave -noupdate -expand -group usbdev_e /testbench/dev_b/dev_e/phy_rxdv
add wave -noupdate -expand -group usbdev_e /testbench/dev_b/dev_e/phy_rxbs
add wave -noupdate -expand -group usbdev_e -radix hexadecimal /testbench/dev_b/dev_e/phy_rxpid
add wave -noupdate -expand -group usbdev_e /testbench/dev_b/dev_e/usbrqst_e/usbrqst_p/request
add wave -noupdate -expand -group usbdev_e /testbench/dev_b/dev_e/phy_rxd
add wave -noupdate -expand -group usbdev_e -divider {New Divider}
add wave -noupdate -expand -group usbdev_e /testbench/dev_b/dev_e/pkt_txen
add wave -noupdate -expand -group usbdev_e -radix hexadecimal /testbench/dev_b/dev_e/pkt_txpid
add wave -noupdate -expand -group usbdev_e /testbench/dev_b/dev_e/pkt_txbs
add wave -noupdate -expand -group usbdev_e -radix hexadecimal /testbench/dev_b/dev_e/pkt_txd
add wave -noupdate -expand -group usbdev_e -divider {New Divider}
add wave -noupdate -expand -group usbdev_e /testbench/dev_b/dev_e/phy_txen
add wave -noupdate -expand -group usbdev_e /testbench/dev_b/dev_e/phy_txbs
add wave -noupdate -expand -group usbdev_e /testbench/dev_b/dev_e/phy_txd
add wave -noupdate -expand -group usbdev_e -expand -group dev_usbrqst -divider {New Divider}
add wave -noupdate -expand -group usbdev_e -expand -group dev_usbrqst /testbench/dev_b/dev_e/usbrqst_e/clk
add wave -noupdate -expand -group usbdev_e -expand -group dev_usbrqst /testbench/dev_b/dev_e/usbrqst_e/cken
add wave -noupdate -expand -group usbdev_e -expand -group dev_usbrqst -radix hexadecimal /testbench/dev_b/dev_e/usbrqst_e/usbrqst_p/request
add wave -noupdate -expand -group usbdev_e -expand -group dev_usbrqst -divider {New Divider}
add wave -noupdate -expand -group usbdev_e -expand -group dev_usbrqst /testbench/dev_b/dev_e/usbrqst_e/in_req
add wave -noupdate -expand -group usbdev_e -expand -group dev_usbrqst /testbench/dev_b/dev_e/usbrqst_e/rqst_rdys(set_address)
add wave -noupdate -expand -group usbdev_e -expand -group dev_usbrqst /testbench/dev_b/dev_e/usbrqst_e/out_req
add wave -noupdate -expand -group usbdev_e -group dev_usbphycrc -group dev_usbphy_tx /testbench/dev_b/dev_e/usbphycrc_e/usbphy_e/usbphytx_e/cken
add wave -noupdate -expand -group usbdev_e -group dev_usbphycrc -group dev_usbphy_tx /testbench/dev_b/dev_e/usbphycrc_e/usbphy_e/usbphytx_e/txen
add wave -noupdate -expand -group usbdev_e -group dev_usbphycrc -group dev_usbphy_tx /testbench/dev_b/dev_e/usbphycrc_e/usbphy_e/usbphytx_e/txd
add wave -noupdate -expand -group usbdev_e -group dev_usbphycrc -group dev_usbphy_tx /testbench/dev_b/dev_e/usbphycrc_e/usbphy_e/usbphytx_e/txbs
add wave -noupdate -expand -group usbdev_e -group dev_usbphycrc -group dev_usbphy_tx /testbench/dev_b/dev_e/usbphycrc_e/usbphy_e/usbphytx_e/txdp
add wave -noupdate -expand -group usbdev_e -group dev_usbphycrc -group dev_usbphy_tx /testbench/dev_b/dev_e/usbphycrc_e/usbphy_e/usbphytx_e/txdn
add wave -noupdate -expand -group usbdev_e -group dev_usbphycrc -expand -group dev_usbphy_rx /testbench/dev_b/dev_e/usbphycrc_e/usbphy_e/usbphyrx_e/clk
add wave -noupdate -expand -group usbdev_e -group dev_usbphycrc -expand -group dev_usbphy_rx /testbench/dev_b/dev_e/usbphycrc_e/usbphy_e/usbphyrx_e/cken
add wave -noupdate -expand -group usbdev_e -group dev_usbphycrc -expand -group dev_usbphy_rx /testbench/dev_b/dev_e/usbphycrc_e/usbphy_e/usbphyrx_e/j
add wave -noupdate -expand -group usbdev_e -group dev_usbphycrc -expand -group dev_usbphy_rx /testbench/dev_b/dev_e/usbphycrc_e/usbphy_e/usbphyrx_e/k
add wave -noupdate -expand -group usbdev_e -group dev_usbphycrc -expand -group dev_usbphy_rx /testbench/dev_b/dev_e/usbphycrc_e/usbphy_e/usbphyrx_e/se0
add wave -noupdate -expand -group usbdev_e -group dev_usbphycrc -expand -group dev_usbphy_rx /testbench/dev_b/dev_e/usbphycrc_e/usbphy_e/usbphyrx_e/rxdv
add wave -noupdate -expand -group usbdev_e -group dev_usbphycrc -expand -group dev_usbphy_rx /testbench/dev_b/dev_e/usbphycrc_e/usbphy_e/usbphyrx_e/rxbs
add wave -noupdate -expand -group usbdev_e -group dev_usbphycrc -expand -group dev_usbphy_rx /testbench/dev_b/dev_e/usbphycrc_e/usbphy_e/usbphyrx_e/rxd
add wave -noupdate -expand -group usbdev_e -group dev_usbphycrc -expand -group dev_usbphy_rx /testbench/dev_b/dev_e/usbphycrc_e/usbphy_e/usbphyrx_e/line__49/state
add wave -noupdate -expand -group usbdev_e -group dev_usbphycrc -expand -group dev_usbphy_rx /testbench/dev_b/dev_e/usbphycrc_e/usbphy_e/usbphyrx_e/line__49/statekj
add wave -noupdate -expand -group usbdev_e -group dev_usbphycrc -expand -group dev_usbphy_rx /testbench/dev_b/dev_e/usbphycrc_e/usbphy_e/usbphyrx_e/line__49/cnt1
add wave -noupdate -expand -group usbdev_e -group dev_usbphycrc -expand -group dev_usbphy_rx /testbench/dev_b/dev_e/usbphycrc_e/usbphy_e/usbphyrx_e/err
add wave -noupdate -expand -group usbdev_e -group dev_usbphycrc -expand -group dev_usbrcr /testbench/dev_b/dev_e/usbphycrc_e/usbcrc_e/clk
add wave -noupdate -expand -group usbdev_e -group dev_usbphycrc -expand -group dev_usbrcr /testbench/dev_b/dev_e/usbphycrc_e/usbcrc_e/cken
add wave -noupdate -expand -group usbdev_e -group dev_usbphycrc -expand -group dev_usbrcr /testbench/dev_b/dev_e/usbphycrc_e/usbcrc_e/dv
add wave -noupdate -expand -group usbdev_e -group dev_usbphycrc -expand -group dev_usbrcr /testbench/dev_b/dev_e/usbphycrc_e/usbcrc_e/data
add wave -noupdate -expand -group usbdev_e -group dev_usbphycrc -expand -group dev_usbrcr /testbench/dev_b/dev_e/usbphycrc_e/usbcrc_e/crc5
add wave -noupdate -expand -group usbdev_e -group dev_usbphycrc -expand -group dev_usbrcr /testbench/dev_b/dev_e/usbphycrc_e/usbcrc_e/ncrc5
add wave -noupdate -expand -group usbdev_e -group dev_usbphycrc -expand -group dev_usbrcr /testbench/dev_b/dev_e/usbphycrc_e/usbcrc_e/ncrc16
add wave -noupdate -expand -group usbdev_e -group dev_usbphycrc -expand -group dev_usbrcr /testbench/dev_b/dev_e/usbphycrc_e/usbcrc_e/crc16
add wave -noupdate -group dev_tp_p /testbench/dev_b/dev_e/tp(1)
add wave -noupdate -group dev_tp_p /testbench/dev_b/dev_e/tp(2)
add wave -noupdate -group dev_tp_p /testbench/dev_b/dev_e/tp(3)
add wave -noupdate -group dev_tp_p -radix hexadecimal /testbench/dev_b/tp_p/msb
add wave -noupdate -group dev_tp_p /testbench/dev_b/tp_p/cntr
add wave -noupdate /testbench/dev_b/dev_e/usbpktrx_e/rx_req
add wave -noupdate /testbench/dev_b/dev_e/usbpktrx_e/rx_rdy
add wave -noupdate /testbench/dev_b/dev_e/usbpktrx_e/line__51/state
add wave -noupdate /testbench/dev_b/dev_e/usbphycrc_e/usbphy_e/usbphyrx_e/rxdv
add wave -noupdate /testbench/dev_b/dev_e/usbpktrx_e/rxpid
add wave -noupdate /testbench/dev_b/dev_e/usbpktrx_e/line__51/state
add wave -noupdate -radix hexadecimal /testbench/dev_b/dev_e/usbpktrx_e/rxrqst
add wave -noupdate -radix hexadecimal /testbench/dev_b/dev_e/usbpktrx_e/rxtoken
add wave -noupdate -radix hexadecimal /testbench/dev_b/dev_e/usbpktrx_e/line__51/shr
add wave -noupdate /testbench/dev_b/dev_e/usbpktrx_e/line__51/cntr
add wave -noupdate /testbench/dev_b/dev_e/usbphycrc_e/usbphy_e/usbphyrx_e/rxbs
add wave -noupdate /testbench/dev_b/dev_e/usbphycrc_e/usbphy_e/usbphyrx_e/rxd
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {4539510 ps} 0} {{Cursor 2} {22151140 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 351
configure wave -valuecolwidth 408
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
WaveRestoreZoom {0 ps} {12915712 ps}
