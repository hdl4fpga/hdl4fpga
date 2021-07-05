onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/du_e/ipoe_g/ipoe_b/du_e/mii_clk
add wave -noupdate /testbench/du_e/ipoe_g/ipoe_b/du_e/ipv4_e/udp_e/dhcpcd_e/dhcpcdtx_frm
add wave -noupdate /testbench/du_e/ipoe_g/ipoe_b/du_e/ipv4_e/udp_e/dhcpcd_e/dlltx_full
add wave -noupdate /testbench/du_e/ipoe_g/ipoe_b/du_e/ipv4_e/udp_e/dhcpcd_e/nettx_full
add wave -noupdate /testbench/du_e/ipoe_g/ipoe_b/du_e/ipv4_e/udp_e/dhcpcd_e/dhcpdscb_e/dhcpdscb_irdy
add wave -noupdate /testbench/du_e/ipoe_g/ipoe_b/du_e/ipv4_e/udp_e/dhcpcd_e/dhcpdscb_e/dhcpdscb_trdy
add wave -noupdate /testbench/du_e/ipoe_g/ipoe_b/du_e/ipv4_e/udp_e/dhcpcd_e/dhcpdscb_e/dhcpdscb_end
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_g/ipoe_b/du_e/ipv4_e/udp_e/dhcpcd_e/dhcpdscb_e/dhcpdscb_data
add wave -noupdate /testbench/du_e/ipoe_g/ipoe_b/du_e/ipv4_e/ipv4satx_frm
add wave -noupdate /testbench/du_e/ipoe_g/ipoe_b/du_e/ipv4_e/meta_b/datx_irdy
add wave -noupdate /testbench/du_e/ipoe_g/ipoe_b/du_e/ipv4_e/nettx_full
add wave -noupdate /testbench/du_e/ipoe_g/ipoe_b/du_e/ipv4_e/udp_e/meta_b/lentx_irdy
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_g/ipoe_b/du_e/ipv4_e/meta_b/crtn_data
add wave -noupdate /testbench/du_e/ipoe_g/ipoe_b/du_e/ipv4_e/meta_b/lentx_full
add wave -noupdate /testbench/du_e/ipoe_g/ipoe_b/du_e/ipv4_e/meta_b/lentx_irdy
add wave -noupdate /testbench/du_e/ipoe_g/ipoe_b/du_e/ipv4_e/meta_b/len_e/si_clk
add wave -noupdate /testbench/du_e/ipoe_g/ipoe_b/du_e/ipv4_e/meta_b/len_e/si_frm
add wave -noupdate /testbench/du_e/ipoe_g/ipoe_b/du_e/ipv4_e/meta_b/len_e/si_irdy
add wave -noupdate /testbench/du_e/ipoe_g/ipoe_b/du_e/ipv4_e/meta_b/len_e/si_trdy
add wave -noupdate /testbench/du_e/ipoe_g/ipoe_b/du_e/ipv4_e/meta_b/len_e/si_full
add wave -noupdate /testbench/du_e/ipoe_g/ipoe_b/du_e/ipv4_e/meta_b/len_e/si_data
add wave -noupdate /testbench/du_e/ipoe_g/ipoe_b/du_e/ipv4_e/arbiter_b/dev_req
add wave -noupdate /testbench/du_e/ipoe_g/ipoe_b/du_e/ipv4_e/arbiter_b/dev_gnt
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {73536770 fs} 0}
quietly wave cursor active 1
configure wave -namecolwidth 1081
configure wave -valuecolwidth 156
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
WaveRestoreZoom {0 fs} {2100 ns}
