onerror {resume}
quietly virtual signal -install /testbench { /testbench/dq(15 downto 0)} dq16
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider testbench
add wave -noupdate /testbench/ba
add wave -noupdate /testbench/cs_n
add wave -noupdate /testbench/cke
add wave -noupdate -radix hexadecimal /testbench/addr
add wave -noupdate /testbench/ras_n
add wave -noupdate /testbench/cas_n
add wave -noupdate /testbench/we_n
add wave -noupdate -radix hexadecimal -childformat {{/testbench/dq16(15) -radix hexadecimal} {/testbench/dq16(14) -radix hexadecimal} {/testbench/dq16(13) -radix hexadecimal} {/testbench/dq16(12) -radix hexadecimal} {/testbench/dq16(11) -radix hexadecimal} {/testbench/dq16(10) -radix hexadecimal} {/testbench/dq16(9) -radix hexadecimal} {/testbench/dq16(8) -radix hexadecimal} {/testbench/dq16(7) -radix hexadecimal} {/testbench/dq16(6) -radix hexadecimal} {/testbench/dq16(5) -radix hexadecimal} {/testbench/dq16(4) -radix hexadecimal} {/testbench/dq16(3) -radix hexadecimal} {/testbench/dq16(2) -radix hexadecimal} {/testbench/dq16(1) -radix hexadecimal} {/testbench/dq16(0) -radix hexadecimal}} -subitemconfig {/testbench/dq(15) {-radix hexadecimal} /testbench/dq(14) {-radix hexadecimal} /testbench/dq(13) {-radix hexadecimal} /testbench/dq(12) {-radix hexadecimal} /testbench/dq(11) {-radix hexadecimal} /testbench/dq(10) {-radix hexadecimal} /testbench/dq(9) {-radix hexadecimal} /testbench/dq(8) {-radix hexadecimal} /testbench/dq(7) {-radix hexadecimal} /testbench/dq(6) {-radix hexadecimal} /testbench/dq(5) {-radix hexadecimal} /testbench/dq(4) {-radix hexadecimal} /testbench/dq(3) {-radix hexadecimal} /testbench/dq(2) {-radix hexadecimal} /testbench/dq(1) {-radix hexadecimal} /testbench/dq(0) {-radix hexadecimal}} /testbench/dq16
add wave -noupdate /testbench/dqs(1)
add wave -noupdate /testbench/dqs(0)
add wave -noupdate -divider {New Divider}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {4429948 ps} 0} {{Cursor 2} {21184786 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 174
configure wave -valuecolwidth 103
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
WaveRestoreZoom {4404019 ps} {4449813 ps}
