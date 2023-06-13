onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/usb_clk
add wave -noupdate /testbench/dp
add wave -noupdate /testbench/dn
add wave -noupdate -divider host_usbphy
add wave -noupdate -expand -group host_usbprtcl /testbench/host_b/host_e/cken
add wave -noupdate -expand -group host_usbprtcl /testbench/host_b/host_e/txen
add wave -noupdate -expand -group host_usbprtcl /testbench/host_b/host_e/txbs
add wave -noupdate -expand -group host_usbprtcl /testbench/host_b/host_e/txd
add wave -noupdate -expand -group host_usbprtcl /testbench/host_b/host_e/rxdv
add wave -noupdate -expand -group host_usbprtcl /testbench/host_b/host_e/rxd
add wave -noupdate -expand -group host_usbprtcl /testbench/host_b/host_e/rxbs
add wave -noupdate -expand -group host_usbprtcl -group host_usbphy_tx /testbench/host_b/host_e/usbphy_e/tx_d/clk
add wave -noupdate -expand -group host_usbprtcl -group host_usbphy_tx /testbench/host_b/host_e/usbphy_e/tx_d/cken
add wave -noupdate -expand -group host_usbprtcl -group host_usbphy_tx /testbench/host_b/host_e/usbphy_e/tx_d/txen
add wave -noupdate -expand -group host_usbprtcl -group host_usbphy_tx /testbench/host_b/host_e/usbphy_e/tx_d/txd
add wave -noupdate -expand -group host_usbprtcl -group host_usbphy_tx /testbench/host_b/host_e/usbphy_e/tx_d/txbs
add wave -noupdate -expand -group host_usbprtcl -group host_usbphy_tx /testbench/host_b/host_e/usbphy_e/tx_d/bit_stuffing
add wave -noupdate -expand -group host_usbprtcl -group host_usbphy_tx /testbench/host_b/host_e/usbphy_e/tx_d/line__25/data
add wave -noupdate -expand -group host_usbprtcl -group host_usbphy_tx /testbench/host_b/host_e/usbphy_e/tx_d/line__25/state
add wave -noupdate -expand -group host_usbprtcl -group host_usbphy_rx /testbench/host_b/host_e/usbphy_e/rx_d/rxdv
add wave -noupdate -expand -group host_usbprtcl -group host_usbphy_rx /testbench/host_b/host_e/usbphy_e/rx_d/rxbs
add wave -noupdate -expand -group host_usbprtcl -group host_usbphy_rx /testbench/host_b/host_e/usbphy_e/rx_d/rxd
add wave -noupdate -expand -group host_usbprtcl -group host_usbphy_rx /testbench/host_b/host_e/usbphy_e/rx_d/line__49/state
add wave -noupdate -expand -group host_usbprtcl -group host_usbphy_rx /testbench/host_b/host_e/usbphy_e/rx_d/line__49/statekj
add wave -noupdate -expand -group host_usbprtcl -group host_usbcrcglue /testbench/host_b/host_e/crcglue_e/clk
add wave -noupdate -expand -group host_usbprtcl -group host_usbcrcglue /testbench/host_b/host_e/crcglue_e/cken
add wave -noupdate -expand -group host_usbprtcl -group host_usbcrcglue /testbench/host_b/host_e/crcglue_e/dv
add wave -noupdate -expand -group host_usbprtcl -group host_usbcrcglue /testbench/host_b/host_e/crcglue_e/bitstff
add wave -noupdate -expand -group host_usbprtcl -group host_usbcrcglue /testbench/host_b/host_e/crcglue_e/data
add wave -noupdate -expand -group host_usbprtcl -group host_usbcrcglue /testbench/host_b/host_e/crcglue_e/crcdv
add wave -noupdate -expand -group host_usbprtcl -group host_usbcrcglue /testbench/host_b/host_e/crcglue_e/crcact
add wave -noupdate -expand -group host_usbprtcl -group host_usbcrcglue /testbench/host_b/host_e/crcglue_e/crcen
add wave -noupdate -expand -group host_usbprtcl -group host_usbcrcglue /testbench/host_b/host_e/crcglue_e/crcd
add wave -noupdate -expand -group host_usbprtcl -group host_usbcrcglue /testbench/host_b/host_e/crcglue_e/txen
add wave -noupdate -expand -group host_usbprtcl -group host_usbcrcglue /testbench/host_b/host_e/crcglue_e/txbs
add wave -noupdate -expand -group host_usbprtcl -group host_usbcrcglue /testbench/host_b/host_e/crcglue_e/txd
add wave -noupdate -expand -group host_usbprtcl -group host_usbcrcglue /testbench/host_b/host_e/crcglue_e/phy_txen
add wave -noupdate -expand -group host_usbprtcl -group host_usbcrcglue /testbench/host_b/host_e/crcglue_e/phy_txbs
add wave -noupdate -expand -group host_usbprtcl -group host_usbcrcglue /testbench/host_b/host_e/crcglue_e/phy_txd
add wave -noupdate -expand -group host_usbprtcl -group host_usbcrcglue /testbench/host_b/host_e/crcglue_e/rxdv
add wave -noupdate -expand -group host_usbprtcl -group host_usbcrcglue /testbench/host_b/host_e/crcglue_e/rxbs
add wave -noupdate -expand -group host_usbprtcl -group host_usbcrcglue /testbench/host_b/host_e/crcglue_e/rxd
add wave -noupdate -expand -group host_usbprtcl -group host_usbcrcglue /testbench/host_b/host_e/crcglue_e/phy_rxdv
add wave -noupdate -expand -group host_usbprtcl -group host_usbcrcglue /testbench/host_b/host_e/crcglue_e/phy_rxbs
add wave -noupdate -expand -group host_usbprtcl -group host_usbcrcglue /testbench/host_b/host_e/crcglue_e/phy_rxd
add wave -noupdate -expand -group host_usbprtcl -group host_usbcrc /testbench/host_b/host_e/usbcrc_e/clk
add wave -noupdate -expand -group host_usbprtcl -group host_usbcrc /testbench/host_b/host_e/usbcrc_e/cken
add wave -noupdate -expand -group host_usbprtcl -group host_usbcrc /testbench/host_b/host_e/usbcrc_e/dv
add wave -noupdate -expand -group host_usbprtcl -group host_usbcrc /testbench/host_b/host_e/usbcrc_e/data
add wave -noupdate -expand -group host_usbprtcl -group host_usbcrc /testbench/host_b/host_e/usbcrc_e/crc5
add wave -noupdate -expand -group host_usbprtcl -group host_usbcrc /testbench/host_b/host_e/usbcrc_e/ncrc5
add wave -noupdate -expand -group host_usbprtcl -group host_usbcrc -radix hexadecimal /testbench/host_b/host_e/usbcrc_e/crc16
add wave -noupdate -expand -group host_usbprtcl -group host_usbcrc -radix hexadecimal /testbench/host_b/host_e/usbcrc_e/ncrc16
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
add wave -noupdate -expand -group dev_usbprtcl -group dev_usbphy_tx /testbench/dev_b/dev_e/usbprtl_e/usbphy_e/tx_d/line__25/state
add wave -noupdate -expand -group dev_usbprtcl -group dev_usbphy_tx /testbench/dev_b/dev_e/usbprtl_e/usbphy_e/tx_d/cken
add wave -noupdate -expand -group dev_usbprtcl -group dev_usbphy_tx /testbench/dev_b/dev_e/usbprtl_e/usbphy_e/tx_d/txen
add wave -noupdate -expand -group dev_usbprtcl -group dev_usbphy_tx /testbench/dev_b/dev_e/usbprtl_e/usbphy_e/tx_d/txd
add wave -noupdate -expand -group dev_usbprtcl -group dev_usbphy_tx /testbench/dev_b/dev_e/usbprtl_e/usbphy_e/tx_d/txbs
add wave -noupdate -expand -group dev_usbprtcl -group dev_usbphy_tx /testbench/dev_b/dev_e/usbprtl_e/usbphy_e/tx_d/txdp
add wave -noupdate -expand -group dev_usbprtcl -group dev_usbphy_tx /testbench/dev_b/dev_e/usbprtl_e/usbphy_e/tx_d/txdn
add wave -noupdate -expand -group dev_usbprtcl -group dev_usbphy_rx /testbench/dev_b/dev_e/usbprtl_e/usbphy_e/rx_d/clk
add wave -noupdate -expand -group dev_usbprtcl -group dev_usbphy_rx /testbench/dev_b/dev_e/usbprtl_e/usbphy_e/rx_d/cken
add wave -noupdate -expand -group dev_usbprtcl -group dev_usbphy_rx /testbench/dev_b/dev_e/usbprtl_e/usbphy_e/rx_d/j
add wave -noupdate -expand -group dev_usbprtcl -group dev_usbphy_rx /testbench/dev_b/dev_e/usbprtl_e/usbphy_e/rx_d/k
add wave -noupdate -expand -group dev_usbprtcl -group dev_usbphy_rx /testbench/dev_b/dev_e/usbprtl_e/usbphy_e/rx_d/se0
add wave -noupdate -expand -group dev_usbprtcl -group dev_usbphy_rx /testbench/dev_b/dev_e/usbprtl_e/usbphy_e/rx_d/rxdv
add wave -noupdate -expand -group dev_usbprtcl -group dev_usbphy_rx /testbench/dev_b/dev_e/usbprtl_e/usbphy_e/rx_d/rxbs
add wave -noupdate -expand -group dev_usbprtcl -group dev_usbphy_rx /testbench/dev_b/dev_e/usbprtl_e/usbphy_e/rx_d/rxd
add wave -noupdate -expand -group dev_usbprtcl -group dev_usbphy_rx /testbench/dev_b/dev_e/usbprtl_e/usbphy_e/rx_d/line__49/state
add wave -noupdate -expand -group dev_usbprtcl -group dev_usbphy_rx /testbench/dev_b/dev_e/usbprtl_e/usbphy_e/rx_d/line__49/statekj
add wave -noupdate -expand -group dev_usbprtcl -group dev_usbphy_rx /testbench/dev_b/dev_e/usbprtl_e/usbphy_e/rx_d/line__49/cnt1
add wave -noupdate -expand -group dev_usbprtcl -group dev_usbphy_rx /testbench/dev_b/dev_e/usbprtl_e/usbphy_e/rx_d/err
add wave -noupdate -expand -group dev_usbprtcl -group dev_usbcrcglue /testbench/dev_b/dev_e/usbprtl_e/crcglue_e/clk
add wave -noupdate -expand -group dev_usbprtcl -group dev_usbcrcglue /testbench/dev_b/dev_e/usbprtl_e/crcglue_e/cken
add wave -noupdate -expand -group dev_usbprtcl -group dev_usbcrcglue /testbench/dev_b/dev_e/usbprtl_e/crcglue_e/dv
add wave -noupdate -expand -group dev_usbprtcl -group dev_usbcrcglue /testbench/dev_b/dev_e/usbprtl_e/crcglue_e/bitstff
add wave -noupdate -expand -group dev_usbprtcl -group dev_usbcrcglue /testbench/dev_b/dev_e/usbprtl_e/crcglue_e/data
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
add wave -noupdate -expand -group dev_usbprtcl -group dev_usbrcr /testbench/dev_b/dev_e/usbprtl_e/usbcrc_e/clk
add wave -noupdate -expand -group dev_usbprtcl -group dev_usbrcr /testbench/dev_b/dev_e/usbprtl_e/usbcrc_e/cken
add wave -noupdate -expand -group dev_usbprtcl -group dev_usbrcr /testbench/dev_b/dev_e/usbprtl_e/usbcrc_e/dv
add wave -noupdate -expand -group dev_usbprtcl -group dev_usbrcr /testbench/dev_b/dev_e/usbprtl_e/usbcrc_e/data
add wave -noupdate -expand -group dev_usbprtcl -group dev_usbrcr /testbench/dev_b/dev_e/usbprtl_e/usbcrc_e/crc5
add wave -noupdate -expand -group dev_usbprtcl -group dev_usbrcr /testbench/dev_b/dev_e/usbprtl_e/usbcrc_e/crc16
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/dev_b/dev_e/frwk_e/setup_p/state
add wave -noupdate -radix hexadecimal /testbench/dev_b/dev_e/frwk_e/setup_p/pid
add wave -noupdate -radix hexadecimal /testbench/dev_b/dev_e/frwk_e/setup_p/rgtr
add wave -noupdate -radix hexadecimal -childformat {{/testbench/dev_b/dev_e/frwk_e/setup_p/token(23) -radix hexadecimal} {/testbench/dev_b/dev_e/frwk_e/setup_p/token(22) -radix hexadecimal} {/testbench/dev_b/dev_e/frwk_e/setup_p/token(21) -radix hexadecimal} {/testbench/dev_b/dev_e/frwk_e/setup_p/token(20) -radix hexadecimal} {/testbench/dev_b/dev_e/frwk_e/setup_p/token(19) -radix hexadecimal} {/testbench/dev_b/dev_e/frwk_e/setup_p/token(18) -radix hexadecimal} {/testbench/dev_b/dev_e/frwk_e/setup_p/token(17) -radix hexadecimal} {/testbench/dev_b/dev_e/frwk_e/setup_p/token(16) -radix hexadecimal} {/testbench/dev_b/dev_e/frwk_e/setup_p/token(15) -radix hexadecimal} {/testbench/dev_b/dev_e/frwk_e/setup_p/token(14) -radix hexadecimal} {/testbench/dev_b/dev_e/frwk_e/setup_p/token(13) -radix hexadecimal} {/testbench/dev_b/dev_e/frwk_e/setup_p/token(12) -radix hexadecimal} {/testbench/dev_b/dev_e/frwk_e/setup_p/token(11) -radix hexadecimal} {/testbench/dev_b/dev_e/frwk_e/setup_p/token(10) -radix hexadecimal} {/testbench/dev_b/dev_e/frwk_e/setup_p/token(9) -radix hexadecimal} {/testbench/dev_b/dev_e/frwk_e/setup_p/token(8) -radix hexadecimal} {/testbench/dev_b/dev_e/frwk_e/setup_p/token(7) -radix hexadecimal} {/testbench/dev_b/dev_e/frwk_e/setup_p/token(6) -radix hexadecimal} {/testbench/dev_b/dev_e/frwk_e/setup_p/token(5) -radix hexadecimal} {/testbench/dev_b/dev_e/frwk_e/setup_p/token(4) -radix hexadecimal} {/testbench/dev_b/dev_e/frwk_e/setup_p/token(3) -radix hexadecimal} {/testbench/dev_b/dev_e/frwk_e/setup_p/token(2) -radix hexadecimal} {/testbench/dev_b/dev_e/frwk_e/setup_p/token(1) -radix hexadecimal} {/testbench/dev_b/dev_e/frwk_e/setup_p/token(0) -radix hexadecimal}} -subitemconfig {/testbench/dev_b/dev_e/frwk_e/setup_p/token(23) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/frwk_e/setup_p/token(22) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/frwk_e/setup_p/token(21) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/frwk_e/setup_p/token(20) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/frwk_e/setup_p/token(19) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/frwk_e/setup_p/token(18) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/frwk_e/setup_p/token(17) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/frwk_e/setup_p/token(16) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/frwk_e/setup_p/token(15) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/frwk_e/setup_p/token(14) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/frwk_e/setup_p/token(13) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/frwk_e/setup_p/token(12) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/frwk_e/setup_p/token(11) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/frwk_e/setup_p/token(10) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/frwk_e/setup_p/token(9) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/frwk_e/setup_p/token(8) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/frwk_e/setup_p/token(7) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/frwk_e/setup_p/token(6) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/frwk_e/setup_p/token(5) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/frwk_e/setup_p/token(4) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/frwk_e/setup_p/token(3) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/frwk_e/setup_p/token(2) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/frwk_e/setup_p/token(1) {-height 29 -radix hexadecimal} /testbench/dev_b/dev_e/frwk_e/setup_p/token(0) {-height 29 -radix hexadecimal}} /testbench/dev_b/dev_e/frwk_e/setup_p/token
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/dev_b/dev_e/frwk_e/rxdv
add wave -noupdate /testbench/dev_b/dev_e/phy_rxdv
add wave -noupdate /testbench/dev_b/dev_e/frwk_e/tk_setup
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {6569325 ps} 1} {{Cursor 2} {8757476 ps} 1} {{Cursor 3} {2163545 ps} 1} {{Cursor 4} {3408340 ps} 1} {{Cursor 5} {3615821 ps} 0}
quietly wave cursor active 5
configure wave -namecolwidth 266
configure wave -valuecolwidth 97
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
WaveRestoreZoom {0 ps} {4200 ns}
