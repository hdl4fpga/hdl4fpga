onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /testbench/rst
add wave -noupdate -radix hexadecimal /testbench/clk
add wave -noupdate -radix hexadecimal /testbench/bin_cnv
add wave -noupdate -radix hexadecimal /testbench/bin_dv
add wave -noupdate -radix hexadecimal /testbench/bin_di
add wave -noupdate -radix hexadecimal -childformat {{/testbench/bcd_do(0) -radix hexadecimal} {/testbench/bcd_do(1) -radix hexadecimal} {/testbench/bcd_do(2) -radix hexadecimal} {/testbench/bcd_do(3) -radix hexadecimal}} -subitemconfig {/testbench/bcd_do(0) {-height 16 -radix hexadecimal} /testbench/bcd_do(1) {-height 16 -radix hexadecimal} /testbench/bcd_do(2) {-height 16 -radix hexadecimal} /testbench/bcd_do(3) {-height 16 -radix hexadecimal}} /testbench/bcd_do
add wave -noupdate -radix hexadecimal /testbench/du/btod_ddi
add wave -noupdate -radix hexadecimal /testbench/du/btod_ddo
add wave -noupdate -radix hexadecimal /testbench/du/queue_do
add wave -noupdate -radix hexadecimal /testbench/du/queue_di
add wave -noupdate -radix hexadecimal /testbench/du/queue_addr
add wave -noupdate /testbench/du/head_updn
add wave -noupdate /testbench/du/head_ena
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {44 ns} 0}
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
WaveRestoreZoom {0 ns} {1 us}
