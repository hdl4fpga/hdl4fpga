onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/txc
add wave -noupdate /testbench/txen
add wave -noupdate /testbench/txd
add wave -noupdate /testbench/tx_d/line__20/cnt1
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/dp
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/rx_d/rxc
add wave -noupdate /testbench/rx_d/k
add wave -noupdate /testbench/rx_d/line__55/q
add wave -noupdate /testbench/rx_d/line__55/cntr
add wave -noupdate /testbench/rx_d/ena
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/rx_d/frm
add wave -noupdate /testbench/rx_d/dv
add wave -noupdate /testbench/rx_d/data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1253410 ps} 0} {{Cursor 2} {713785 ps} 0}
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
WaveRestoreZoom {302500 ps} {1352500 ps}
