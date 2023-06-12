onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/usb_clk
add wave -noupdate /testbench/dp
add wave -noupdate /testbench/dn
add wave -noupdate -divider host_usbphy
add wave -noupdate -expand -group host_usbprtcl -group host_usbphy_rx /testbench/host_b/host_e/usbphy_e/rx_d/rxdv
add wave -noupdate -expand -group host_usbprtcl -group host_usbphy_rx /testbench/host_b/host_e/usbphy_e/rx_d/rxbs
add wave -noupdate -expand -group host_usbprtcl -group host_usbphy_rx /testbench/host_b/host_e/usbphy_e/rx_d/rxd
add wave -noupdate -expand -group host_usbprtcl -group host_usbphy_rx /testbench/host_b/host_e/usbphy_e/rx_d/line__49/state
add wave -noupdate -expand -group host_usbprtcl -group host_usbphy_rx /testbench/host_b/host_e/usbphy_e/rx_d/line__49/statekj
add wave -noupdate -expand -group host_usbprtcl -group host_usbcrc /testbench/host_b/host_e/usbcrc_e/clk
add wave -noupdate -expand -group host_usbprtcl -group host_usbcrc /testbench/host_b/host_e/usbcrc_e/cken
add wave -noupdate -expand -group host_usbprtcl -group host_usbcrc /testbench/host_b/host_e/usbcrc_e/dv
add wave -noupdate -expand -group host_usbprtcl -group host_usbcrc /testbench/host_b/host_e/usbcrc_e/data
add wave -noupdate -expand -group host_usbprtcl -group host_usbcrc /testbench/host_b/host_e/usbcrc_e/crc5
add wave -noupdate -expand -group host_usbprtcl -group host_usbcrc /testbench/host_b/host_e/usbcrc_e/ncrc5
add wave -noupdate -expand -group host_usbprtcl -group host_usbcrc /testbench/host_b/host_e/usbcrc_e/crc16
add wave -noupdate -expand -group host_usbprtcl -group host_usbcrc /testbench/host_b/host_e/usbcrc_e/ncrc16
add wave -noupdate -divider dvc_usbphy
add wave -noupdate -group dev_usbprtcl /testbench/dev_b/dev_e/usbphy_e/j
add wave -noupdate -group dev_usbprtcl /testbench/dev_b/dev_e/usbphy_e/k
add wave -noupdate -group dev_usbprtcl /testbench/dev_b/dev_e/usbphy_e/se0
add wave -noupdate -group dev_usbprtcl /testbench/dev_b/dev_e/phy_txen
add wave -noupdate -group dev_usbprtcl /testbench/dev_b/dev_e/cken
add wave -noupdate -group dev_usbprtcl /testbench/dev_b/dev_e/rxdv
add wave -noupdate -group dev_usbprtcl /testbench/dev_b/dev_e/crcrq
add wave -noupdate -group dev_usbprtcl -expand -group dev_usbrcr /testbench/dev_b/dev_e/usbcrc_e/clk
add wave -noupdate -group dev_usbprtcl -expand -group dev_usbrcr /testbench/dev_b/dev_e/usbcrc_e/cken
add wave -noupdate -group dev_usbprtcl -expand -group dev_usbrcr /testbench/dev_b/dev_e/usbcrc_e/dv
add wave -noupdate -group dev_usbprtcl -expand -group dev_usbrcr /testbench/dev_b/dev_e/usbcrc_e/data
add wave -noupdate -group dev_usbprtcl -expand -group dev_usbrcr /testbench/dev_b/dev_e/usbcrc_e/crc5
add wave -noupdate -group dev_usbprtcl -expand -group dev_usbrcr /testbench/dev_b/dev_e/usbcrc_e/crc16
add wave -noupdate -group dev_usbprtcl -expand -group dev_usbphy_tx /testbench/dev_b/dev_e/usbphy_e/tx_d/line__25/state
add wave -noupdate -group dev_usbprtcl -expand -group dev_usbphy_tx /testbench/dev_b/dev_e/usbphy_e/tx_d/cken
add wave -noupdate -group dev_usbprtcl -expand -group dev_usbphy_tx /testbench/dev_b/dev_e/usbphy_e/tx_d/txen
add wave -noupdate -group dev_usbprtcl -expand -group dev_usbphy_tx /testbench/dev_b/dev_e/usbphy_e/tx_d/txd
add wave -noupdate -group dev_usbprtcl -expand -group dev_usbphy_tx /testbench/dev_b/dev_e/usbphy_e/tx_d/txbs
add wave -noupdate -group dev_usbprtcl -expand -group dev_usbphy_tx /testbench/dev_b/dev_e/usbphy_e/tx_d/txdp
add wave -noupdate -group dev_usbprtcl -expand -group dev_usbphy_tx /testbench/dev_b/dev_e/usbphy_e/tx_d/txdn
add wave -noupdate -group dev_usbprtcl -expand -group dev_usbphy_rx /testbench/dev_b/dev_e/usbphy_e/rx_d/clk
add wave -noupdate -group dev_usbprtcl -expand -group dev_usbphy_rx /testbench/dev_b/dev_e/usbphy_e/rx_d/cken
add wave -noupdate -group dev_usbprtcl -expand -group dev_usbphy_rx /testbench/dev_b/dev_e/usbphy_e/rx_d/j
add wave -noupdate -group dev_usbprtcl -expand -group dev_usbphy_rx /testbench/dev_b/dev_e/usbphy_e/rx_d/k
add wave -noupdate -group dev_usbprtcl -expand -group dev_usbphy_rx /testbench/dev_b/dev_e/usbphy_e/rx_d/se0
add wave -noupdate -group dev_usbprtcl -expand -group dev_usbphy_rx /testbench/dev_b/dev_e/usbphy_e/rx_d/rxdv
add wave -noupdate -group dev_usbprtcl -expand -group dev_usbphy_rx /testbench/dev_b/dev_e/usbphy_e/rx_d/rxbs
add wave -noupdate -group dev_usbprtcl -expand -group dev_usbphy_rx /testbench/dev_b/dev_e/usbphy_e/rx_d/rxd
add wave -noupdate -group dev_usbprtcl -expand -group dev_usbphy_rx /testbench/dev_b/dev_e/usbphy_e/rx_d/err
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {8828401 ps} 0} {{Cursor 2} {2083350 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 230
configure wave -valuecolwidth 262
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
WaveRestoreZoom {1203585 ps} {3539161 ps}
