onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/ddr_timer_rst
add wave -noupdate /testbench/du/ddr_timer_clk
add wave -noupdate /testbench/ddr_timer_sel
add wave -noupdate /testbench/du/ddr_timer_200u
add wave -noupdate /testbench/du/ddr_timer_dll
add wave -noupdate /testbench/du/ddr_timer_ref
add wave -noupdate -radix hexadecimal /testbench/du/counter_g(0)/q(0)
add wave -noupdate -radix hexadecimal /testbench/du/counter_g(1)/q(0)
add wave -noupdate -radix hexadecimal -childformat {{/testbench/du/counter_g(0)/d(0) -radix hexadecimal} {/testbench/du/counter_g(0)/d(1) -radix hexadecimal} {/testbench/du/counter_g(0)/d(2) -radix hexadecimal} {/testbench/du/counter_g(0)/d(3) -radix hexadecimal} {/testbench/du/counter_g(0)/d(4) -radix hexadecimal} {/testbench/du/counter_g(0)/d(5) -radix hexadecimal} {/testbench/du/counter_g(0)/d(6) -radix hexadecimal} {/testbench/du/counter_g(0)/d(7) -radix hexadecimal} {/testbench/du/counter_g(0)/d(8) -radix hexadecimal} {/testbench/du/counter_g(0)/d(9) -radix hexadecimal} {/testbench/du/counter_g(0)/d(10) -radix hexadecimal} {/testbench/du/counter_g(0)/d(11) -radix hexadecimal}} -subitemconfig {/testbench/du/counter_g(0)/d(0) {-height 16 -radix hexadecimal} /testbench/du/counter_g(0)/d(1) {-height 16 -radix hexadecimal} /testbench/du/counter_g(0)/d(2) {-height 16 -radix hexadecimal} /testbench/du/counter_g(0)/d(3) {-height 16 -radix hexadecimal} /testbench/du/counter_g(0)/d(4) {-height 16 -radix hexadecimal} /testbench/du/counter_g(0)/d(5) {-height 16 -radix hexadecimal} /testbench/du/counter_g(0)/d(6) {-height 16 -radix hexadecimal} /testbench/du/counter_g(0)/d(7) {-height 16 -radix hexadecimal} /testbench/du/counter_g(0)/d(8) {-height 16 -radix hexadecimal} /testbench/du/counter_g(0)/d(9) {-height 16 -radix hexadecimal} /testbench/du/counter_g(0)/d(10) {-height 16 -radix hexadecimal} /testbench/du/counter_g(0)/d(11) {-height 16 -radix hexadecimal}} /testbench/du/counter_g(0)/d
add wave -noupdate -radix hexadecimal /testbench/du/counter_g(1)/q(0)
add wave -noupdate -radix hexadecimal /testbench/du/counter_g(0)/q(0)
add wave -noupdate -radix hexadecimal -childformat {{/testbench/du/counter_g(1)/d(0) -radix hexadecimal} {/testbench/du/counter_g(1)/d(1) -radix hexadecimal} {/testbench/du/counter_g(1)/d(2) -radix hexadecimal} {/testbench/du/counter_g(1)/d(3) -radix hexadecimal} {/testbench/du/counter_g(1)/d(4) -radix hexadecimal} {/testbench/du/counter_g(1)/d(5) -radix hexadecimal}} -subitemconfig {/testbench/du/counter_g(1)/d(0) {-height 16 -radix hexadecimal} /testbench/du/counter_g(1)/d(1) {-height 16 -radix hexadecimal} /testbench/du/counter_g(1)/d(2) {-height 16 -radix hexadecimal} /testbench/du/counter_g(1)/d(3) {-height 16 -radix hexadecimal} /testbench/du/counter_g(1)/d(4) {-height 16 -radix hexadecimal} /testbench/du/counter_g(1)/d(5) {-height 16 -radix hexadecimal}} /testbench/du/counter_g(1)/d
add wave -noupdate /testbench/du/counter_g(0)/load
add wave -noupdate -radix hexadecimal /testbench/du/counter_g(1)/q(0)
add wave -noupdate -radix hexadecimal -childformat {{/testbench/du/counter_g(1)/q(0) -radix hexadecimal} {/testbench/du/counter_g(1)/q(1) -radix hexadecimal} {/testbench/du/counter_g(1)/q(2) -radix hexadecimal} {/testbench/du/counter_g(1)/q(3) -radix hexadecimal} {/testbench/du/counter_g(1)/q(4) -radix hexadecimal} {/testbench/du/counter_g(1)/q(5) -radix hexadecimal}} -subitemconfig {/testbench/du/counter_g(1)/q(0) {-height 16 -radix hexadecimal} /testbench/du/counter_g(1)/q(1) {-height 16 -radix hexadecimal} /testbench/du/counter_g(1)/q(2) {-height 16 -radix hexadecimal} /testbench/du/counter_g(1)/q(3) {-height 16 -radix hexadecimal} /testbench/du/counter_g(1)/q(4) {-height 16 -radix hexadecimal} /testbench/du/counter_g(1)/q(5) {-height 16 -radix hexadecimal}} /testbench/du/counter_g(1)/q
add wave -noupdate -height 16 -radix hexadecimal /testbench/du/counter_g(0)/q(0)
add wave -noupdate -radix hexadecimal -childformat {{/testbench/du/counter_g(0)/q(0) -radix hexadecimal} {/testbench/du/counter_g(0)/q(1) -radix hexadecimal} {/testbench/du/counter_g(0)/q(2) -radix hexadecimal} {/testbench/du/counter_g(0)/q(3) -radix hexadecimal} {/testbench/du/counter_g(0)/q(4) -radix hexadecimal} {/testbench/du/counter_g(0)/q(5) -radix hexadecimal} {/testbench/du/counter_g(0)/q(6) -radix hexadecimal} {/testbench/du/counter_g(0)/q(7) -radix hexadecimal} {/testbench/du/counter_g(0)/q(8) -radix hexadecimal} {/testbench/du/counter_g(0)/q(9) -radix hexadecimal} {/testbench/du/counter_g(0)/q(10) -radix hexadecimal} {/testbench/du/counter_g(0)/q(11) -radix hexadecimal}} -subitemconfig {/testbench/du/counter_g(0)/q(0) {-height 16 -radix hexadecimal} /testbench/du/counter_g(0)/q(1) {-height 16 -radix hexadecimal} /testbench/du/counter_g(0)/q(2) {-height 16 -radix hexadecimal} /testbench/du/counter_g(0)/q(3) {-height 16 -radix hexadecimal} /testbench/du/counter_g(0)/q(4) {-height 16 -radix hexadecimal} /testbench/du/counter_g(0)/q(5) {-height 16 -radix hexadecimal} /testbench/du/counter_g(0)/q(6) {-height 16 -radix hexadecimal} /testbench/du/counter_g(0)/q(7) {-height 16 -radix hexadecimal} /testbench/du/counter_g(0)/q(8) {-height 16 -radix hexadecimal} /testbench/du/counter_g(0)/q(9) {-height 16 -radix hexadecimal} /testbench/du/counter_g(0)/q(10) {-height 16 -radix hexadecimal} /testbench/du/counter_g(0)/q(11) {-height 16 -radix hexadecimal}} /testbench/du/counter_g(0)/q
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du/q0(1)
add wave -noupdate -divider {New Divider}
add wave -noupdate -expand /testbench/du/q0
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {22498 ps} 1} {{Cursor 2} {189805163 ps} 0}
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
WaveRestoreZoom {189753379 ps} {189856947 ps}
