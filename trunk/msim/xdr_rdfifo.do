onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/sys_clk
add wave -noupdate /testbench/sys_clk2
add wave -noupdate /testbench/sys_rdy
add wave -noupdate /testbench/sys_rea
add wave -noupdate -radix hexadecimal /testbench/xdr_dqi
add wave -noupdate /testbench/xdr_win_dqs
add wave -noupdate -radix hexadecimal /testbench/sys_do
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
