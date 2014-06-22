onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/sys_clk
add wave -noupdate /testbench/sys_req
add wave -noupdate -expand /testbench/xdr_wr_fifo_e/clks
add wave -noupdate -radix hexadecimal /testbench/sys_di
add wave -noupdate /testbench/xdr_enas
add wave -noupdate -radix hexadecimal -childformat {{/testbench/xdr_dqo(31) -radix hexadecimal} {/testbench/xdr_dqo(30) -radix hexadecimal} {/testbench/xdr_dqo(29) -radix hexadecimal} {/testbench/xdr_dqo(28) -radix hexadecimal} {/testbench/xdr_dqo(27) -radix hexadecimal} {/testbench/xdr_dqo(26) -radix hexadecimal} {/testbench/xdr_dqo(25) -radix hexadecimal} {/testbench/xdr_dqo(24) -radix hexadecimal} {/testbench/xdr_dqo(23) -radix hexadecimal} {/testbench/xdr_dqo(22) -radix hexadecimal} {/testbench/xdr_dqo(21) -radix hexadecimal} {/testbench/xdr_dqo(20) -radix hexadecimal} {/testbench/xdr_dqo(19) -radix hexadecimal} {/testbench/xdr_dqo(18) -radix hexadecimal} {/testbench/xdr_dqo(17) -radix hexadecimal} {/testbench/xdr_dqo(16) -radix hexadecimal} {/testbench/xdr_dqo(15) -radix hexadecimal} {/testbench/xdr_dqo(14) -radix hexadecimal} {/testbench/xdr_dqo(13) -radix hexadecimal} {/testbench/xdr_dqo(12) -radix hexadecimal} {/testbench/xdr_dqo(11) -radix hexadecimal} {/testbench/xdr_dqo(10) -radix hexadecimal} {/testbench/xdr_dqo(9) -radix hexadecimal} {/testbench/xdr_dqo(8) -radix hexadecimal} {/testbench/xdr_dqo(7) -radix hexadecimal} {/testbench/xdr_dqo(6) -radix hexadecimal} {/testbench/xdr_dqo(5) -radix hexadecimal} {/testbench/xdr_dqo(4) -radix hexadecimal} {/testbench/xdr_dqo(3) -radix hexadecimal} {/testbench/xdr_dqo(2) -radix hexadecimal} {/testbench/xdr_dqo(1) -radix hexadecimal} {/testbench/xdr_dqo(0) -radix hexadecimal}} -subitemconfig {/testbench/xdr_dqo(31) {-height 15 -radix hexadecimal} /testbench/xdr_dqo(30) {-height 15 -radix hexadecimal} /testbench/xdr_dqo(29) {-height 15 -radix hexadecimal} /testbench/xdr_dqo(28) {-height 15 -radix hexadecimal} /testbench/xdr_dqo(27) {-height 15 -radix hexadecimal} /testbench/xdr_dqo(26) {-height 15 -radix hexadecimal} /testbench/xdr_dqo(25) {-height 15 -radix hexadecimal} /testbench/xdr_dqo(24) {-height 15 -radix hexadecimal} /testbench/xdr_dqo(23) {-height 15 -radix hexadecimal} /testbench/xdr_dqo(22) {-height 15 -radix hexadecimal} /testbench/xdr_dqo(21) {-height 15 -radix hexadecimal} /testbench/xdr_dqo(20) {-height 15 -radix hexadecimal} /testbench/xdr_dqo(19) {-height 15 -radix hexadecimal} /testbench/xdr_dqo(18) {-height 15 -radix hexadecimal} /testbench/xdr_dqo(17) {-height 15 -radix hexadecimal} /testbench/xdr_dqo(16) {-height 15 -radix hexadecimal} /testbench/xdr_dqo(15) {-height 15 -radix hexadecimal} /testbench/xdr_dqo(14) {-height 15 -radix hexadecimal} /testbench/xdr_dqo(13) {-height 15 -radix hexadecimal} /testbench/xdr_dqo(12) {-height 15 -radix hexadecimal} /testbench/xdr_dqo(11) {-height 15 -radix hexadecimal} /testbench/xdr_dqo(10) {-height 15 -radix hexadecimal} /testbench/xdr_dqo(9) {-height 15 -radix hexadecimal} /testbench/xdr_dqo(8) {-height 15 -radix hexadecimal} /testbench/xdr_dqo(7) {-height 15 -radix hexadecimal} /testbench/xdr_dqo(6) {-height 15 -radix hexadecimal} /testbench/xdr_dqo(5) {-height 15 -radix hexadecimal} /testbench/xdr_dqo(4) {-height 15 -radix hexadecimal} /testbench/xdr_dqo(3) {-height 15 -radix hexadecimal} /testbench/xdr_dqo(2) {-height 15 -radix hexadecimal} /testbench/xdr_dqo(1) {-height 15 -radix hexadecimal} /testbench/xdr_dqo(0) {-height 15 -radix hexadecimal}} /testbench/xdr_dqo
add wave -noupdate -radix hexadecimal /testbench/xdr_wr_fifo_e/sys_axdr_q
add wave -noupdate -radix hexadecimal -childformat {{/testbench/xdr_wr_fifo_e/xdr_axdr_q(3) -radix hexadecimal} {/testbench/xdr_wr_fifo_e/xdr_axdr_q(2) -radix hexadecimal} {/testbench/xdr_wr_fifo_e/xdr_axdr_q(1) -radix hexadecimal} {/testbench/xdr_wr_fifo_e/xdr_axdr_q(0) -radix hexadecimal}} -subitemconfig {/testbench/xdr_wr_fifo_e/xdr_axdr_q(3) {-height 15 -radix hexadecimal} /testbench/xdr_wr_fifo_e/xdr_axdr_q(2) {-height 15 -radix hexadecimal} /testbench/xdr_wr_fifo_e/xdr_axdr_q(1) {-height 15 -radix hexadecimal} /testbench/xdr_wr_fifo_e/xdr_axdr_q(0) {-height 15 -radix hexadecimal}} /testbench/xdr_wr_fifo_e/xdr_axdr_q
add wave -noupdate -radix hexadecimal -childformat {{/testbench/xdr_wr_fifo_e/di(3) -radix hexadecimal} {/testbench/xdr_wr_fifo_e/di(2) -radix hexadecimal} {/testbench/xdr_wr_fifo_e/di(1) -radix hexadecimal} {/testbench/xdr_wr_fifo_e/di(0) -radix hexadecimal}} -subitemconfig {/testbench/xdr_wr_fifo_e/di(3) {-height 15 -radix hexadecimal} /testbench/xdr_wr_fifo_e/di(2) {-height 15 -radix hexadecimal} /testbench/xdr_wr_fifo_e/di(1) {-height 15 -radix hexadecimal} /testbench/xdr_wr_fifo_e/di(0) {-height 15 -radix hexadecimal}} /testbench/xdr_wr_fifo_e/di
add wave -noupdate -radix hexadecimal -childformat {{/testbench/xdr_wr_fifo_e/do(3) -radix hexadecimal} {/testbench/xdr_wr_fifo_e/do(2) -radix hexadecimal} {/testbench/xdr_wr_fifo_e/do(1) -radix hexadecimal} {/testbench/xdr_wr_fifo_e/do(0) -radix hexadecimal}} -expand -subitemconfig {/testbench/xdr_wr_fifo_e/do(3) {-radix hexadecimal} /testbench/xdr_wr_fifo_e/do(2) {-radix hexadecimal} /testbench/xdr_wr_fifo_e/do(1) {-radix hexadecimal} /testbench/xdr_wr_fifo_e/do(0) {-radix hexadecimal}} /testbench/xdr_wr_fifo_e/do
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {12817 ps} 0}
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
WaveRestoreZoom {0 ps} {546672 ps}
