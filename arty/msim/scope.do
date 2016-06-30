onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/rst
add wave -noupdate /testbench/arty_e/gclk100
add wave -noupdate /testbench/ddr_clk_p
add wave -noupdate /testbench/cke
add wave -noupdate /testbench/rst_n
add wave -noupdate /testbench/cs_n
add wave -noupdate /testbench/ras_n
add wave -noupdate /testbench/cas_n
add wave -noupdate /testbench/we_n
add wave -noupdate /testbench/odt
add wave -noupdate -radix hexadecimal -childformat {{/testbench/ba(2) -radix hexadecimal} {/testbench/ba(1) -radix hexadecimal} {/testbench/ba(0) -radix hexadecimal}} -subitemconfig {/testbench/ba(2) {-height 16 -radix hexadecimal} /testbench/ba(1) {-height 16 -radix hexadecimal} /testbench/ba(0) {-height 16 -radix hexadecimal}} /testbench/ba
add wave -noupdate -radix hexadecimal /testbench/addr
add wave -noupdate /testbench/dqs_p
add wave -noupdate -radix hexadecimal /testbench/dq
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix hexadecimal /testbench/arty_e/scope_e/dataio_e/ddrs_bnka
add wave -noupdate -radix hexadecimal /testbench/arty_e/scope_e/dataio_e/ddrs_rowa
add wave -noupdate -radix hexadecimal /testbench/arty_e/scope_e/dataio_e/ddrs_cola
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {13433420 ps} 0} {{Cursor 2} {12857702 ps} 0}
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
WaveRestoreZoom {13402658 ps} {13464182 ps}
