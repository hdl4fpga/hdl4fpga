onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {CGA CODE}
add wave -noupdate /testbench/du_e/video_g/ser_debug_e/ser_display_e/cga_we
add wave -noupdate -radix ascii /testbench/du_e/video_g/ser_debug_e/ser_display_e/cga_codes
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/rmii_clk
add wave -noupdate /testbench/rmii_rxdv
add wave -noupdate -radix hexadecimal /testbench/rmii_rxd
add wave -noupdate /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/fcs_sb
add wave -noupdate /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/fcs_vld
add wave -noupdate -divider TX
add wave -noupdate /testbench/rmii_txen
add wave -noupdate -radix hexadecimal -childformat {{/testbench/rmii_txd(0) -radix hexadecimal} {/testbench/rmii_txd(1) -radix hexadecimal}} -subitemconfig {/testbench/rmii_txd(0) {-height 20 -radix hexadecimal} /testbench/rmii_txd(1) {-height 20 -radix hexadecimal}} /testbench/rmii_txd
add wave -noupdate /testbench/tb_ipoe_b/tbipoe_e/tbehrx_e/fcs_sb
add wave -noupdate /testbench/tb_ipoe_b/tbipoe_e/tbehrx_e/fcs_vld
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {24587421940 fs} 0}
quietly wave cursor active 1
configure wave -namecolwidth 178
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
WaveRestoreZoom {0 fs} {31500 ns}
