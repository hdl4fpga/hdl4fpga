onerror {resume}
quietly WaveActivateNextPane {} 0
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
add wave -noupdate -divider {CGA CODE}
add wave -noupdate /testbench/du_e/video_g/ser_debug_e/ser_display_e/cga_we
add wave -noupdate -radix ascii /testbench/du_e/video_g/ser_debug_e/ser_display_e/cga_codes
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/ipv4_i/icmpd_i/icmptx_frm
add wave -noupdate /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/ipv4_i/icmpd_i/icmptx_irdy
add wave -noupdate /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/ipv4_i/icmpd_i/icmptx_trdy
add wave -noupdate /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/ipv4_i/icmpd_i/icmptx_data
add wave -noupdate /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/ipv4_i/tx_b/length_act
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/ipv4_i/icmpd_i/icmprx_irdy
add wave -noupdate /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/ipv4_i/icmpd_i/icmprx_trdy
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/ipv4_i/icmpd_i/rqst_b/miiadjlen_i/init
add wave -noupdate /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/ipv4_i/icmpd_i/rqst_b/type_irdy
add wave -noupdate /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/ipv4_i/icmpd_i/rqst_b/code_irdy
add wave -noupdate /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/ipv4_i/tx_b/q
add wave -noupdate /testbench/rmii_clk
add wave -noupdate /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/ipv4_i/icmpd_i/rqst_b/chksum_irdy
add wave -noupdate /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/ipv4_i/icmpd_i/rqst_b/chksum_data
add wave -noupdate /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/ipv4_i/icmpd_i/icmprx_frm
add wave -noupdate -radix binary /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/ipv4_i/icmpd_i/icmprx_data
add wave -noupdate /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/ipv4_i/icmpd_i/rqst_b/rx_frm
add wave -noupdate /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/ipv4_i/icmpd_i/rx_data
add wave -noupdate /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/ipv4_i/icmpd_i/rx_irdy
add wave -noupdate /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/ipv4_i/icmpd_i/rqst_b/icmpchksum_irdy
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {17861487510 fs} 0} {{Cursor 2} {17597319080 fs} 1} {{Cursor 3} {13950434880 fs} 0}
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
WaveRestoreZoom {16777006580 fs} {18417631580 fs}
