onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /testbench/clk
add wave -noupdate -format Logic /testbench/ri
add wave -noupdate -format Literal -radix decimal /testbench/twd_xi
add wave -noupdate -format Literal -radix decimal /testbench/twd_xo
add wave -noupdate -format Literal -radix decimal /testbench/du/s
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Literal -radix decimal /testbench/du/twd_b
add wave -noupdate -format Literal -radix decimal /testbench/du/twd_a
add wave -noupdate -format Literal -radix decimal /testbench/du/twd_c
add wave -noupdate -format Literal -radix decimal /testbench/du/twd_d
add wave -noupdate -format Literal -radix decimal /testbench/du/twd_ab
add wave -noupdate -format Literal -radix decimal /testbench/du/mltp1
add wave -noupdate -format Literal -radix decimal /testbench/du/twd_acd
add wave -noupdate -format Literal -radix decimal /testbench/du/twd_abc
add wave -noupdate -format Literal -radix decimal /testbench/du/mltp2
add wave -noupdate -format Literal -radix decimal /testbench/du/twd_abcd
add wave -noupdate -format Literal -radix decimal /testbench/du/twd_opa(0)
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Literal -radix unsigned /testbench/du/twd_n
add wave -noupdate -format Logic /testbench/du/twd_ctrl(6).ri
add wave -noupdate -format Literal -radix decimal /testbench/du/twd_ctrl(6).s
add wave -noupdate -format Literal -radix decimal /testbench/du/twd_swap
add wave -noupdate -format Logic /testbench/du/ne
add wave -noupdate -format Logic /testbench/du/ne1
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {120 ns} 0}
configure wave -namecolwidth 207
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
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
WaveRestoreZoom {0 ns} {416 ns}
