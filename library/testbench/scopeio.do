onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/scopeio_e/input_clk
add wave -noupdate /testbench/scopeio_e/input_ena
add wave -noupdate -radix hexadecimal -childformat {{/testbench/input_addr(13) -radix hexadecimal} {/testbench/input_addr(12) -radix hexadecimal} {/testbench/input_addr(11) -radix hexadecimal} {/testbench/input_addr(10) -radix hexadecimal} {/testbench/input_addr(9) -radix hexadecimal} {/testbench/input_addr(8) -radix hexadecimal} {/testbench/input_addr(7) -radix hexadecimal} {/testbench/input_addr(6) -radix hexadecimal} {/testbench/input_addr(5) -radix hexadecimal} {/testbench/input_addr(4) -radix hexadecimal} {/testbench/input_addr(3) -radix hexadecimal} {/testbench/input_addr(2) -radix hexadecimal} {/testbench/input_addr(1) -radix hexadecimal} {/testbench/input_addr(0) -radix hexadecimal}} -subitemconfig {/testbench/input_addr(13) {-height 29 -radix hexadecimal} /testbench/input_addr(12) {-height 29 -radix hexadecimal} /testbench/input_addr(11) {-height 29 -radix hexadecimal} /testbench/input_addr(10) {-height 29 -radix hexadecimal} /testbench/input_addr(9) {-height 29 -radix hexadecimal} /testbench/input_addr(8) {-height 29 -radix hexadecimal} /testbench/input_addr(7) {-height 29 -radix hexadecimal} /testbench/input_addr(6) {-height 29 -radix hexadecimal} /testbench/input_addr(5) {-height 29 -radix hexadecimal} /testbench/input_addr(4) {-height 29 -radix hexadecimal} /testbench/input_addr(3) {-height 29 -radix hexadecimal} /testbench/input_addr(2) {-height 29 -radix hexadecimal} /testbench/input_addr(1) {-height 29 -radix hexadecimal} /testbench/input_addr(0) {-height 29 -radix hexadecimal}} /testbench/input_addr
add wave -noupdate -radix decimal /testbench/sample
add wave -noupdate -divider {New Divider}
add wave -noupdate -clampanalog 1 -format Analog-Step -height 124 -max 127.00000000000001 -min -63.0 -radix decimal /testbench/scopeio_e/input_data
add wave -noupdate -divider amp
add wave -noupdate /testbench/scopeio_e/amp_b/amp_g(0)/amp_e/input_clk
add wave -noupdate -radix decimal -childformat {{/testbench/scopeio_e/amp_b/amp_g(0)/amp_e/input_sample(0) -radix decimal} {/testbench/scopeio_e/amp_b/amp_g(0)/amp_e/input_sample(1) -radix decimal} {/testbench/scopeio_e/amp_b/amp_g(0)/amp_e/input_sample(2) -radix decimal} {/testbench/scopeio_e/amp_b/amp_g(0)/amp_e/input_sample(3) -radix decimal} {/testbench/scopeio_e/amp_b/amp_g(0)/amp_e/input_sample(4) -radix decimal} {/testbench/scopeio_e/amp_b/amp_g(0)/amp_e/input_sample(5) -radix decimal} {/testbench/scopeio_e/amp_b/amp_g(0)/amp_e/input_sample(6) -radix decimal} {/testbench/scopeio_e/amp_b/amp_g(0)/amp_e/input_sample(7) -radix decimal} {/testbench/scopeio_e/amp_b/amp_g(0)/amp_e/input_sample(8) -radix decimal} {/testbench/scopeio_e/amp_b/amp_g(0)/amp_e/input_sample(9) -radix decimal} {/testbench/scopeio_e/amp_b/amp_g(0)/amp_e/input_sample(10) -radix decimal} {/testbench/scopeio_e/amp_b/amp_g(0)/amp_e/input_sample(11) -radix decimal} {/testbench/scopeio_e/amp_b/amp_g(0)/amp_e/input_sample(12) -radix decimal} {/testbench/scopeio_e/amp_b/amp_g(0)/amp_e/input_sample(13) -radix decimal}} -subitemconfig {/testbench/scopeio_e/amp_b/amp_g(0)/amp_e/input_sample(0) {-height 29 -radix decimal} /testbench/scopeio_e/amp_b/amp_g(0)/amp_e/input_sample(1) {-height 29 -radix decimal} /testbench/scopeio_e/amp_b/amp_g(0)/amp_e/input_sample(2) {-height 29 -radix decimal} /testbench/scopeio_e/amp_b/amp_g(0)/amp_e/input_sample(3) {-height 29 -radix decimal} /testbench/scopeio_e/amp_b/amp_g(0)/amp_e/input_sample(4) {-height 29 -radix decimal} /testbench/scopeio_e/amp_b/amp_g(0)/amp_e/input_sample(5) {-height 29 -radix decimal} /testbench/scopeio_e/amp_b/amp_g(0)/amp_e/input_sample(6) {-height 29 -radix decimal} /testbench/scopeio_e/amp_b/amp_g(0)/amp_e/input_sample(7) {-height 29 -radix decimal} /testbench/scopeio_e/amp_b/amp_g(0)/amp_e/input_sample(8) {-height 29 -radix decimal} /testbench/scopeio_e/amp_b/amp_g(0)/amp_e/input_sample(9) {-height 29 -radix decimal} /testbench/scopeio_e/amp_b/amp_g(0)/amp_e/input_sample(10) {-height 29 -radix decimal} /testbench/scopeio_e/amp_b/amp_g(0)/amp_e/input_sample(11) {-height 29 -radix decimal} /testbench/scopeio_e/amp_b/amp_g(0)/amp_e/input_sample(12) {-height 29 -radix decimal} /testbench/scopeio_e/amp_b/amp_g(0)/amp_e/input_sample(13) {-height 29 -radix decimal}} /testbench/scopeio_e/amp_b/amp_g(0)/amp_e/input_sample
add wave -noupdate /testbench/scopeio_e/amp_b/amp_g(0)/amp_e/input_dv
add wave -noupdate /testbench/scopeio_e/amp_b/amp_g(0)/amp_e/output_dv
add wave -noupdate -radix decimal /testbench/scopeio_e/amp_b/amp_g(0)/amp_e/output_sample
add wave -noupdate -radix decimal /testbench/scopeio_e/amp_b/amp_g(0)/amp_e/b
add wave -noupdate -radix decimal /testbench/scopeio_e/amp_b/amp_g(0)/amp_e/g
add wave -noupdate -radix hexadecimal /testbench/scopeio_e/amp_b/amp_g(0)/amp_e/p
add wave -noupdate /testbench/scopeio_e/scopeio_video_e/layout_b/mainbox_b/scopeio_segment_e/grid_on
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {13107641 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 305
configure wave -valuecolwidth 207
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
WaveRestoreZoom {13399554 ns} {13401618 ns}
