onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/usb_clk
add wave -noupdate /testbench/dp
add wave -noupdate /testbench/dn
add wave -noupdate -divider host_usbphy
add wave -noupdate -group host_rx_p /testbench/host_b/rx_p/cntr
add wave -noupdate -group host_rx_p -radix hexadecimal /testbench/host_b/rx_p/msb
add wave -noupdate -expand -group host_usbphyerr /testbench/host_b/host_e/cken
add wave -noupdate -expand -group host_usbphyerr /testbench/host_b/host_e/txen
add wave -noupdate -expand -group host_usbphyerr /testbench/host_b/host_e/idle
add wave -noupdate -expand -group host_usbphyerr /testbench/host_b/host_e/txbs
add wave -noupdate -expand -group host_usbphyerr /testbench/host_b/host_e/pktfmt_p/state
add wave -noupdate -expand -group host_usbphyerr /testbench/host_b/host_e/txd
add wave -noupdate -expand -group host_usbphyerr /testbench/host_b/host_e/rxdv
add wave -noupdate -expand -group host_usbphyerr /testbench/host_b/host_e/rxd
add wave -noupdate -expand -group host_usbphyerr /testbench/host_b/host_e/rxbs
add wave -noupdate -expand -group host_usbphyerr -expand -group host_usbphy_tx /testbench/host_b/host_e/usbphy_e/tx_d/clk
add wave -noupdate -expand -group host_usbphyerr -expand -group host_usbphy_tx /testbench/host_b/host_e/usbphy_e/tx_d/cken
add wave -noupdate -expand -group host_usbphyerr -expand -group host_usbphy_tx /testbench/host_b/host_e/usbphy_e/tx_d/txen
add wave -noupdate -expand -group host_usbphyerr -expand -group host_usbphy_tx /testbench/host_b/host_e/usbphy_e/tx_d/txd
add wave -noupdate -expand -group host_usbphyerr -expand -group host_usbphy_tx /testbench/host_b/host_e/usbphy_e/tx_d/txbs
add wave -noupdate -expand -group host_usbphyerr -expand -group host_usbphy_tx /testbench/host_b/host_e/usbphy_e/tx_d/bit_stuffing
add wave -noupdate -expand -group host_usbphyerr -group host_usbphy_rx /testbench/host_b/host_e/usbphy_e/rx_d/rxdv
add wave -noupdate -expand -group host_usbphyerr -group host_usbphy_rx /testbench/host_b/host_e/usbphy_e/rx_d/rxbs
add wave -noupdate -expand -group host_usbphyerr -group host_usbphy_rx /testbench/host_b/host_e/usbphy_e/rx_d/rxd
add wave -noupdate -expand -group host_usbphyerr -group host_usbphy_rx /testbench/host_b/host_e/usbphy_e/rx_d/line__49/state
add wave -noupdate -expand -group host_usbphyerr -group host_usbphy_rx /testbench/host_b/host_e/usbphy_e/rx_d/line__49/statekj
add wave -noupdate -expand -group host_usbphyerr -group host_usbcrcglue /testbench/host_b/host_e/crcglue_e/clk
add wave -noupdate -expand -group host_usbphyerr -group host_usbcrcglue /testbench/host_b/host_e/crcglue_e/mealy_p/state
add wave -noupdate -expand -group host_usbphyerr -group host_usbcrcglue /testbench/host_b/host_e/crcglue_e/cken
add wave -noupdate -expand -group host_usbphyerr -group host_usbcrcglue /testbench/host_b/host_e/crcglue_e/bitstff
add wave -noupdate -expand -group host_usbphyerr -group host_usbcrcglue /testbench/host_b/host_e/crcglue_e/crcdv
add wave -noupdate -expand -group host_usbphyerr -group host_usbcrcglue /testbench/host_b/host_e/crcglue_e/crcact
add wave -noupdate -expand -group host_usbphyerr -group host_usbcrcglue /testbench/host_b/host_e/crcglue_e/crcen
add wave -noupdate -expand -group host_usbphyerr -group host_usbcrcglue /testbench/host_b/host_e/crcglue_e/crcd
add wave -noupdate -expand -group host_usbphyerr -group host_usbcrcglue /testbench/host_b/host_e/crcglue_e/txen
add wave -noupdate -expand -group host_usbphyerr -group host_usbcrcglue /testbench/host_b/host_e/crcglue_e/txbs
add wave -noupdate -expand -group host_usbphyerr -group host_usbcrcglue /testbench/host_b/host_e/crcglue_e/txd
add wave -noupdate -expand -group host_usbphyerr -group host_usbcrcglue /testbench/host_b/host_e/crcglue_e/phy_txen
add wave -noupdate -expand -group host_usbphyerr -group host_usbcrcglue /testbench/host_b/host_e/crcglue_e/phy_txbs
add wave -noupdate -expand -group host_usbphyerr -group host_usbcrcglue /testbench/host_b/host_e/crcglue_e/phy_txd
add wave -noupdate -expand -group host_usbphyerr -group host_usbcrcglue /testbench/host_b/host_e/crcglue_e/rxdv
add wave -noupdate -expand -group host_usbphyerr -group host_usbcrcglue /testbench/host_b/host_e/crcglue_e/rxbs
add wave -noupdate -expand -group host_usbphyerr -group host_usbcrcglue /testbench/host_b/host_e/crcglue_e/rxd
add wave -noupdate -expand -group host_usbphyerr -group host_usbcrcglue /testbench/host_b/host_e/crcglue_e/phy_rxdv
add wave -noupdate -expand -group host_usbphyerr -group host_usbcrcglue /testbench/host_b/host_e/crcglue_e/phy_rxbs
add wave -noupdate -expand -group host_usbphyerr -group host_usbcrcglue /testbench/host_b/host_e/crcglue_e/phy_rxd
add wave -noupdate -expand -group host_usbphyerr -expand -group host_usbcrc /testbench/host_b/host_e/usbcrc_e/clk
add wave -noupdate -expand -group host_usbphyerr -expand -group host_usbcrc /testbench/host_b/host_e/usbcrc_e/cken
add wave -noupdate -expand -group host_usbphyerr -expand -group host_usbcrc /testbench/host_b/host_e/usbcrc_e/dv
add wave -noupdate -expand -group host_usbphyerr -expand -group host_usbcrc /testbench/host_b/host_e/usbcrc_e/data
add wave -noupdate -expand -group host_usbphyerr -expand -group host_usbcrc /testbench/host_b/host_e/usbcrc_e/crc5
add wave -noupdate -expand -group host_usbphyerr -expand -group host_usbcrc /testbench/host_b/host_e/usbcrc_e/ncrc5
add wave -noupdate -expand -group host_usbphyerr -expand -group host_usbcrc -radix binary /testbench/host_b/host_e/usbcrc_e/crc16
add wave -noupdate -expand -group host_usbphyerr -expand -group host_usbcrc -radix hexadecimal /testbench/host_b/host_e/usbcrc_e/ncrc16
add wave -noupdate -divider dvc_usbphy
add wave -noupdate -expand -group dev_usbphyerr /testbench/dev_b/dev_e/cken
add wave -noupdate -expand -group dev_usbphyerr /testbench/dev_b/dev_e/usbphy_e/txen
add wave -noupdate -expand -group dev_usbphyerr /testbench/dev_b/dev_e/usbphy_e/phy_txen
add wave -noupdate -expand -group dev_usbphyerr /testbench/dev_b/dev_e/txbs
add wave -noupdate -expand -group dev_usbphyerr /testbench/dev_b/dev_e/txd
add wave -noupdate -expand -group dev_usbphyerr /testbench/dev_b/dev_e/usbphy_e/pktfmt_p/state
add wave -noupdate -expand -group dev_usbphyerr /testbench/dev_b/dev_e/usbphy_e/crcact
add wave -noupdate -expand -group dev_usbphyerr /testbench/dev_b/dev_e/usbphy_e/pktfmt_p/cntr
add wave -noupdate -expand -group dev_usbphyerr -radix hexadecimal /testbench/dev_b/dev_e/usbphy_e/pktfmt_p/pid
add wave -noupdate -expand -group dev_usbphyerr /testbench/dev_b/dev_e/rxdv
add wave -noupdate -expand -group dev_usbphyerr /testbench/dev_b/dev_e/rxbs
add wave -noupdate -expand -group dev_usbphyerr /testbench/dev_b/dev_e/rxd
add wave -noupdate -expand -group dev_usbphyerr /testbench/dev_b/dev_e/usbphy_e/usbphy_e/k
add wave -noupdate -expand -group dev_usbphyerr /testbench/dev_b/dev_e/usbphy_e/usbphy_e/j
add wave -noupdate -expand -group dev_usbphyerr /testbench/dev_b/dev_e/usbphy_e/usbphy_e/se0
add wave -noupdate -expand -group dev_usbphyerr -expand -group dev_usbphy_tx /testbench/dev_b/dev_e/usbphy_e/usbphy_e/tx_d/cken
add wave -noupdate -expand -group dev_usbphyerr -expand -group dev_usbphy_tx /testbench/dev_b/dev_e/usbphy_e/usbphy_e/tx_d/txen
add wave -noupdate -expand -group dev_usbphyerr -expand -group dev_usbphy_tx /testbench/dev_b/dev_e/usbphy_e/usbphy_e/tx_d/txd
add wave -noupdate -expand -group dev_usbphyerr -expand -group dev_usbphy_tx /testbench/dev_b/dev_e/usbphy_e/usbphy_e/tx_d/txbs
add wave -noupdate -expand -group dev_usbphyerr -expand -group dev_usbphy_tx /testbench/dev_b/dev_e/usbphy_e/usbphy_e/tx_d/txdp
add wave -noupdate -expand -group dev_usbphyerr -expand -group dev_usbphy_tx /testbench/dev_b/dev_e/usbphy_e/usbphy_e/tx_d/txdn
add wave -noupdate -expand -group dev_usbphyerr -group dev_usbphy_rx /testbench/dev_b/dev_e/usbphy_e/usbphy_e/rx_d/clk
add wave -noupdate -expand -group dev_usbphyerr -group dev_usbphy_rx /testbench/dev_b/dev_e/usbphy_e/usbphy_e/rx_d/cken
add wave -noupdate -expand -group dev_usbphyerr -group dev_usbphy_rx /testbench/dev_b/dev_e/usbphy_e/usbphy_e/rx_d/j
add wave -noupdate -expand -group dev_usbphyerr -group dev_usbphy_rx /testbench/dev_b/dev_e/usbphy_e/usbphy_e/rx_d/k
add wave -noupdate -expand -group dev_usbphyerr -group dev_usbphy_rx /testbench/dev_b/dev_e/usbphy_e/usbphy_e/rx_d/se0
add wave -noupdate -expand -group dev_usbphyerr -group dev_usbphy_rx /testbench/dev_b/dev_e/usbphy_e/usbphy_e/rx_d/rxdv
add wave -noupdate -expand -group dev_usbphyerr -group dev_usbphy_rx /testbench/dev_b/dev_e/usbphy_e/usbphy_e/rx_d/rxbs
add wave -noupdate -expand -group dev_usbphyerr -group dev_usbphy_rx /testbench/dev_b/dev_e/usbphy_e/usbphy_e/rx_d/rxd
add wave -noupdate -expand -group dev_usbphyerr -group dev_usbphy_rx /testbench/dev_b/dev_e/usbphy_e/usbphy_e/rx_d/line__49/state
add wave -noupdate -expand -group dev_usbphyerr -group dev_usbphy_rx /testbench/dev_b/dev_e/usbphy_e/usbphy_e/rx_d/line__49/statekj
add wave -noupdate -expand -group dev_usbphyerr -group dev_usbphy_rx /testbench/dev_b/dev_e/usbphy_e/usbphy_e/rx_d/line__49/cnt1
add wave -noupdate -expand -group dev_usbphyerr -group dev_usbphy_rx /testbench/dev_b/dev_e/usbphy_e/usbphy_e/rx_d/err
add wave -noupdate -expand -group dev_usbphyerr -group dev_usbcrcglue /testbench/dev_b/dev_e/usbphy_e/crcglue_e/clk
add wave -noupdate -expand -group dev_usbphyerr -group dev_usbcrcglue /testbench/dev_b/dev_e/usbphy_e/crcglue_e/cken
add wave -noupdate -expand -group dev_usbphyerr -group dev_usbcrcglue /testbench/dev_b/dev_e/usbphy_e/crcglue_e/bitstff
add wave -noupdate -expand -group dev_usbphyerr -group dev_usbcrcglue /testbench/dev_b/dev_e/usbphy_e/crcglue_e/crcdv
add wave -noupdate -expand -group dev_usbphyerr -group dev_usbcrcglue /testbench/dev_b/dev_e/usbphy_e/crcglue_e/crcact
add wave -noupdate -expand -group dev_usbphyerr -group dev_usbcrcglue /testbench/dev_b/dev_e/usbphy_e/crcglue_e/crcen
add wave -noupdate -expand -group dev_usbphyerr -group dev_usbcrcglue /testbench/dev_b/dev_e/usbphy_e/crcglue_e/crcd
add wave -noupdate -expand -group dev_usbphyerr -group dev_usbcrcglue /testbench/dev_b/dev_e/usbphy_e/crcglue_e/txen
add wave -noupdate -expand -group dev_usbphyerr -group dev_usbcrcglue /testbench/dev_b/dev_e/usbphy_e/crcglue_e/txbs
add wave -noupdate -expand -group dev_usbphyerr -group dev_usbcrcglue /testbench/dev_b/dev_e/usbphy_e/crcglue_e/txd
add wave -noupdate -expand -group dev_usbphyerr -group dev_usbcrcglue /testbench/dev_b/dev_e/usbphy_e/crcglue_e/phy_txen
add wave -noupdate -expand -group dev_usbphyerr -group dev_usbcrcglue /testbench/dev_b/dev_e/usbphy_e/crcglue_e/phy_txbs
add wave -noupdate -expand -group dev_usbphyerr -group dev_usbcrcglue /testbench/dev_b/dev_e/usbphy_e/crcglue_e/phy_txd
add wave -noupdate -expand -group dev_usbphyerr -group dev_usbcrcglue /testbench/dev_b/dev_e/usbphy_e/crcglue_e/rxdv
add wave -noupdate -expand -group dev_usbphyerr -group dev_usbcrcglue /testbench/dev_b/dev_e/usbphy_e/crcglue_e/rxbs
add wave -noupdate -expand -group dev_usbphyerr -group dev_usbcrcglue /testbench/dev_b/dev_e/usbphy_e/crcglue_e/rxd
add wave -noupdate -expand -group dev_usbphyerr -group dev_usbcrcglue /testbench/dev_b/dev_e/usbphy_e/crcglue_e/phy_rxdv
add wave -noupdate -expand -group dev_usbphyerr -group dev_usbcrcglue /testbench/dev_b/dev_e/usbphy_e/crcglue_e/phy_rxbs
add wave -noupdate -expand -group dev_usbphyerr -group dev_usbcrcglue /testbench/dev_b/dev_e/usbphy_e/crcglue_e/phy_rxd
add wave -noupdate -expand -group dev_usbphyerr -group dev_usbrcr /testbench/dev_b/dev_e/usbphy_e/usbcrc_e/clk
add wave -noupdate -expand -group dev_usbphyerr -group dev_usbrcr /testbench/dev_b/dev_e/usbphy_e/usbcrc_e/cken
add wave -noupdate -expand -group dev_usbphyerr -group dev_usbrcr /testbench/dev_b/dev_e/usbphy_e/crcglue_e/mealy_p/state
add wave -noupdate -expand -group dev_usbphyerr -group dev_usbrcr /testbench/dev_b/dev_e/usbphy_e/usbcrc_e/dv
add wave -noupdate -expand -group dev_usbphyerr -group dev_usbrcr /testbench/dev_b/dev_e/usbphy_e/usbcrc_e/data
add wave -noupdate -expand -group dev_usbphyerr -group dev_usbrcr /testbench/dev_b/dev_e/usbphy_e/usbcrc_e/crc5
add wave -noupdate -expand -group dev_usbphyerr -group dev_usbrcr /testbench/dev_b/dev_e/usbphy_e/usbcrc_e/crc16
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/dev_b/dev_e/txen
add wave -noupdate /testbench/dev_b/dev_e/usbphy_e/crcglue_e/mealy_p/state
add wave -noupdate /testbench/dev_b/dev_e/phy_rxdv
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/dev_b/dev_e/usbphy_e/idle
add wave -noupdate -divider {New Divider}
add wave -noupdate -expand -group dev_usbpkt_tx /testbench/dev_b/dev_e/usbpkttx_e/clk
add wave -noupdate -expand -group dev_usbpkt_tx /testbench/dev_b/dev_e/usbpkttx_e/cken
add wave -noupdate -expand -group dev_usbpkt_tx /testbench/dev_b/dev_e/usbpkttx_e/tx_req
add wave -noupdate -expand -group dev_usbpkt_tx /testbench/dev_b/dev_e/usbpkttx_e/tx_rdy
add wave -noupdate -expand -group dev_usbpkt_tx /testbench/dev_b/dev_e/usbpkttx_e/txpid
add wave -noupdate -expand -group dev_usbpkt_tx /testbench/dev_b/dev_e/usbpkttx_e/txen
add wave -noupdate -expand -group dev_usbpkt_tx /testbench/dev_b/dev_e/usbpkttx_e/txbs
add wave -noupdate -expand -group dev_usbpkt_tx /testbench/dev_b/dev_e/usbpkttx_e/txd
add wave -noupdate /testbench/dev_b/dev_e/usbrqst_e/usbrqst_p/state
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix hexadecimal /testbench/dev_b/dev_e/usbphy_e/rxpid
add wave -noupdate /testbench/dev_b/dev_e/usbphy_e/rxdv
add wave -noupdate /testbench/dev_b/dev_e/usbphy_e/usbphy_e/rxdv
add wave -noupdate -divider {New Divider}
add wave -noupdate -group dev_tp_p /testbench/dev_b/dev_e/tp(1)
add wave -noupdate -group dev_tp_p /testbench/dev_b/dev_e/tp(2)
add wave -noupdate -group dev_tp_p /testbench/dev_b/dev_e/tp(3)
add wave -noupdate -group dev_tp_p -radix hexadecimal /testbench/dev_b/tp_p/msb
add wave -noupdate -group dev_tp_p /testbench/dev_b/tp_p/cntr
add wave -noupdate -divider {New Divider}
add wave -noupdate -expand -group dev_usbpkt_rx /testbench/dev_b/dev_e/usbpktrx_e/rx_req
add wave -noupdate -expand -group dev_usbpkt_rx /testbench/dev_b/dev_e/usbpktrx_e/rx_rdy
add wave -noupdate -expand -group dev_usbpkt_rx /testbench/dev_b/dev_e/usbpktrx_e/addr
add wave -noupdate -expand -group dev_usbpkt_rx /testbench/dev_b/dev_e/cken
add wave -noupdate -expand -group dev_usbpkt_rx /testbench/dev_b/dev_e/usbpktrx_e/endp
add wave -noupdate -expand -group dev_usbpkt_rx /testbench/dev_b/dev_e/usbpktrx_e/rxdv
add wave -noupdate -expand -group dev_usbpkt_rx /testbench/dev_b/dev_e/usbphy_e/usbphy_e/rx_d/rxdv
add wave -noupdate -expand -group dev_usbpkt_rx /testbench/dev_b/dev_e/usbpktrx_e/rxd
add wave -noupdate -expand -group dev_usbpkt_rx /testbench/dev_b/dev_e/usbpktrx_e/rxbs
add wave -noupdate -expand -group dev_usbpkt_rx -radix hexadecimal -childformat {{/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(0) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(1) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(2) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(3) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(4) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(5) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(6) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(7) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(8) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(9) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(10) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(11) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(12) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(13) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(14) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(15) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(16) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(17) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(18) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(19) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(20) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(21) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(22) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(23) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(24) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(25) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(26) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(27) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(28) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(29) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(30) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(31) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(32) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(33) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(34) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(35) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(36) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(37) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(38) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(39) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(40) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(41) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(42) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(43) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(44) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(45) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(46) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(47) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(48) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(49) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(50) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(51) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(52) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(53) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(54) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(55) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(56) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(57) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(58) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(59) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(60) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(61) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(62) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(63) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(64) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(65) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(66) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(67) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(68) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(69) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(70) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(71) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(72) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(73) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(74) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(75) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(76) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(77) -radix hexadecimal} {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(78) -radix hexadecimal}} -subitemconfig {/testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(0) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(1) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(2) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(3) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(4) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(5) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(6) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(7) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(8) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(9) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(10) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(11) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(12) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(13) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(14) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(15) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(16) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(17) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(18) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(19) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(20) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(21) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(22) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(23) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(24) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(25) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(26) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(27) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(28) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(29) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(30) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(31) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(32) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(33) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(34) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(35) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(36) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(37) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(38) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(39) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(40) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(41) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(42) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(43) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(44) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(45) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(46) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(47) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(48) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(49) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(50) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(51) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(52) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(53) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(54) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(55) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(56) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(57) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(58) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(59) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(60) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(61) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(62) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(63) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(64) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(65) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(66) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(67) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(68) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(69) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(70) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(71) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(72) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(73) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(74) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(75) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(76) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(77) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr(78) {-height 29 -radix hexadecimal}} /testbench/dev_b/dev_e/usbpktrx_e/line__69/shr
add wave -noupdate -expand -group dev_usbpkt_rx /testbench/dev_b/dev_e/usbpktrx_e/line__69/state
add wave -noupdate /testbench/dev_b/dev_e/usbrqst_e/tx_req
add wave -noupdate /testbench/dev_b/dev_e/usbrqst_e/tx_rdy
add wave -noupdate /testbench/dev_b/dev_e/usbpkttx_e/line__59/state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3575157 ps} 0} {{Cursor 3} {27509303 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 245
configure wave -valuecolwidth 142
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
WaveRestoreZoom {70 ns} {29470 ns}
