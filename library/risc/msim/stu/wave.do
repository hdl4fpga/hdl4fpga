onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /testbench/a0s
add wave -noupdate -format Logic /testbench/a1s
add wave -noupdate -format Literal -expand /testbench/szs
add wave -noupdate -format Literal -radix hexadecimal /testbench/dins
add wave -noupdate -format Literal -radix hexadecimal /testbench/douts
add wave -noupdate -format Literal -expand /testbench/memes
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
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
update
WaveRestoreZoom {0 ns} {126 ns}
