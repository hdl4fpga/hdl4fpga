onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/rst
add wave -noupdate /testbench/xclk
add wave -noupdate /testbench/clk
add wave -noupdate /testbench/uartrx_e/uart_sin
add wave -noupdate /testbench/uart_rxc
add wave -noupdate /testbench/uartrx_e/uart_ena
add wave -noupdate /testbench/uart_rxdv
add wave -noupdate -radix hexadecimal -childformat {{/testbench/uartrx_e/uart_rxd(7) -radix hexadecimal} {/testbench/uartrx_e/uart_rxd(6) -radix hexadecimal} {/testbench/uartrx_e/uart_rxd(5) -radix hexadecimal} {/testbench/uartrx_e/uart_rxd(4) -radix hexadecimal} {/testbench/uartrx_e/uart_rxd(3) -radix hexadecimal} {/testbench/uartrx_e/uart_rxd(2) -radix hexadecimal} {/testbench/uartrx_e/uart_rxd(1) -radix hexadecimal} {/testbench/uartrx_e/uart_rxd(0) -radix hexadecimal}} -subitemconfig {/testbench/uartrx_e/uart_rxd(7) {-height 29 -radix hexadecimal} /testbench/uartrx_e/uart_rxd(6) {-height 29 -radix hexadecimal} /testbench/uartrx_e/uart_rxd(5) {-height 29 -radix hexadecimal} /testbench/uartrx_e/uart_rxd(4) {-height 29 -radix hexadecimal} /testbench/uartrx_e/uart_rxd(3) {-height 29 -radix hexadecimal} /testbench/uartrx_e/uart_rxd(2) {-height 29 -radix hexadecimal} /testbench/uartrx_e/uart_rxd(1) {-height 29 -radix hexadecimal} /testbench/uartrx_e/uart_rxd(0) {-height 29 -radix hexadecimal}} /testbench/uartrx_e/uart_rxd
add wave -noupdate -radix hexadecimal /testbench/uartrx_e/uart_state
add wave -noupdate -radix hexadecimal /testbench/uartrx_e/sample_rxd
add wave -noupdate -radix hexadecimal /testbench/uartrx_e/init_cntr
add wave -noupdate -radix hexadecimal /testbench/uartrx_e/half_count
add wave -noupdate -radix hexadecimal /testbench/uartrx_e/full_count
add wave -noupdate /testbench/line__71/max_count
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {82254 ns} 0} {{Cursor 2} {2304000 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 261
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
WaveRestoreZoom {999999297 ns} {1000000037 ns}
