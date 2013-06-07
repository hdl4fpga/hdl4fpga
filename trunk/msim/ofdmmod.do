onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic -radix binary /testbench/clk
add wave -noupdate -format Analog-Step -height 512 -max 127.0 -min -127.0 /testbench/du1/du/xi
add wave -noupdate -format Analog-Step -height 512 -max 126.0 -min -128.0 -radix decimal /testbench/xo
add wave -noupdate -format Analog-Step -height 256 -max 40000.0 -min -10000.0 -radix decimal /testbench/crln
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {20980 ns} 0}
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
WaveRestoreZoom {16797 ns} {46621 ns}
