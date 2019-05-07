onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/rst
add wave -noupdate /testbench/clk
add wave -noupdate /testbench/xclk
add wave -noupdate -radix hexadecimal /testbench/line__49/data
add wave -noupdate /testbench/uart_rxc
add wave -noupdate /testbench/uart_sin
add wave -noupdate /testbench/uart_rxdv
add wave -noupdate /testbench/uart_rxd
add wave -noupdate /testbench/uartrx_e/line__54/uart_state
add wave -noupdate -radix hexadecimal /testbench/uartrx_e/line__54/tcntr
add wave -noupdate -radix hexadecimal /testbench/uartrx_e/line__54/dcntr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {43221 ns} 0} {{Cursor 2} {17360 ns} 0}
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
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {105 us}
