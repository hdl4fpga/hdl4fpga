onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/rst
add wave -noupdate /testbench/clk
add wave -noupdate /testbench/du_e/eth_tx_clk
add wave -noupdate /testbench/du_e/eth_tx_en
add wave -noupdate -radix hexadecimal -childformat {{/testbench/du_e/eth_txd(0) -radix hexadecimal} {/testbench/du_e/eth_txd(1) -radix hexadecimal} {/testbench/du_e/eth_txd(2) -radix hexadecimal} {/testbench/du_e/eth_txd(3) -radix hexadecimal}} -subitemconfig {/testbench/du_e/eth_txd(0) {-height 29 -radix hexadecimal} /testbench/du_e/eth_txd(1) {-height 29 -radix hexadecimal} /testbench/du_e/eth_txd(2) {-height 29 -radix hexadecimal} /testbench/du_e/eth_txd(3) {-height 29 -radix hexadecimal}} /testbench/du_e/eth_txd
add wave -noupdate /testbench/du_e/ser_debug_e/ser_clk
add wave -noupdate /testbench/du_e/ser_debug_e/ser_frm
add wave -noupdate /testbench/du_e/ser_debug_e/ser_irdy
add wave -noupdate -radix hexadecimal /testbench/du_e/ser_debug_e/ser_data
add wave -noupdate -divider {eth receiver}
add wave -noupdate /testbench/ethrx_e/mii_clk
add wave -noupdate /testbench/ethrx_e/mii_irdy
add wave -noupdate /testbench/ethrx_e/mii_frm
add wave -noupdate -radix hexadecimal /testbench/ethrx_e/mii_data
add wave -noupdate /testbench/ethrx_e/crc_equ
add wave -noupdate /testbench/ethrx_e/crc_sb
add wave -noupdate /testbench/ethrx_e/line__114/q
add wave -noupdate -radix hexadecimal /testbench/ethrx_e/crc_rem
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/ipoe_b/htb_e/eth1_txd
add wave -noupdate /testbench/du_e/ipoe_b/htb_e/eth1_end
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/htb_e/eth_llc
add wave -noupdate /testbench/du_e/ipoe_b/htb_e/pl_frm
add wave -noupdate /testbench/du_e/ipoe_b/htb_e/pl_trdy
add wave -noupdate /testbench/du_e/ipoe_b/htb_e/pl_end
add wave -noupdate /testbench/du_e/ipoe_b/htb_e/pl_data
add wave -noupdate /testbench/du_e/ipoe_b/htb_e/miirx_frm
add wave -noupdate /testbench/du_e/ipoe_b/htb_e/miirx_end
add wave -noupdate /testbench/du_e/ipoe_b/htb_e/miirx_irdy
add wave -noupdate /testbench/du_e/ipoe_b/htb_e/miirx_data
add wave -noupdate /testbench/du_e/ipoe_b/htb_e/hwllc_irdy
add wave -noupdate /testbench/du_e/ipoe_b/htb_e/hwllc_trdy
add wave -noupdate /testbench/du_e/ipoe_b/htb_e/hwllc_end
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/htb_e/hwllc_data
add wave -noupdate -radix ascii /testbench/du_e/ser_debug_e/video_b/ser_display_e/cga_codes
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/ipoe_b/miirx_frm
add wave -noupdate -radix unsigned /testbench/du_e/ipoe_b/du_e/ethtx_e/cntr1
add wave -noupdate /testbench/du_e/ipoe_b/miirx_irdy
add wave -noupdate /testbench/du_e/ipoe_b/miirx_trdy
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/miirx_data
add wave -noupdate /testbench/du_e/ipoe_b/du_e/miitx_frm
add wave -noupdate /testbench/du_e/ipoe_b/du_e/miitx_irdy
add wave -noupdate /testbench/du_e/ipoe_b/du_e/miitx_trdy
add wave -noupdate /testbench/du_e/ipoe_b/du_e/miitx_end
add wave -noupdate -radix hexadecimal -childformat {{/testbench/du_e/ipoe_b/du_e/miitx_data(0) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/miitx_data(1) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/miitx_data(2) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/miitx_data(3) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/miitx_data(4) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/miitx_data(5) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/miitx_data(6) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/miitx_data(7) -radix hexadecimal}} -subitemconfig {/testbench/du_e/ipoe_b/du_e/miitx_data(0) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/miitx_data(1) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/miitx_data(2) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/miitx_data(3) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/miitx_data(4) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/miitx_data(5) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/miitx_data(6) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/miitx_data(7) {-height 29 -radix hexadecimal}} /testbench/du_e/ipoe_b/du_e/miitx_data
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ethtx_e/minpkt
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ethtx_e/fcs_mode
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ethtx_e/fcs_irdy
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ethtx_e/fcs_data
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ethtx_e/fcs_crc
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ethtx_e/fcs_end
add wave -noupdate -divider ipoe
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_end
add wave -noupdate /testbench/du_e/ipoe_b/du_e/arbiter_b/dev_req(0)
add wave -noupdate /testbench/du_e/ipoe_b/du_e/arbiter_b/dev_req(1)
add wave -noupdate /testbench/du_e/ipoe_b/du_e/arbiter_b/dev_gnt(0)
add wave -noupdate /testbench/du_e/ipoe_b/du_e/arbiter_b/dev_gnt(1)
add wave -noupdate -divider arp
add wave -noupdate /testbench/du_e/ipoe_b/du_e/arpd_e/arprx_frm
add wave -noupdate /testbench/du_e/ipoe_b/du_e/arpd_e/sparx_irdy
add wave -noupdate /testbench/du_e/ipoe_b/du_e/arpd_e/sparx_trdy
add wave -noupdate /testbench/du_e/ipoe_b/du_e/arpd_e/sparx_end
add wave -noupdate /testbench/du_e/ipoe_b/du_e/arpd_e/sparx_equ
add wave -noupdate /testbench/du_e/ipoe_b/du_e/arpd_e/arpd_rdy
add wave -noupdate /testbench/du_e/ipoe_b/du_e/arpd_e/arpd_req
add wave -noupdate /testbench/du_e/ipoe_b/du_e/arpd_e/arpdtx_frm
add wave -noupdate /testbench/du_e/ipoe_b/du_e/arpd_e/arpdtx_irdy
add wave -noupdate /testbench/du_e/ipoe_b/du_e/arpd_e/arpdtx_trdy
add wave -noupdate -divider ipv4
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4rx_frm
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4rx_data
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4sarx_frm
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4sarx_irdy
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4sarx_trdy
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4sarx_end
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4sarx_equ
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4sack_frm
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4sack_irdy
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4rx_e/ipv4_frm
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4rx_irdy
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4da_vld
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4darx_frm
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4darx_irdy
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4sarx_data
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/meta_b/lentx_full
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/meta_b/lentx_irdy
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/meta_b/lentx_data
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4proto_data
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4shdr_frm
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4len_frm
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4hdr_data
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4_trdy
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4proto_frm
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4proto_trdy
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4chsm_data
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/cksm_data
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/cksm_irdy
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/icmprx_vld
add wave -noupdate -divider icmp4
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/icmp_e/icmpd_rdy
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/icmp_e/icmpd_req
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {13318231 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 243
configure wave -valuecolwidth 191
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
WaveRestoreZoom {4035 ns} {18735 ns}
