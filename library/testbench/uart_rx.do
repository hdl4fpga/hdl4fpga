onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/rst
add wave -noupdate /testbench/clk
add wave -noupdate /testbench/xclk
add wave -noupdate /testbench/uart_rxc
add wave -noupdate /testbench/uart_sin
add wave -noupdate /testbench/uart_rxdv
add wave -noupdate -radix hexadecimal -childformat {{/testbench/uart_rxd(7) -radix hexadecimal} {/testbench/uart_rxd(6) -radix hexadecimal} {/testbench/uart_rxd(5) -radix hexadecimal} {/testbench/uart_rxd(4) -radix hexadecimal} {/testbench/uart_rxd(3) -radix hexadecimal} {/testbench/uart_rxd(2) -radix hexadecimal} {/testbench/uart_rxd(1) -radix hexadecimal} {/testbench/uart_rxd(0) -radix hexadecimal}} -expand -subitemconfig {/testbench/uart_rxd(7) {-height 16 -radix hexadecimal} /testbench/uart_rxd(6) {-height 16 -radix hexadecimal} /testbench/uart_rxd(5) {-height 16 -radix hexadecimal} /testbench/uart_rxd(4) {-height 16 -radix hexadecimal} /testbench/uart_rxd(3) {-height 16 -radix hexadecimal} /testbench/uart_rxd(2) {-height 16 -radix hexadecimal} /testbench/uart_rxd(1) {-height 16 -radix hexadecimal} /testbench/uart_rxd(0) {-height 16 -radix hexadecimal}} /testbench/uart_rxd
add wave -noupdate /testbench/uartrx_e/line__54/uart_state
add wave -noupdate /testbench/uartrx_e/din
add wave -noupdate -radix hexadecimal /testbench/uartrx_e/line__54/tcntr(0)
add wave -noupdate -radix hexadecimal -childformat {{/testbench/uartrx_e/line__54/tcntr(0) -radix hexadecimal} {/testbench/uartrx_e/line__54/tcntr(1) -radix hexadecimal} {/testbench/uartrx_e/line__54/tcntr(2) -radix hexadecimal}} -subitemconfig {/testbench/uartrx_e/line__54/tcntr(0) {-height 16 -radix hexadecimal} /testbench/uartrx_e/line__54/tcntr(1) {-height 16 -radix hexadecimal} /testbench/uartrx_e/line__54/tcntr(2) {-height 16 -radix hexadecimal}} /testbench/uartrx_e/line__54/tcntr
add wave -noupdate -radix hexadecimal /testbench/uartrx_e/line__54/dcntr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {82900 ns} 0} {{Cursor 2} {12460 ns} 0}
quietly wave cursor active 2
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
WaveRestoreZoom {12030 ns} {24630 ns}
