onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/scopeio_e/input_clk
add wave -noupdate /testbench/scopeio_e/input_ena
add wave -noupdate -radix hexadecimal /testbench/input_addr
add wave -noupdate /testbench/sample
add wave -noupdate -divider {New Divider}
add wave -noupdate -clampanalog 1 -format Analog-Step -height 124 -max 127.00000000000001 -min -63.0 -radix decimal /testbench/scopeio_e/input_data
add wave -noupdate -divider scopeio_amp
add wave -noupdate /testbench/scopeio_e/amp_b/amp_g(0)/amp_e/input_clk
add wave -noupdate /testbench/scopeio_e/amp_b/amp_g(0)/amp_e/input_ena
add wave -noupdate -radix decimal -childformat {{/testbench/scopeio_e/amp_b/amp_g(0)/amp_e/input_sample(0) -radix decimal} {/testbench/scopeio_e/amp_b/amp_g(0)/amp_e/input_sample(1) -radix decimal} {/testbench/scopeio_e/amp_b/amp_g(0)/amp_e/input_sample(2) -radix decimal} {/testbench/scopeio_e/amp_b/amp_g(0)/amp_e/input_sample(3) -radix decimal} {/testbench/scopeio_e/amp_b/amp_g(0)/amp_e/input_sample(4) -radix decimal} {/testbench/scopeio_e/amp_b/amp_g(0)/amp_e/input_sample(5) -radix decimal} {/testbench/scopeio_e/amp_b/amp_g(0)/amp_e/input_sample(6) -radix decimal} {/testbench/scopeio_e/amp_b/amp_g(0)/amp_e/input_sample(7) -radix decimal} {/testbench/scopeio_e/amp_b/amp_g(0)/amp_e/input_sample(8) -radix decimal} {/testbench/scopeio_e/amp_b/amp_g(0)/amp_e/input_sample(9) -radix decimal} {/testbench/scopeio_e/amp_b/amp_g(0)/amp_e/input_sample(10) -radix decimal} {/testbench/scopeio_e/amp_b/amp_g(0)/amp_e/input_sample(11) -radix decimal} {/testbench/scopeio_e/amp_b/amp_g(0)/amp_e/input_sample(12) -radix decimal} {/testbench/scopeio_e/amp_b/amp_g(0)/amp_e/input_sample(13) -radix decimal}} -subitemconfig {/testbench/scopeio_e/amp_b/amp_g(0)/amp_e/input_sample(0) {-radix decimal} /testbench/scopeio_e/amp_b/amp_g(0)/amp_e/input_sample(1) {-radix decimal} /testbench/scopeio_e/amp_b/amp_g(0)/amp_e/input_sample(2) {-radix decimal} /testbench/scopeio_e/amp_b/amp_g(0)/amp_e/input_sample(3) {-radix decimal} /testbench/scopeio_e/amp_b/amp_g(0)/amp_e/input_sample(4) {-radix decimal} /testbench/scopeio_e/amp_b/amp_g(0)/amp_e/input_sample(5) {-radix decimal} /testbench/scopeio_e/amp_b/amp_g(0)/amp_e/input_sample(6) {-radix decimal} /testbench/scopeio_e/amp_b/amp_g(0)/amp_e/input_sample(7) {-radix decimal} /testbench/scopeio_e/amp_b/amp_g(0)/amp_e/input_sample(8) {-radix decimal} /testbench/scopeio_e/amp_b/amp_g(0)/amp_e/input_sample(9) {-radix decimal} /testbench/scopeio_e/amp_b/amp_g(0)/amp_e/input_sample(10) {-radix decimal} /testbench/scopeio_e/amp_b/amp_g(0)/amp_e/input_sample(11) {-radix decimal} /testbench/scopeio_e/amp_b/amp_g(0)/amp_e/input_sample(12) {-radix decimal} /testbench/scopeio_e/amp_b/amp_g(0)/amp_e/input_sample(13) {-radix decimal}} /testbench/scopeio_e/amp_b/amp_g(0)/amp_e/input_sample
add wave -noupdate -radix hexadecimal /testbench/scopeio_e/amp_b/amp_g(0)/amp_e/b
add wave -noupdate -radix decimal /testbench/scopeio_e/amp_b/amp_g(0)/amp_e/g
add wave -noupdate -radix hexadecimal /testbench/scopeio_e/amp_b/amp_g(0)/amp_e/p
add wave -noupdate -radix decimal /testbench/scopeio_e/amp_b/amp_g(0)/amp_e/output_sample
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {4423003 ns} 0} {{Cursor 2} {29248 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 174
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
WaveRestoreZoom {4408453 ns} {4441267 ns}
