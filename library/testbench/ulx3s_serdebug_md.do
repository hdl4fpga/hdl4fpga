onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/rmii_clk
add wave -noupdate /testbench/rmii_rxdv
add wave -noupdate -radix hexadecimal /testbench/rmii_rxd
add wave -noupdate /testbench/rmii_clk
add wave -noupdate /testbench/rmii_txen
add wave -noupdate -radix hexadecimal /testbench/rmii_txd
add wave -noupdate -radix ascii /testbench/du_e/video_g/ser_debug_e/ser_display_e/cga_codes
add wave -noupdate /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/fcs_sb
add wave -noupdate /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/fcs_vld
add wave -noupdate /testbench/tb_ipoe_b/tbipoe_e/tbethtx_e/pyl_frm
add wave -noupdate /testbench/tb_ipoe_b/tbipoe_e/tbethtx_e/pyl_irdy
add wave -noupdate /testbench/tb_ipoe_b/tbipoe_e/tbethtx_e/pyl_trdy
add wave -noupdate /testbench/tb_ipoe_b/tbipoe_e/tbethtx_e/pyl_data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {5870000000 fs} 0} {{Cursor 3} {109982090 fs} 0}
quietly wave cursor active 1
configure wave -namecolwidth 111
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
configure wave -timelineunits us
update
WaveRestoreZoom {0 fs} {6352500 ps}
