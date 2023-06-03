onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/txc
add wave -noupdate /testbench/txen
add wave -noupdate /testbench/txd
add wave -noupdate /testbench/dp
add wave -noupdate /testbench/dn
add wave -noupdate /testbench/tx_d/line__20/data
add wave -noupdate /testbench/tx_d/line__20/cnt1
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/rx_d/rxdp
add wave -noupdate /testbench/rx_d/rxdn
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/rx_d/frm
add wave -noupdate /testbench/rx_d/dv
add wave -noupdate /testbench/rx_d/data
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/rx_d/rxc
add wave -noupdate /testbench/rx_d/line__54/q
add wave -noupdate /testbench/rx_d/k
add wave -noupdate /testbench/rx_d/line__54/cntr(0)
add wave -noupdate -radix decimal /testbench/rx_d/line__54/cntr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {142322 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 132
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
WaveRestoreZoom {0 ps} {630 ns}
