onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/du/ddr_acc_clk
add wave -noupdate /testbench/du/ddr_acc_clk90
add wave -noupdate /testbench/du/ddr_acc_drf
add wave -noupdate /testbench/du/ddr_acc_drr
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du/ddr_acc_dqs
add wave -noupdate -color Orange /testbench/du/ddr_acc_dqsz
add wave -noupdate -color Red /testbench/du/ddr_acc_dqz
add wave -noupdate /testbench/du/ddr_acc_dwr
add wave -noupdate /testbench/du/ddr_acc_dwf
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/ddr_ras
add wave -noupdate /testbench/ddr_cas
add wave -noupdate /testbench/ddr_we
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du/ddr_acc_rdy
add wave -noupdate /testbench/du/ddr_acc_req
add wave -noupdate -divider {New Divider}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {45092 ps} 0} {{Cursor 4} {35043 ps} 0} {{Cursor 5} {115049 ps} 0}
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
WaveRestoreZoom {0 ps} {1050 ns}
