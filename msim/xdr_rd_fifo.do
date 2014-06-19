onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/sys_clk
add wave -noupdate /testbench/sys_clk2
add wave -noupdate /testbench/sys_rdy
add wave -noupdate /testbench/sys_rea
add wave -noupdate -radix hexadecimal /testbench/xdr_dqi
add wave -noupdate /testbench/xdr_rd_fifo_e/xdr_dlyd_dqs(0)
add wave -noupdate -radix hexadecimal /testbench/xdr_dqi
add wave -noupdate /testbench/xdr_rd_fifo_e/xdr_dlyd_dqs(1)
add wave -noupdate -radix hexadecimal /testbench/xdr_rd_fifo_e/axdr_o_q
add wave -noupdate -radix hexadecimal /testbench/xdr_rd_fifo_e/xdr_fifo(0)/phase_g(0)/axdr_i_q
add wave -noupdate -radix hexadecimal /testbench/xdr_rd_fifo_e/xdr_fifo(0)/phase_g(1)/axdr_i_q
add wave -noupdate -radix hexadecimal /testbench/xdr_rd_fifo_e/xdr_fifo(1)/phase_g(0)/axdr_i_q
add wave -noupdate -radix hexadecimal /testbench/xdr_rd_fifo_e/xdr_fifo(1)/phase_g(1)/axdr_i_q
add wave -noupdate /testbench/xdr_win_dqs
add wave -noupdate /testbench/xdr_rd_fifo_e/axdr_we
add wave -noupdate -radix hexadecimal /testbench/sys_do
add wave -noupdate -radix hexadecimal -childformat {{/testbench/xdr_rd_fifo_e/xdr_fifo_do(15) -radix hexadecimal} {/testbench/xdr_rd_fifo_e/xdr_fifo_do(14) -radix hexadecimal} {/testbench/xdr_rd_fifo_e/xdr_fifo_do(13) -radix hexadecimal} {/testbench/xdr_rd_fifo_e/xdr_fifo_do(12) -radix hexadecimal} {/testbench/xdr_rd_fifo_e/xdr_fifo_do(11) -radix hexadecimal} {/testbench/xdr_rd_fifo_e/xdr_fifo_do(10) -radix hexadecimal} {/testbench/xdr_rd_fifo_e/xdr_fifo_do(9) -radix hexadecimal} {/testbench/xdr_rd_fifo_e/xdr_fifo_do(8) -radix hexadecimal} {/testbench/xdr_rd_fifo_e/xdr_fifo_do(7) -radix hexadecimal} {/testbench/xdr_rd_fifo_e/xdr_fifo_do(6) -radix hexadecimal} {/testbench/xdr_rd_fifo_e/xdr_fifo_do(5) -radix hexadecimal} {/testbench/xdr_rd_fifo_e/xdr_fifo_do(4) -radix hexadecimal} {/testbench/xdr_rd_fifo_e/xdr_fifo_do(3) -radix hexadecimal} {/testbench/xdr_rd_fifo_e/xdr_fifo_do(2) -radix hexadecimal} {/testbench/xdr_rd_fifo_e/xdr_fifo_do(1) -radix hexadecimal} {/testbench/xdr_rd_fifo_e/xdr_fifo_do(0) -radix hexadecimal}} -expand -subitemconfig {/testbench/xdr_rd_fifo_e/xdr_fifo_do(15) {-height 16 -radix hexadecimal} /testbench/xdr_rd_fifo_e/xdr_fifo_do(14) {-height 16 -radix hexadecimal} /testbench/xdr_rd_fifo_e/xdr_fifo_do(13) {-height 16 -radix hexadecimal} /testbench/xdr_rd_fifo_e/xdr_fifo_do(12) {-height 16 -radix hexadecimal} /testbench/xdr_rd_fifo_e/xdr_fifo_do(11) {-height 16 -radix hexadecimal} /testbench/xdr_rd_fifo_e/xdr_fifo_do(10) {-height 16 -radix hexadecimal} /testbench/xdr_rd_fifo_e/xdr_fifo_do(9) {-height 16 -radix hexadecimal} /testbench/xdr_rd_fifo_e/xdr_fifo_do(8) {-height 16 -radix hexadecimal} /testbench/xdr_rd_fifo_e/xdr_fifo_do(7) {-height 16 -radix hexadecimal} /testbench/xdr_rd_fifo_e/xdr_fifo_do(6) {-height 16 -radix hexadecimal} /testbench/xdr_rd_fifo_e/xdr_fifo_do(5) {-height 16 -radix hexadecimal} /testbench/xdr_rd_fifo_e/xdr_fifo_do(4) {-height 16 -radix hexadecimal} /testbench/xdr_rd_fifo_e/xdr_fifo_do(3) {-height 16 -radix hexadecimal} /testbench/xdr_rd_fifo_e/xdr_fifo_do(2) {-height 16 -radix hexadecimal} /testbench/xdr_rd_fifo_e/xdr_fifo_do(1) {-height 16 -radix hexadecimal} /testbench/xdr_rd_fifo_e/xdr_fifo_do(0) {-height 16 -radix hexadecimal}} /testbench/xdr_rd_fifo_e/xdr_fifo_do
add wave -noupdate -radix hexadecimal -childformat {{/testbench/xdr_rd_fifo_e/xdr_fifo(0)/phase_g(1)/ram_b/rd_slice(1) -radix hexadecimal} {/testbench/xdr_rd_fifo_e/xdr_fifo(0)/phase_g(1)/ram_b/rd_slice(0) -radix hexadecimal}} -subitemconfig {/testbench/xdr_rd_fifo_e/xdr_fifo(0)/phase_g(1)/ram_b/rd_slice(1) {-height 16 -radix hexadecimal} /testbench/xdr_rd_fifo_e/xdr_fifo(0)/phase_g(1)/ram_b/rd_slice(0) {-height 16 -radix hexadecimal}} /testbench/xdr_rd_fifo_e/xdr_fifo(0)/phase_g(1)/ram_b/rd_slice
add wave -noupdate /testbench/xdr_rd_fifo_e/xdr_fifo(0)/phase_g(1)/ram_b/do
add wave -noupdate /testbench/xdr_rd_fifo_e/xdr_fifo(0)/ph_sel
add wave -noupdate /testbench/xdr_rd_fifo_e/axdr_i_set
add wave -noupdate /testbench/xdr_win_dq
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {234906 ps} 0} {{Cursor 2} {40018 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 128
configure wave -valuecolwidth 69
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
WaveRestoreZoom {0 ps} {420 ns}
