onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/clk
add wave -noupdate -radix hexadecimal /testbench/mulp_b/mand
add wave -noupdate -radix hexadecimal /testbench/mulp_b/mier
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/mulp_b/ci
add wave -noupdate -radix hexadecimal -childformat {{/testbench/mulp_b/fifo_o(3) -radix hexadecimal} {/testbench/mulp_b/fifo_o(2) -radix hexadecimal} {/testbench/mulp_b/fifo_o(1) -radix hexadecimal} {/testbench/mulp_b/fifo_o(0) -radix hexadecimal}} -subitemconfig {/testbench/mulp_b/fifo_o(3) {-height 16 -radix hexadecimal} /testbench/mulp_b/fifo_o(2) {-height 16 -radix hexadecimal} /testbench/mulp_b/fifo_o(1) {-height 16 -radix hexadecimal} /testbench/mulp_b/fifo_o(0) {-height 16 -radix hexadecimal}} /testbench/mulp_b/fifo_o
add wave -noupdate -radix hexadecimal /testbench/mulp_b/b
add wave -noupdate /testbench/mulp_b/co
add wave -noupdate -radix hexadecimal /testbench/mulp_b/s
add wave -noupdate -radix hexadecimal -childformat {{/testbench/mulp_b/fifo_i(3) -radix hexadecimal} {/testbench/mulp_b/fifo_i(2) -radix hexadecimal} {/testbench/mulp_b/fifo_i(1) -radix hexadecimal} {/testbench/mulp_b/fifo_i(0) -radix hexadecimal}} -subitemconfig {/testbench/mulp_b/fifo_i(3) {-height 16 -radix hexadecimal} /testbench/mulp_b/fifo_i(2) {-height 16 -radix hexadecimal} /testbench/mulp_b/fifo_i(1) {-height 16 -radix hexadecimal} /testbench/mulp_b/fifo_i(0) {-height 16 -radix hexadecimal}} /testbench/mulp_b/fifo_i
add wave -noupdate /testbench/mulp_b/inia
add wave -noupdate /testbench/ini
add wave -noupdate -radix hexadecimal /testbench/mulp_b/sela
add wave -noupdate -radix hexadecimal /testbench/mulp_b/selb
add wave -noupdate /testbench/mulp_b/inim
add wave -noupdate -radix hexadecimal /testbench/mulp_b/dg
add wave -noupdate /testbench/mulp_b/dv
add wave -noupdate /testbench/mulp_b/last
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {30 ns} 0} {{Cursor 2} {148 ns} 0}
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
WaveRestoreZoom {0 ns} {210 ns}
