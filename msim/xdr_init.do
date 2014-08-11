onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/xdr_clk
add wave -noupdate /testbench/xdr_wait_clk
add wave -noupdate /testbench/xdr_rst
add wave -noupdate /testbench/xdr_init_rdy
add wave -noupdate /testbench/xdr_ras
add wave -noupdate /testbench/xdr_cas
add wave -noupdate /testbench/xdr_we
add wave -noupdate /testbench/du/xdr_init_a
add wave -noupdate /testbench/du/xdr_init_b
add wave -noupdate /testbench/du/xdr_init_pc
add wave -noupdate -radix hexadecimal /testbench/du/dst
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {25000 ps} 0}
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
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {157500 ps}
