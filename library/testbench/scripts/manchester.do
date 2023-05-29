onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/tx_d/txc
add wave -noupdate /testbench/tx_d/txen
add wave -noupdate /testbench/tx_d/txd
add wave -noupdate /testbench/tx_d/tx
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/rx_d/rx
add wave -noupdate /testbench/rx_d/rxc
add wave -noupdate /testbench/rx_d/rxdv
add wave -noupdate /testbench/rx_d/rxd
add wave -noupdate /testbench/rx_d/line__36/cntr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1769057 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
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
WaveRestoreZoom {1585065 ps} {2241315 ps}
