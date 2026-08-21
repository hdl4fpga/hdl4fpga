onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/rmii_clk
add wave -noupdate /testbench/rmii_rxdv
add wave -noupdate /testbench/rmii_rxd
add wave -noupdate /testbench/rmii_clk
add wave -noupdate /testbench/rmii_txen
add wave -noupdate -radix hexadecimal /testbench/rmii_txd
add wave -noupdate /testbench/tbipoe_e/tbehrx_e/fcs_sb
add wave -noupdate /testbench/tbipoe_e/tbehrx_e/fcs_vld
add wave -noupdate -group rmii /testbench/du_e/gn(12)
add wave -noupdate -group rmii -divider {New Divider}
add wave -noupdate -group rmii /testbench/du_e/gn(10)
add wave -noupdate -group rmii /testbench/du_e/gp(10)
add wave -noupdate -group rmii /testbench/du_e/gn(9)
add wave -noupdate -group rmii -divider {New Divider}
add wave -noupdate -group rmii /testbench/du_e/gp(12)
add wave -noupdate -group rmii /testbench/du_e/gp(11)
add wave -noupdate -group rmii /testbench/du_e/gn(11)
add wave -noupdate -group rmii -divider {New Divider}
add wave -noupdate -group rmii /testbench/du_e/gp(13)
add wave -noupdate -group rmii /testbench/du_e/gn(13)
add wave -noupdate -radix ascii /testbench/du_e/video_g/ser_debug_e/ser_display_e/cga_codes
add wave -noupdate /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/arpd_i/tx_b/buffer_b/buffer_i/commit
add wave -noupdate /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/arpd_i/tx_b/buffer_b/buffer_i/rollback
add wave -noupdate /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/arpd_i/tx_b/buffer_b/buffer_i/src_frm
add wave -noupdate /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/arpd_i/tx_b/buffer_b/buffer_i/src_irdy
add wave -noupdate /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/arpd_i/tx_b/buffer_b/buffer_i/src_trdy
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/arpd_i/tx_b/buffer_b/buffer_i/src_data
add wave -noupdate /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/arpd_i/tx_b/buffer_b/buffer_i/dst_frm
add wave -noupdate /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/arpd_i/tx_b/buffer_b/buffer_i/dst_irdy
add wave -noupdate /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/arpd_i/tx_b/buffer_b/buffer_i/dst_trdy
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/arpd_i/tx_b/buffer_b/buffer_i/dst_data
add wave -noupdate /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/arpd_i/tx_b/buffer_b/buffer_i/fifo_irdy
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/arpd_i/tx_b/buffer_b/buffer_i/fifo_data
add wave -noupdate /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/arpd_i/tx_b/buffer_b/buffer_i/fifo_trdy
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {10744813050 fs} 0} {{Cursor 2} {4940505860 fs} 0}
quietly wave cursor active 1
configure wave -namecolwidth 219
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
WaveRestoreZoom {3530370200 fs} {16370546200 fs}
