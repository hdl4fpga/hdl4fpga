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
add wave -noupdate /testbench/ml509_e/scope_e/ddr_e/wrfifo_i/xdr_fifo_g(0)/outbyte_i/ser_clk
add wave -noupdate /testbench/ml509_e/scope_e/ddr_e/wrfifo_i/xdr_fifo_g(0)/outbyte_i/ser_ena
add wave -noupdate /testbench/ml509_e/scope_e/ddr_e/xdr_wclks
add wave -noupdate /testbench/ml509_e/scope_e/ddr_e/data_phases
add wave -noupdate /testbench/ml509_e/scope_e/ddr_e/data_edges
add wave -noupdate -radix hexadecimal -childformat {{/testbench/ml509_e/ddrphy_e/byte_g(1)/ddrdqphy_i/sys_dqo(15) -radix hexadecimal} {/testbench/ml509_e/ddrphy_e/byte_g(1)/ddrdqphy_i/sys_dqo(14) -radix hexadecimal} {/testbench/ml509_e/ddrphy_e/byte_g(1)/ddrdqphy_i/sys_dqo(13) -radix hexadecimal} {/testbench/ml509_e/ddrphy_e/byte_g(1)/ddrdqphy_i/sys_dqo(12) -radix hexadecimal} {/testbench/ml509_e/ddrphy_e/byte_g(1)/ddrdqphy_i/sys_dqo(11) -radix hexadecimal} {/testbench/ml509_e/ddrphy_e/byte_g(1)/ddrdqphy_i/sys_dqo(10) -radix hexadecimal} {/testbench/ml509_e/ddrphy_e/byte_g(1)/ddrdqphy_i/sys_dqo(9) -radix hexadecimal} {/testbench/ml509_e/ddrphy_e/byte_g(1)/ddrdqphy_i/sys_dqo(8) -radix hexadecimal} {/testbench/ml509_e/ddrphy_e/byte_g(1)/ddrdqphy_i/sys_dqo(7) -radix hexadecimal} {/testbench/ml509_e/ddrphy_e/byte_g(1)/ddrdqphy_i/sys_dqo(6) -radix hexadecimal} {/testbench/ml509_e/ddrphy_e/byte_g(1)/ddrdqphy_i/sys_dqo(5) -radix hexadecimal} {/testbench/ml509_e/ddrphy_e/byte_g(1)/ddrdqphy_i/sys_dqo(4) -radix hexadecimal} {/testbench/ml509_e/ddrphy_e/byte_g(1)/ddrdqphy_i/sys_dqo(3) -radix hexadecimal} {/testbench/ml509_e/ddrphy_e/byte_g(1)/ddrdqphy_i/sys_dqo(2) -radix hexadecimal} {/testbench/ml509_e/ddrphy_e/byte_g(1)/ddrdqphy_i/sys_dqo(1) -radix hexadecimal} {/testbench/ml509_e/ddrphy_e/byte_g(1)/ddrdqphy_i/sys_dqo(0) -radix hexadecimal}} -subitemconfig {/testbench/ml509_e/ddrphy_e/byte_g(1)/ddrdqphy_i/sys_dqo(15) {-height 16 -radix hexadecimal} /testbench/ml509_e/ddrphy_e/byte_g(1)/ddrdqphy_i/sys_dqo(14) {-height 16 -radix hexadecimal} /testbench/ml509_e/ddrphy_e/byte_g(1)/ddrdqphy_i/sys_dqo(13) {-height 16 -radix hexadecimal} /testbench/ml509_e/ddrphy_e/byte_g(1)/ddrdqphy_i/sys_dqo(12) {-height 16 -radix hexadecimal} /testbench/ml509_e/ddrphy_e/byte_g(1)/ddrdqphy_i/sys_dqo(11) {-height 16 -radix hexadecimal} /testbench/ml509_e/ddrphy_e/byte_g(1)/ddrdqphy_i/sys_dqo(10) {-height 16 -radix hexadecimal} /testbench/ml509_e/ddrphy_e/byte_g(1)/ddrdqphy_i/sys_dqo(9) {-height 16 -radix hexadecimal} /testbench/ml509_e/ddrphy_e/byte_g(1)/ddrdqphy_i/sys_dqo(8) {-height 16 -radix hexadecimal} /testbench/ml509_e/ddrphy_e/byte_g(1)/ddrdqphy_i/sys_dqo(7) {-height 16 -radix hexadecimal} /testbench/ml509_e/ddrphy_e/byte_g(1)/ddrdqphy_i/sys_dqo(6) {-height 16 -radix hexadecimal} /testbench/ml509_e/ddrphy_e/byte_g(1)/ddrdqphy_i/sys_dqo(5) {-height 16 -radix hexadecimal} /testbench/ml509_e/ddrphy_e/byte_g(1)/ddrdqphy_i/sys_dqo(4) {-height 16 -radix hexadecimal} /testbench/ml509_e/ddrphy_e/byte_g(1)/ddrdqphy_i/sys_dqo(3) {-height 16 -radix hexadecimal} /testbench/ml509_e/ddrphy_e/byte_g(1)/ddrdqphy_i/sys_dqo(2) {-height 16 -radix hexadecimal} /testbench/ml509_e/ddrphy_e/byte_g(1)/ddrdqphy_i/sys_dqo(1) {-height 16 -radix hexadecimal} /testbench/ml509_e/ddrphy_e/byte_g(1)/ddrdqphy_i/sys_dqo(0) {-height 16 -radix hexadecimal}} /testbench/ml509_e/ddrphy_e/byte_g(1)/ddrdqphy_i/sys_dqo
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {4425921 ps} 0} {{Cursor 2} {4429142 ps} 0}
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
WaveRestoreZoom {4412986 ps} {4458780 ps}
