onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/du_e/ipoe_g/ipoe_b/du_e/mii_clk
add wave -noupdate /testbench/du_e/ipoe_g/ipoe_b/du_e/ipv4_e/udp_e/dhcpcd_e/dhcpcdtx_frm
add wave -noupdate /testbench/du_e/ipoe_g/ipoe_b/du_e/ipv4_e/udp_e/dhcpcd_e/dlltx_full
add wave -noupdate /testbench/du_e/ipoe_g/ipoe_b/du_e/ipv4_e/udp_e/dhcpcd_e/nettx_full
add wave -noupdate /testbench/du_e/ipoe_g/ipoe_b/du_e/ipv4_e/udp_e/dhcpcd_e/dhcpdscb_e/dhcpdscb_irdy
add wave -noupdate /testbench/du_e/ipoe_g/ipoe_b/du_e/ipv4_e/udp_e/dhcpcd_e/dhcpdscb_e/dhcpdscb_trdy
add wave -noupdate /testbench/du_e/ipoe_g/ipoe_b/du_e/ipv4_e/udp_e/dhcpcd_e/dhcpdscb_e/dhcpdscb_end
add wave -noupdate /testbench/du_e/ipoe_g/ipoe_b/du_e/ipv4_e/udp_e/dhcpcd_e/dhcpdscb_e/dhcpdscb_data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {22237140 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 117
configure wave -valuecolwidth 69
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
WaveRestoreZoom {0 ps} {42 us}
