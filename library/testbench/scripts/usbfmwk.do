onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/usb_clk
add wave -noupdate /testbench/dp
add wave -noupdate /testbench/dn
add wave -noupdate /testbench/dev_b/dev_e/usbphycrc_e/crc5_16
add wave -noupdate -divider host_usbphy
add wave -noupdate -expand -group host_usbphycrc /testbench/host_b/host_e/cken
add wave -noupdate -expand -group host_usbphycrc /testbench/host_b/host_e/txen
add wave -noupdate -expand -group host_usbphycrc /testbench/host_b/host_e/txbs
add wave -noupdate -expand -group host_usbphycrc /testbench/host_b/host_e/pktfmt_p/state
add wave -noupdate -expand -group host_usbphycrc /testbench/host_b/host_e/txd
add wave -noupdate -expand -group host_usbphycrc /testbench/host_b/host_e/rxdv
add wave -noupdate -expand -group host_usbphycrc /testbench/dev_b/dev_e/usbphycrc_e/crcact_tx
add wave -noupdate -expand -group host_usbphycrc /testbench/dev_b/dev_e/usbphycrc_e/crc0
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
add wave -noupdate -expand -group host_usbphycrc -expand -group host_usbcrc /testbench/host_b/host_e/usbcrc_e/clk
add wave -noupdate -expand -group host_usbphycrc -expand -group host_usbcrc /testbench/host_b/host_e/usbcrc_e/cken
add wave -noupdate -expand -group host_usbphycrc -expand -group host_usbcrc /testbench/dev_b/dev_e/usbphycrc_e/usbcrc_e/usbcrc_g(1)/crc_b/crc
add wave -noupdate -expand -group host_usbphycrc -expand -group host_usbcrc /testbench/host_b/host_e/usbcrc_e/dv
add wave -noupdate -expand -group host_usbphycrc -expand -group host_usbcrc /testbench/host_b/host_e/usbcrc_e/data
add wave -noupdate -expand -group host_usbphycrc -expand -group host_usbcrc /testbench/host_b/host_e/crcact_tx
add wave -noupdate -expand -group host_usbphycrc -expand -group host_usbcrc /testbench/host_b/host_e/usbcrc_e/usbcrc_g(0)/crc_b/crc_p/state
add wave -noupdate -expand -group host_usbphycrc -expand -group host_usbcrc /testbench/host_b/host_e/usbcrc_e/crc5
add wave -noupdate -expand -group host_usbphycrc -expand -group host_usbcrc /testbench/host_b/host_e/usbcrc_e/ncrc5
add wave -noupdate -expand -group host_usbphycrc -expand -group host_usbcrc -radix hexadecimal /testbench/host_b/host_e/usbcrc_e/crc16
add wave -noupdate -expand -group host_usbphycrc -expand -group host_usbcrc -radix binary -childformat {{/testbench/host_b/host_e/usbcrc_e/ncrc16(0) -radix binary} {/testbench/host_b/host_e/usbcrc_e/ncrc16(1) -radix binary} {/testbench/host_b/host_e/usbcrc_e/ncrc16(2) -radix binary} {/testbench/host_b/host_e/usbcrc_e/ncrc16(3) -radix binary} {/testbench/host_b/host_e/usbcrc_e/ncrc16(4) -radix binary} {/testbench/host_b/host_e/usbcrc_e/ncrc16(5) -radix binary} {/testbench/host_b/host_e/usbcrc_e/ncrc16(6) -radix binary} {/testbench/host_b/host_e/usbcrc_e/ncrc16(7) -radix binary} {/testbench/host_b/host_e/usbcrc_e/ncrc16(8) -radix binary} {/testbench/host_b/host_e/usbcrc_e/ncrc16(9) -radix binary} {/testbench/host_b/host_e/usbcrc_e/ncrc16(10) -radix binary} {/testbench/host_b/host_e/usbcrc_e/ncrc16(11) -radix binary} {/testbench/host_b/host_e/usbcrc_e/ncrc16(12) -radix binary} {/testbench/host_b/host_e/usbcrc_e/ncrc16(13) -radix binary} {/testbench/host_b/host_e/usbcrc_e/ncrc16(14) -radix binary} {/testbench/host_b/host_e/usbcrc_e/ncrc16(15) -radix binary}} -subitemconfig {/testbench/host_b/host_e/usbcrc_e/ncrc16(0) {-height 29 -radix binary} /testbench/host_b/host_e/usbcrc_e/ncrc16(1) {-height 29 -radix binary} /testbench/host_b/host_e/usbcrc_e/ncrc16(2) {-height 29 -radix binary} /testbench/host_b/host_e/usbcrc_e/ncrc16(3) {-height 29 -radix binary} /testbench/host_b/host_e/usbcrc_e/ncrc16(4) {-height 29 -radix binary} /testbench/host_b/host_e/usbcrc_e/ncrc16(5) {-height 29 -radix binary} /testbench/host_b/host_e/usbcrc_e/ncrc16(6) {-height 29 -radix binary} /testbench/host_b/host_e/usbcrc_e/ncrc16(7) {-height 29 -radix binary} /testbench/host_b/host_e/usbcrc_e/ncrc16(8) {-height 29 -radix binary} /testbench/host_b/host_e/usbcrc_e/ncrc16(9) {-height 29 -radix binary} /testbench/host_b/host_e/usbcrc_e/ncrc16(10) {-height 29 -radix binary} /testbench/host_b/host_e/usbcrc_e/ncrc16(11) {-height 29 -radix binary} /testbench/host_b/host_e/usbcrc_e/ncrc16(12) {-height 29 -radix binary} /testbench/host_b/host_e/usbcrc_e/ncrc16(13) {-height 29 -radix binary} /testbench/host_b/host_e/usbcrc_e/ncrc16(14) {-height 29 -radix binary} /testbench/host_b/host_e/usbcrc_e/ncrc16(15) {-height 29 -radix binary}} /testbench/host_b/host_e/usbcrc_e/ncrc16
add wave -noupdate -group host_rx_p /testbench/host_b/host_e/tp(1)
add wave -noupdate -group host_rx_p /testbench/host_b/host_e/tp(2)
add wave -noupdate -group host_rx_p /testbench/host_b/host_e/tp(3)
add wave -noupdate -group host_rx_p /testbench/host_b/rx_p/cntr
add wave -noupdate -group host_rx_p -radix hexadecimal /testbench/host_b/rx_p/msb
add wave -noupdate -divider dev_usbphy
add wave -noupdate -expand -group usbdev_e /testbench/dev_b/dev_e/rx_req
add wave -noupdate -expand -group usbdev_e /testbench/dev_b/dev_e/rx_rdy
add wave -noupdate -expand -group usbdev_e /testbench/dev_b/dev_e/tx_req
add wave -noupdate -expand -group usbdev_e /testbench/dev_b/dev_e/tx_rdy
add wave -noupdate -expand -group usbdev_e -radix hexadecimal /testbench/dev_b/dev_e/usbrqst_e/rxpid
add wave -noupdate -expand -group usbdev_e -radix hexadecimal /testbench/dev_b/dev_e/usbrqst_e/rxtoken
add wave -noupdate -expand -group usbdev_e -radix hexadecimal /testbench/dev_b/dev_e/usbrqst_e/rxrqst
add wave -noupdate -expand -group usbdev_e /testbench/dev_b/dev_e/usbrqst_e/tp_state
add wave -noupdate -expand -group usbdev_e /testbench/dev_b/dev_e/usbrqst_e/txpid
add wave -noupdate -expand -group usbdev_e -divider {New Divider}
add wave -noupdate -expand -group usbdev_e /testbench/dev_b/dev_e/phy_rxdv
add wave -noupdate -expand -group usbdev_e /testbench/dev_b/dev_e/usbphycrc_e/phy_rxdv
add wave -noupdate -expand -group usbdev_e /testbench/dev_b/dev_e/usbphycrc_e/pktfmt_p/state
add wave -noupdate -expand -group usbdev_e /testbench/dev_b/dev_e/usbphycrc_e/crcact_rx
add wave -noupdate -expand -group usbdev_e /testbench/dev_b/dev_e/usbphycrc_e/crcact_tx
add wave -noupdate -expand -group usbdev_e /testbench/dev_b/dev_e/phy_rxbs
add wave -noupdate -expand -group usbdev_e /testbench/dev_b/dev_e/phy_rxd
add wave -noupdate -expand -group usbdev_e -radix hexadecimal /testbench/dev_b/dev_e/phy_rxpid
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
add wave -noupdate -expand -group usbdev_e -expand -group dev_usbrqst /testbench/dev_b/dev_e/usbrqst_e/txen
add wave -noupdate -expand -group usbdev_e -expand -group dev_usbrqst /testbench/dev_b/dev_e/usbrqst_e/txbs
add wave -noupdate -expand -group usbdev_e -expand -group dev_usbrqst /testbench/dev_b/dev_e/usbrqst_e/txd
add wave -noupdate -expand -group usbdev_e -expand -group dev_usbrqst -radix hexadecimal -childformat {{/testbench/dev_b/dev_e/usbrqst_e/hosttodev_p/request(7) -radix hexadecimal} {/testbench/dev_b/dev_e/usbrqst_e/hosttodev_p/request(6) -radix hexadecimal} {/testbench/dev_b/dev_e/usbrqst_e/hosttodev_p/request(5) -radix hexadecimal} {/testbench/dev_b/dev_e/usbrqst_e/hosttodev_p/request(4) -radix hexadecimal} {/testbench/dev_b/dev_e/usbrqst_e/hosttodev_p/request(3) -radix hexadecimal} {/testbench/dev_b/dev_e/usbrqst_e/hosttodev_p/request(2) -radix hexadecimal} {/testbench/dev_b/dev_e/usbrqst_e/hosttodev_p/request(1) -radix hexadecimal} {/testbench/dev_b/dev_e/usbrqst_e/hosttodev_p/request(0) -radix hexadecimal}} -subitemconfig {/testbench/dev_b/dev_e/usbrqst_e/hosttodev_p/request(7) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbrqst_e/hosttodev_p/request(6) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbrqst_e/hosttodev_p/request(5) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbrqst_e/hosttodev_p/request(4) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbrqst_e/hosttodev_p/request(3) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbrqst_e/hosttodev_p/request(2) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbrqst_e/hosttodev_p/request(1) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbrqst_e/hosttodev_p/request(0) {-height 29 -radix hexadecimal}} /testbench/dev_b/dev_e/usbrqst_e/hosttodev_p/request
add wave -noupdate -expand -group usbdev_e -expand -group dev_usbrqst -radix hexadecimal /testbench/dev_b/dev_e/usbrqst_e/rxpid
add wave -noupdate -expand -group usbdev_e -expand -group dev_usbrqst -divider {New Divider}
add wave -noupdate -expand -group usbdev_e -expand -group dev_usbrqst -radix hexadecimal /testbench/dev_b/dev_e/usbrqst_e/token
add wave -noupdate -expand -group usbdev_e -expand -group dev_usbrqst /testbench/dev_b/dev_e/usbrqst_e/in_req
add wave -noupdate -expand -group usbdev_e -expand -group dev_usbrqst /testbench/dev_b/dev_e/usbrqst_e/in_rdy
add wave -noupdate -expand -group usbdev_e -expand -group dev_usbrqst -divider {New Divider}
add wave -noupdate -expand -group usbdev_e -expand -group dev_usbrqst /testbench/dev_b/dev_e/usbrqst_e/out_req
add wave -noupdate -expand -group usbdev_e -expand -group dev_usbrqst /testbench/dev_b/dev_e/usbrqst_e/out_rdy
add wave -noupdate -expand -group usbdev_e -expand -group dev_usbrqst /testbench/dev_b/dev_e/usbrqst_e/data_req
add wave -noupdate -expand -group usbdev_e -expand -group dev_usbrqst /testbench/dev_b/dev_e/usbrqst_e/data_rdy
add wave -noupdate -expand -group usbdev_e -expand -group dev_usbrqst /testbench/dev_b/dev_e/usbrqst_e/ack_req
add wave -noupdate -expand -group usbdev_e -expand -group dev_usbrqst /testbench/dev_b/dev_e/usbrqst_e/ack_rdy
add wave -noupdate -expand -group usbdev_e -expand -group dev_usbrqst /testbench/dev_b/dev_e/usbrqst_e/setaddress_req
add wave -noupdate -expand -group usbdev_e -expand -group dev_usbrqst /testbench/dev_b/dev_e/usbrqst_e/setaddress_rdy
add wave -noupdate -expand -group usbdev_e -expand -group dev_usbrqst /testbench/dev_b/dev_e/usbrqst_e/getdescriptor_req
add wave -noupdate -expand -group usbdev_e -expand -group dev_usbrqst /testbench/dev_b/dev_e/usbrqst_e/getdescriptor_rdy
add wave -noupdate -expand -group usbdev_e -group dev_usbpkt_tx /testbench/dev_b/dev_e/usbpkttx_e/tx_req
add wave -noupdate -expand -group usbdev_e -group dev_usbpkt_tx /testbench/dev_b/dev_e/usbpkttx_e/tx_rdy
add wave -noupdate -expand -group usbdev_e -group dev_usbpkt_tx /testbench/dev_b/dev_e/usbpkttx_e/line__54/state
add wave -noupdate -expand -group usbdev_e -group dev_usbpkt_tx -radix hexadecimal /testbench/dev_b/dev_e/usbpkttx_e/pkt_txpid
add wave -noupdate -expand -group usbdev_e -group dev_usbpkt_tx /testbench/dev_b/dev_e/usbpkttx_e/pkt_txen
add wave -noupdate -expand -group usbdev_e -group dev_usbpkt_tx /testbench/dev_b/dev_e/usbpkttx_e/pkt_txbs
add wave -noupdate -expand -group usbdev_e -group dev_usbpkt_tx /testbench/dev_b/dev_e/usbpkttx_e/pkt_txd
add wave -noupdate -expand -group usbdev_e -group dev_usbpkt_tx /testbench/dev_b/dev_e/usbpkttx_e/phy_txen
add wave -noupdate -expand -group usbdev_e -group dev_usbpkt_tx /testbench/dev_b/dev_e/usbpkttx_e/phy_txbs
add wave -noupdate -expand -group usbdev_e -group dev_usbpkt_tx /testbench/dev_b/dev_e/usbpkttx_e/phy_txd
add wave -noupdate -expand -group usbdev_e -expand -group dev_usbphycrc -group dev_usbphy_tx /testbench/dev_b/dev_e/usbphycrc_e/usbphy_e/usbphytx_e/cken
add wave -noupdate -expand -group usbdev_e -expand -group dev_usbphycrc -group dev_usbphy_tx /testbench/dev_b/dev_e/usbphycrc_e/usbphy_e/usbphytx_e/txen
add wave -noupdate -expand -group usbdev_e -expand -group dev_usbphycrc -group dev_usbphy_tx /testbench/dev_b/dev_e/usbphycrc_e/usbphy_e/usbphytx_e/txd
add wave -noupdate -expand -group usbdev_e -expand -group dev_usbphycrc -group dev_usbphy_tx /testbench/dev_b/dev_e/usbphycrc_e/usbphy_e/usbphytx_e/txbs
add wave -noupdate -expand -group usbdev_e -expand -group dev_usbphycrc -group dev_usbphy_tx /testbench/dev_b/dev_e/usbphycrc_e/usbphy_e/usbphytx_e/txdp
add wave -noupdate -expand -group usbdev_e -expand -group dev_usbphycrc -group dev_usbphy_tx /testbench/dev_b/dev_e/usbphycrc_e/usbphy_e/usbphytx_e/txdn
add wave -noupdate -expand -group usbdev_e -expand -group dev_usbphycrc -group dev_usbphy_rx /testbench/dev_b/dev_e/usbphycrc_e/usbphy_e/usbphyrx_e/clk
add wave -noupdate -expand -group usbdev_e -expand -group dev_usbphycrc -group dev_usbphy_rx /testbench/dev_b/dev_e/usbphycrc_e/usbphy_e/usbphyrx_e/cken
add wave -noupdate -expand -group usbdev_e -expand -group dev_usbphycrc -group dev_usbphy_rx /testbench/dev_b/dev_e/usbphycrc_e/usbphy_e/usbphyrx_e/j
add wave -noupdate -expand -group usbdev_e -expand -group dev_usbphycrc -group dev_usbphy_rx /testbench/dev_b/dev_e/usbphycrc_e/usbphy_e/usbphyrx_e/k
add wave -noupdate -expand -group usbdev_e -expand -group dev_usbphycrc -group dev_usbphy_rx /testbench/dev_b/dev_e/usbphycrc_e/usbphy_e/usbphyrx_e/se0
add wave -noupdate -expand -group usbdev_e -expand -group dev_usbphycrc -group dev_usbphy_rx /testbench/dev_b/dev_e/usbphycrc_e/usbphy_e/usbphyrx_e/rxdv
add wave -noupdate -expand -group usbdev_e -expand -group dev_usbphycrc -group dev_usbphy_rx /testbench/dev_b/dev_e/usbphycrc_e/usbphy_e/usbphyrx_e/rxbs
add wave -noupdate -expand -group usbdev_e -expand -group dev_usbphycrc -group dev_usbphy_rx /testbench/dev_b/dev_e/usbphycrc_e/usbphy_e/usbphyrx_e/rxd
add wave -noupdate -expand -group usbdev_e -expand -group dev_usbphycrc -group dev_usbphy_rx /testbench/dev_b/dev_e/usbphycrc_e/usbphy_e/usbphyrx_e/line__49/state
add wave -noupdate -expand -group usbdev_e -expand -group dev_usbphycrc -group dev_usbphy_rx /testbench/dev_b/dev_e/usbphycrc_e/usbphy_e/usbphyrx_e/line__49/statekj
add wave -noupdate -expand -group usbdev_e -expand -group dev_usbphycrc -group dev_usbphy_rx /testbench/dev_b/dev_e/usbphycrc_e/usbphy_e/usbphyrx_e/line__49/cnt1
add wave -noupdate -expand -group usbdev_e -expand -group dev_usbphycrc -group dev_usbphy_rx /testbench/dev_b/dev_e/usbphycrc_e/usbphy_e/usbphyrx_e/err
add wave -noupdate -expand -group usbdev_e -expand -group dev_usbphycrc -group dev_usbrcr /testbench/dev_b/dev_e/usbphycrc_e/usbcrc_e/clk
add wave -noupdate -expand -group usbdev_e -expand -group dev_usbphycrc -group dev_usbrcr /testbench/dev_b/dev_e/usbphycrc_e/usbcrc_e/cken
add wave -noupdate -expand -group usbdev_e -expand -group dev_usbphycrc -group dev_usbrcr /testbench/dev_b/dev_e/usbphycrc_e/usbcrc_e/dv
add wave -noupdate -expand -group usbdev_e -expand -group dev_usbphycrc -group dev_usbrcr /testbench/dev_b/dev_e/usbphycrc_e/usbcrc_e/data
add wave -noupdate -expand -group usbdev_e -expand -group dev_usbphycrc -group dev_usbrcr /testbench/dev_b/dev_e/usbphycrc_e/usbcrc_e/usbcrc_g(1)/crc_b/crc_p/state
add wave -noupdate -expand -group usbdev_e -expand -group dev_usbphycrc -group dev_usbrcr /testbench/dev_b/dev_e/usbphycrc_e/usbcrc_e/crc5
add wave -noupdate -expand -group usbdev_e -expand -group dev_usbphycrc -group dev_usbrcr /testbench/dev_b/dev_e/usbphycrc_e/usbcrc_e/ncrc5
add wave -noupdate -expand -group usbdev_e -expand -group dev_usbphycrc -group dev_usbrcr -radix binary /testbench/dev_b/dev_e/usbphycrc_e/usbcrc_e/ncrc16
add wave -noupdate -expand -group usbdev_e -expand -group dev_usbphycrc -group dev_usbrcr -radix binary /testbench/dev_b/dev_e/usbphycrc_e/usbcrc_e/crc16
add wave -noupdate -expand -group usbdev_e /testbench/dev_b/dev_e/usbphycrc_e/crcact_tx
add wave -noupdate -expand -group usbdev_e /testbench/dev_b/dev_e/usbphycrc_e/crc0
add wave -noupdate -group dev_tp_p /testbench/dev_b/dev_e/tp(1)
add wave -noupdate -group dev_tp_p /testbench/dev_b/dev_e/tp(2)
add wave -noupdate -group dev_tp_p /testbench/dev_b/dev_e/tp(3)
add wave -noupdate -group dev_tp_p -radix hexadecimal /testbench/dev_b/tp_p/msb
add wave -noupdate -group dev_tp_p /testbench/dev_b/tp_p/cntr
add wave -noupdate /testbench/dev_b/dev_e/usbrqst_e/getdescriptor_p/cntr
add wave -noupdate -radix hexadecimal /testbench/dev_b/dev_e/usbrqst_e/getdescriptor_p/descriptor_addr
add wave -noupdate /testbench/dev_b/dev_e/usbrqst_e/getdescriptor_p/descriptor_length
add wave -noupdate /testbench/dev_b/dev_e/usbrqst_e/tp(13)
add wave -noupdate /testbench/dev_b/dev_e/usbrqst_e/tp(14)
add wave -noupdate /testbench/dev_b/dev_e/usbrqst_e/tp(15)
add wave -noupdate /testbench/dev_b/dev_e/usbrqst_e/tx_req
add wave -noupdate /testbench/dev_b/dev_e/usbrqst_e/tx_rdy
add wave -noupdate /testbench/dev_b/dev_e/usbrqst_e/getdescriptor_p/state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {45174088 ps} 0} {{Cursor 2} {68366232 ps} 0} {{Cursor 3} {87142529 ps} 0}
quietly wave cursor active 3
configure wave -namecolwidth 282
configure wave -valuecolwidth 172
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
WaveRestoreZoom {62328364 ps} {114828364 ps}
