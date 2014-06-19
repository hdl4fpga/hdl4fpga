onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/sys_clk
add wave -noupdate /testbench/sys_rea
add wave -noupdate -radix hexadecimal /testbench/xdr_dqi
add wave -noupdate /testbench/xdr_rd_fifo_e/xdr_dlyd_dqs(0)
add wave -noupdate -radix hexadecimal /testbench/xdr_dqi
add wave -noupdate /testbench/xdr_rd_fifo_e/xdr_dlyd_dqs(1)
add wave -noupdate /testbench/xdr_rd_fifo_e/axdr_o_q
add wave -noupdate /testbench/xdr_rd_fifo_e/xdr_fifo(0)/phase_g(0)/axdr_i_q
add wave -noupdate /testbench/xdr_rd_fifo_e/xdr_fifo(1)/phase_g(0)/axdr_i_q
add wave -noupdate /testbench/xdr_rd_fifo_e/xdr_fifo(0)/phase_g(0)/we
add wave -noupdate /testbench/xdr_rd_fifo_e/xdr_fifo(1)/phase_g(0)/we
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {8 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 216
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
WaveRestoreZoom {18 ns} {105 ns}
