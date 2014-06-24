onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/xdr_wrfifo_e/sys_clk
add wave -noupdate /testbench/xdr_wrfifo_e/sys_req
add wave -noupdate /testbench/xdr_wrfifo_e/sys_dmi
add wave -noupdate -radix hexadecimal /testbench/xdr_wrfifo_e/sys_dqi
add wave -noupdate /testbench/xdr_wrfifo_e/xdr_clks
add wave -noupdate /testbench/xdr_wrfifo_e/xdr_enas
add wave -noupdate /testbench/xdr_wrfifo_e/xdr_dmo
add wave -noupdate /testbench/xdr_wrfifo_e/xdr_dqo
add wave -noupdate -radix hexadecimal -childformat {{/testbench/xdr_wrfifo_e/di(7) -radix hexadecimal} {/testbench/xdr_wrfifo_e/di(6) -radix hexadecimal} {/testbench/xdr_wrfifo_e/di(5) -radix hexadecimal} {/testbench/xdr_wrfifo_e/di(4) -radix hexadecimal} {/testbench/xdr_wrfifo_e/di(3) -radix hexadecimal} {/testbench/xdr_wrfifo_e/di(2) -radix hexadecimal} {/testbench/xdr_wrfifo_e/di(1) -radix hexadecimal} {/testbench/xdr_wrfifo_e/di(0) -radix hexadecimal}} -subitemconfig {/testbench/xdr_wrfifo_e/di(7) {-height 16 -radix hexadecimal} /testbench/xdr_wrfifo_e/di(6) {-height 16 -radix hexadecimal} /testbench/xdr_wrfifo_e/di(5) {-height 16 -radix hexadecimal} /testbench/xdr_wrfifo_e/di(4) {-height 16 -radix hexadecimal} /testbench/xdr_wrfifo_e/di(3) {-height 16 -radix hexadecimal} /testbench/xdr_wrfifo_e/di(2) {-height 16 -radix hexadecimal} /testbench/xdr_wrfifo_e/di(1) {-height 16 -radix hexadecimal} /testbench/xdr_wrfifo_e/di(0) {-height 16 -radix hexadecimal}} /testbench/xdr_wrfifo_e/di
add wave -noupdate -radix hexadecimal /testbench/xdr_wrfifo_e/do
add wave -noupdate -radix hexadecimal /testbench/xdr_wrfifo_e/xdr_fifo_g(1)/fifo_di
add wave -noupdate -radix hexadecimal /testbench/xdr_wrfifo_e/xdr_fifo_g(1)/fifo_do
add wave -noupdate -radix hexadecimal -childformat {{/testbench/xdr_wrfifo_e/xdr_fifo_g(1)/dqi(3) -radix hexadecimal} {/testbench/xdr_wrfifo_e/xdr_fifo_g(1)/dqi(2) -radix hexadecimal} {/testbench/xdr_wrfifo_e/xdr_fifo_g(1)/dqi(1) -radix hexadecimal} {/testbench/xdr_wrfifo_e/xdr_fifo_g(1)/dqi(0) -radix hexadecimal}} -subitemconfig {/testbench/xdr_wrfifo_e/xdr_fifo_g(1)/dqi(3) {-height 16 -radix hexadecimal} /testbench/xdr_wrfifo_e/xdr_fifo_g(1)/dqi(2) {-height 16 -radix hexadecimal} /testbench/xdr_wrfifo_e/xdr_fifo_g(1)/dqi(1) {-height 16 -radix hexadecimal} /testbench/xdr_wrfifo_e/xdr_fifo_g(1)/dqi(0) {-height 16 -radix hexadecimal}} /testbench/xdr_wrfifo_e/xdr_fifo_g(1)/dqi
add wave -noupdate -radix hexadecimal /testbench/xdr_wrfifo_e/xdr_fifo_g(0)/outbyte_i/do
add wave -noupdate -radix hexadecimal /testbench/xdr_wrfifo_e/xdr_fifo_g(0)/outbyte_i/xdr_fifo_g(0)/dpo
add wave -noupdate -radix hexadecimal /testbench/xdr_wrfifo_e/xdr_fifo_g(1)/outbyte_i/xdr_fifo_g(0)/dpo
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
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
WaveRestoreZoom {360100 ps} {402100 ps}
