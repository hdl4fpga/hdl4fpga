onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/rmii_clk
add wave -noupdate /testbench/rmii_rxdv
add wave -noupdate /testbench/rmii_rxd
add wave -noupdate /testbench/rmii_clk
add wave -noupdate /testbench/rmii_txen
add wave -noupdate /testbench/rmii_txd
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
add wave -noupdate /testbench/du_e/ipoe_g_rmii_rxdv
add wave -noupdate /testbench/du_e/ipoe_g_mii_e_udpdaisy_e_sio_udp_e_miiipoe_i_arpd_i_rx_b_decode_i_cntr_0
add wave -noupdate /testbench/du_e/ipoe_g_mii_e_udpdaisy_e_sio_udp_e_miiipoe_i_arpd_i_tx_b_decode_i_cntr_0_sqmuxa
add wave -noupdate /testbench/du_e/ipoe_g_mii_e_udpdaisy_e_sio_udp_e_miiipoe_i_arpd_i_tx_req
add wave -noupdate /testbench/du_e/ipoe_g_mii_e_udpdaisy_e_sio_udp_e_miiipoe_i_arpd_i_tx_rdy
add wave -noupdate /testbench/du_e/ipoe_g_mii_e_udpdaisy_e_sio_udp_e_miiipoe_i_arpd_i_decode_frm
add wave -noupdate /testbench/du_e/ipoe_g_mii_e_udpdaisy_e_sio_udp_e_miiipoe_i_arpd_i_step_2
add wave -noupdate /testbench/du_e/ipoe_g_mii_e_udpdaisy_e_sio_udp_e_miiipoe_i_arpd_i_tx_b_decode_i_cntr_0
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {4431457000 fs} 0}
quietly wave cursor active 1
configure wave -namecolwidth 523
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
WaveRestoreZoom {4363244640 fs} {4516369630 fs}
