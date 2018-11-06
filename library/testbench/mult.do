onerror {resume}
quietly virtual signal -install /testbench/mulp_b { /testbench/mulp_b/prod(3 downto 0)} pmier
quietly virtual signal -install /testbench/mulp_b { /testbench/mulp_b/xxp/temp(3 downto 0)} tmier
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/clk
add wave -noupdate -radix hexadecimal /testbench/mulp_b/mand
add wave -noupdate -radix hexadecimal /testbench/mulp_b/mier
add wave -noupdate -radix hexadecimal -childformat {{/testbench/mulp_b/prod(7) -radix hexadecimal} {/testbench/mulp_b/prod(6) -radix hexadecimal} {/testbench/mulp_b/prod(5) -radix hexadecimal} {/testbench/mulp_b/prod(4) -radix hexadecimal} {/testbench/mulp_b/prod(3) -radix hexadecimal} {/testbench/mulp_b/prod(2) -radix hexadecimal} {/testbench/mulp_b/prod(1) -radix hexadecimal} {/testbench/mulp_b/prod(0) -radix hexadecimal}} -subitemconfig {/testbench/mulp_b/prod(7) {-height 16 -radix hexadecimal} /testbench/mulp_b/prod(6) {-height 16 -radix hexadecimal} /testbench/mulp_b/prod(5) {-height 16 -radix hexadecimal} /testbench/mulp_b/prod(4) {-height 16 -radix hexadecimal} /testbench/mulp_b/prod(3) {-height 16 -radix hexadecimal} /testbench/mulp_b/prod(2) {-height 16 -radix hexadecimal} /testbench/mulp_b/prod(1) {-height 16 -radix hexadecimal} /testbench/mulp_b/prod(0) {-height 16 -radix hexadecimal}} /testbench/mulp_b/prod
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/mulp_b/ci
add wave -noupdate -radix hexadecimal -childformat {{/testbench/mulp_b/fifo_o(3) -radix hexadecimal} {/testbench/mulp_b/fifo_o(2) -radix hexadecimal} {/testbench/mulp_b/fifo_o(1) -radix hexadecimal} {/testbench/mulp_b/fifo_o(0) -radix hexadecimal}} -subitemconfig {/testbench/mulp_b/fifo_o(3) {-height 16 -radix hexadecimal} /testbench/mulp_b/fifo_o(2) {-height 16 -radix hexadecimal} /testbench/mulp_b/fifo_o(1) {-height 16 -radix hexadecimal} /testbench/mulp_b/fifo_o(0) {-height 16 -radix hexadecimal}} /testbench/mulp_b/fifo_o
add wave -noupdate -radix hexadecimal /testbench/mulp_b/pmier
add wave -noupdate -radix hexadecimal /testbench/mulp_b/tmier
add wave -noupdate -radix hexadecimal /testbench/mulp_b/s
add wave -noupdate -radix hexadecimal /testbench/mulp_b/b
add wave -noupdate /testbench/mulp_b/co
add wave -noupdate -radix hexadecimal -childformat {{/testbench/mulp_b/fifo_i(3) -radix hexadecimal} {/testbench/mulp_b/fifo_i(2) -radix hexadecimal} {/testbench/mulp_b/fifo_i(1) -radix hexadecimal} {/testbench/mulp_b/fifo_i(0) -radix hexadecimal}} -subitemconfig {/testbench/mulp_b/fifo_i(3) {-height 16 -radix hexadecimal} /testbench/mulp_b/fifo_i(2) {-height 16 -radix hexadecimal} /testbench/mulp_b/fifo_i(1) {-height 16 -radix hexadecimal} /testbench/mulp_b/fifo_i(0) {-height 16 -radix hexadecimal}} /testbench/mulp_b/fifo_i
add wave -noupdate /testbench/mulp_b/inia
add wave -noupdate /testbench/mulp_b/inim
add wave -noupdate -radix hexadecimal /testbench/mulp_b/dg
add wave -noupdate /testbench/mulp_b/dv
add wave -noupdate -radix hexadecimal /testbench/mulp_b/kk
add wave -noupdate -radix hexadecimal /testbench/mulp_b/cc
add wave -noupdate -radix hexadecimal /testbench/mulp_b/pp
add wave -noupdate -radix hexadecimal /testbench/mulp_b/xxp/xxxx
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {159 ns} 0}
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
WaveRestoreZoom {0 ns} {252 ns}
