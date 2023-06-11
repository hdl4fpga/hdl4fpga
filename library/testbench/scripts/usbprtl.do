onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/dp
add wave -noupdate /testbench/dn
add wave -noupdate -divider usbphy
add wave -noupdate /testbench/du_b/du/usbphy_e/j
add wave -noupdate /testbench/du_b/du/usbphy_e/k
add wave -noupdate /testbench/du_b/du/usbphy_e/se0
add wave -noupdate -divider usbphy_tx
add wave -noupdate /testbench/du_b/rst
add wave -noupdate /testbench/du_b/du/usbphy_e/tx_d/line__25/state
add wave -noupdate /testbench/du_b/du/usbphy_e/tx_d/cken
add wave -noupdate /testbench/du_b/du/usbphy_e/tx_d/txen
add wave -noupdate /testbench/du_b/du/usbphy_e/tx_d/txd
add wave -noupdate /testbench/du_b/du/usbphy_e/tx_d/txbs
add wave -noupdate /testbench/du_b/du/usbphy_e/tx_d/txdp
add wave -noupdate /testbench/du_b/du/usbphy_e/tx_d/txdn
add wave -noupdate -divider du_usbprtl
add wave -noupdate -divider tb_usbphy_rx
add wave -noupdate /testbench/tb_b/tb_e/usbphy_e/rx_d/rxdv
add wave -noupdate /testbench/tb_b/tb_e/usbphy_e/rx_d/rxbs
add wave -noupdate /testbench/tb_b/tb_e/usbphy_e/rx_d/rxd
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2958680 ps} 1} {{Cursor 2} {418795 ps} 0}
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
WaveRestoreZoom {0 ps} {4200 ns}
