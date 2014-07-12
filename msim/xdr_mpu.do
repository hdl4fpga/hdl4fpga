onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/rst
add wave -noupdate /testbench/clk
add wave -noupdate -radix decimal -childformat {{/testbench/du/lat_timer(0) -radix decimal} {/testbench/du/lat_timer(1) -radix decimal} {/testbench/du/lat_timer(2) -radix decimal} {/testbench/du/lat_timer(3) -radix decimal} {/testbench/du/lat_timer(4) -radix decimal}} -subitemconfig {/testbench/du/lat_timer(0) {-height 15 -radix decimal} /testbench/du/lat_timer(1) {-height 15 -radix decimal} /testbench/du/lat_timer(2) {-height 15 -radix decimal} /testbench/du/lat_timer(3) {-height 15 -radix decimal} /testbench/du/lat_timer(4) {-height 15 -radix decimal}} /testbench/du/lat_timer
add wave -noupdate /testbench/cmd
add wave -noupdate /testbench/rdy
add wave -noupdate /testbench/du/xdr_state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {28553 ps} 0}
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
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {105 ns}
