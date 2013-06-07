onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /testbench/clk
add wave -noupdate -format Literal /testbench/cntr
add wave -noupdate -format Logic /testbench/ri
add wave -noupdate -format Literal -radix decimal /testbench/du/twd_b
add wave -noupdate -format Literal -radix decimal /testbench/du/twd_a
add wave -noupdate -format Literal -radix decimal /testbench/du/twd_ab
add wave -noupdate -format Literal -radix decimal /testbench/du/twd_opb
add wave -noupdate -format Literal -radix decimal /testbench/du/twd_cof
add wave -noupdate -format Literal -radix decimal /testbench/du/twd_opa
add wave -noupdate -format Literal -radix decimal /testbench/du/twd_mty
add wave -noupdate -format Logic /testbench/twd_j
add wave -noupdate -format Logic /testbench/du/twd_mux_j
add wave -noupdate -format Literal -radix decimal /testbench/twd_xo
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {25 ns} 0}
configure wave -namecolwidth 150
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
WaveRestoreZoom {0 ns} {126 ns}
