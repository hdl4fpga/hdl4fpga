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
add wave -noupdate -group eth_receiver /testbench/ethrx_e/mii_clk
add wave -noupdate -group eth_receiver /testbench/ethrx_e/mii_frm
add wave -noupdate -group eth_receiver /testbench/ethrx_e/mii_irdy
add wave -noupdate -group eth_receiver -radix hexadecimal /testbench/ethrx_e/mii_data
add wave -noupdate -group eth_receiver -expand -group crc /testbench/ethrx_e/crc_equ
add wave -noupdate -group eth_receiver -expand -group crc /testbench/ethrx_e/crc_sb
add wave -noupdate -group eth_receiver -expand -group crc -radix hexadecimal /testbench/ethrx_e/crc_rem
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix ascii /testbench/du_e/ser_debug_e/video_b/ser_display_e/cga_codes
add wave -noupdate -expand -group pltx /testbench/du_e/ipoe_b/pltx_frm
add wave -noupdate -expand -group pltx /testbench/du_e/ipoe_b/pltx_irdy
add wave -noupdate -expand -group pltx /testbench/du_e/ipoe_b/pltx_trdy
add wave -noupdate -expand -group pltx /testbench/du_e/ipoe_b/pltx_end
add wave -noupdate -expand -group pltx -radix hexadecimal /testbench/du_e/ipoe_b/pltx_data
add wave -noupdate -divider {New Divider}
add wave -noupdate -group eth_tx /testbench/du_e/ipoe_b/du_e/miitx_frm
add wave -noupdate -group eth_tx /testbench/du_e/ipoe_b/du_e/miitx_irdy
add wave -noupdate -group eth_tx /testbench/du_e/ipoe_b/du_e/miitx_trdy
add wave -noupdate -group eth_tx /testbench/du_e/ipoe_b/du_e/miitx_end
add wave -noupdate -group eth_tx -radix hexadecimal -childformat {{/testbench/du_e/ipoe_b/du_e/miitx_data(0) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/miitx_data(1) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/miitx_data(2) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/miitx_data(3) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/miitx_data(4) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/miitx_data(5) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/miitx_data(6) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/miitx_data(7) -radix hexadecimal}} -subitemconfig {/testbench/du_e/ipoe_b/du_e/miitx_data(0) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/miitx_data(1) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/miitx_data(2) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/miitx_data(3) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/miitx_data(4) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/miitx_data(5) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/miitx_data(6) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/miitx_data(7) {-height 29 -radix hexadecimal}} /testbench/du_e/ipoe_b/du_e/miitx_data
add wave -noupdate -group eth_tx /testbench/du_e/ipoe_b/du_e/ethtx_e/minpkt
add wave -noupdate -group eth_tx /testbench/du_e/ipoe_b/du_e/ethtx_e/fcs_mode
add wave -noupdate -group eth_tx /testbench/du_e/ipoe_b/du_e/ethtx_e/fcs_irdy
add wave -noupdate -group eth_tx -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ethtx_e/fcs_data
add wave -noupdate -group eth_tx -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ethtx_e/fcs_crc
add wave -noupdate -group eth_tx /testbench/du_e/ipoe_b/du_e/ethtx_e/fcs_end
add wave -noupdate -group arpd /testbench/du_e/ipoe_b/du_e/arpd_e/arprx_frm
add wave -noupdate -group arpd /testbench/du_e/ipoe_b/du_e/arpd_e/sparx_irdy
add wave -noupdate -group arpd /testbench/du_e/ipoe_b/du_e/arpd_e/sparx_trdy
add wave -noupdate -group arpd /testbench/du_e/ipoe_b/du_e/arpd_e/sparx_end
add wave -noupdate -group arpd /testbench/du_e/ipoe_b/du_e/arpd_e/sparx_equ
add wave -noupdate -group arpd /testbench/du_e/ipoe_b/du_e/arpd_e/arpd_rdy
add wave -noupdate -group arpd /testbench/du_e/ipoe_b/du_e/arpd_e/arpd_req
add wave -noupdate -group arpd /testbench/du_e/ipoe_b/du_e/arpd_e/arpdtx_frm
add wave -noupdate -group arpd /testbench/du_e/ipoe_b/du_e/arpd_e/arpdtx_irdy
add wave -noupdate -group arpd /testbench/du_e/ipoe_b/du_e/arpd_e/arpdtx_trdy
add wave -noupdate -group udp4 /testbench/du_e/ipoe_b/du_e/ipv4_e/udp_e/pltx_frm
add wave -noupdate -group udp4 /testbench/du_e/ipoe_b/du_e/ipv4_e/udp_e/pltx_irdy
add wave -noupdate -group udp4 /testbench/du_e/ipoe_b/du_e/ipv4_e/udp_e/pltx_trdy
add wave -noupdate -group udp4 -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/udp_e/pltx_data
add wave -noupdate -group udp4 /testbench/du_e/ipoe_b/du_e/ipv4_e/udp_e/pltx_end
add wave -noupdate -group udp4 /testbench/du_e/ipoe_b/du_e/ipv4_e/udp_e/dlltx_end
add wave -noupdate -group udp4 /testbench/du_e/ipoe_b/du_e/ipv4_e/udp_e/dlltx_irdy
add wave -noupdate -group udp4 /testbench/du_e/ipoe_b/du_e/ipv4_e/udp_e/dlltx_full
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/meta_b/lentx_irdy
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4_irdy
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/pl_irdy
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/pl_trdy
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4_trdy
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4_data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {8580349 ps} 0} {{Cursor 2} {2364411 ps} 0}
quietly wave cursor active 2
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
WaveRestoreZoom {0 ps} {7371400 ps}
