onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/rst
add wave -noupdate /testbench/ml509_e/NlwBufferSignal_scope_e_ddr_e_ddr2_init_g_ddr_init_du_ddr_init_cas_CLK
add wave -noupdate /testbench/ml509_e/scope_e_ddr_e_dll_timer_rdy
add wave -noupdate /testbench/ml509_e/NlwBufferSignal_scope_e_ddr_e_ddr2_init_g_ddr_init_du_ddr_init_cas_IN
add wave -noupdate /testbench/ml509_e/scope_e_ddr_e_ddr_init_cas
add wave -noupdate /testbench/ml509_e/NlwBufferSignal_scope_e_ddr_e_ddr2_init_g_ddr_init_du_ddr_init_cas_CLK
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3991262 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 181
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
configure wave -timelineunits ps
update
WaveRestoreZoom {3986621 ps} {4011231 ps}
