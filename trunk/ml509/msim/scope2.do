onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/rst
add wave -noupdate /testbench/clk
add wave -noupdate -radix hexadecimal /testbench/dq
add wave -noupdate /testbench/dqs
add wave -noupdate /testbench/dqs_n
add wave -noupdate /testbench/addr
add wave -noupdate /testbench/ba
add wave -noupdate /testbench/clk_p
add wave -noupdate /testbench/clk_n
add wave -noupdate /testbench/ml509_e/scope_e_ddr_e_ddr_init_cke
add wave -noupdate -expand /testbench/cke
add wave -noupdate /testbench/cs_n
add wave -noupdate /testbench/ras_n
add wave -noupdate /testbench/cas_n
add wave -noupdate /testbench/we_n
add wave -noupdate /testbench/dm
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {200761173 ps} 0}
quietly wave cursor active 1
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
configure wave -timelineunits ps
update
WaveRestoreZoom {200734256 ps} {200778113 ps}
