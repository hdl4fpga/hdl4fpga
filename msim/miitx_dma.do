onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/mii_req
add wave -noupdate /testbench/mii_txc
add wave -noupdate -radix hexadecimal /testbench/mii_txd
add wave -noupdate /testbench/n
add wave -noupdate -radix hexadecimal /testbench/ram
add wave -noupdate -radix hexadecimal /testbench/sys_addr
add wave -noupdate -radix hexadecimal /testbench/sys_data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
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
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {1050 ps}
