onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/rst
add wave -noupdate /testbench/clk
add wave -noupdate /testbench/du_e/eth_tx_clk
add wave -noupdate /testbench/du_e/eth_tx_en
add wave -noupdate -radix hexadecimal -childformat {{/testbench/du_e/eth_txd(0) -radix hexadecimal} {/testbench/du_e/eth_txd(1) -radix hexadecimal} {/testbench/du_e/eth_txd(2) -radix hexadecimal} {/testbench/du_e/eth_txd(3) -radix hexadecimal}} -subitemconfig {/testbench/du_e/eth_txd(0) {-height 29 -radix hexadecimal} /testbench/du_e/eth_txd(1) {-height 29 -radix hexadecimal} /testbench/du_e/eth_txd(2) {-height 29 -radix hexadecimal} /testbench/du_e/eth_txd(3) {-height 29 -radix hexadecimal}} /testbench/du_e/eth_txd
add wave -noupdate /testbench/du_e/ser_debug_e/ser_frm
add wave -noupdate /testbench/du_e/ser_debug_e/ser_clk
add wave -noupdate /testbench/du_e/ser_debug_e/ser_irdy
add wave -noupdate -radix hexadecimal /testbench/du_e/ser_debug_e/ser_data
add wave -noupdate /testbench/du_e/ipoe_b/du_e/miirx_frm
add wave -noupdate /testbench/du_e/ipoe_b/du_e/miirx_irdy
add wave -noupdate /testbench/du_e/ipoe_b/du_e/miirx_trdy
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/du_e/miirx_data
add wave -noupdate -divider {eth receiver}
add wave -noupdate -expand -group eth_receiver /testbench/ethrx_e/mii_clk
add wave -noupdate -expand -group eth_receiver /testbench/ethrx_e/mii_frm
add wave -noupdate -expand -group eth_receiver /testbench/ethrx_e/mii_irdy
add wave -noupdate -expand -group eth_receiver -radix hexadecimal -childformat {{/testbench/ethrx_e/mii_data(0) -radix hexadecimal} {/testbench/ethrx_e/mii_data(1) -radix hexadecimal} {/testbench/ethrx_e/mii_data(2) -radix hexadecimal} {/testbench/ethrx_e/mii_data(3) -radix hexadecimal}} -subitemconfig {/testbench/ethrx_e/mii_data(0) {-height 29 -radix hexadecimal} /testbench/ethrx_e/mii_data(1) {-height 29 -radix hexadecimal} /testbench/ethrx_e/mii_data(2) {-height 29 -radix hexadecimal} /testbench/ethrx_e/mii_data(3) {-height 29 -radix hexadecimal}} /testbench/ethrx_e/mii_data
add wave -noupdate -expand -group eth_receiver -expand -group crc /testbench/ethrx_e/crc_equ
add wave -noupdate -expand -group eth_receiver -expand -group crc /testbench/ethrx_e/crc_sb
add wave -noupdate -expand -group eth_receiver -expand -group crc -radix hexadecimal /testbench/ethrx_e/crc_rem
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/ser_debug_e/video_b/ser_display_e/serdes_e/des_irdy
add wave -noupdate -radix ascii /testbench/du_e/ser_debug_e/video_b/ser_display_e/cga_codes
add wave -noupdate -group pltx /testbench/du_e/ipoe_b/pltx_frm
add wave -noupdate -group pltx /testbench/du_e/ipoe_b/pltx_irdy
add wave -noupdate -group pltx /testbench/du_e/ipoe_b/pltx_trdy
add wave -noupdate -group pltx /testbench/du_e/ipoe_b/pltx_end
add wave -noupdate -group pltx -radix hexadecimal -childformat {{/testbench/du_e/ipoe_b/pltx_data(0) -radix hexadecimal} {/testbench/du_e/ipoe_b/pltx_data(1) -radix hexadecimal} {/testbench/du_e/ipoe_b/pltx_data(2) -radix hexadecimal} {/testbench/du_e/ipoe_b/pltx_data(3) -radix hexadecimal} {/testbench/du_e/ipoe_b/pltx_data(4) -radix hexadecimal} {/testbench/du_e/ipoe_b/pltx_data(5) -radix hexadecimal} {/testbench/du_e/ipoe_b/pltx_data(6) -radix hexadecimal} {/testbench/du_e/ipoe_b/pltx_data(7) -radix hexadecimal}} -subitemconfig {/testbench/du_e/ipoe_b/pltx_data(0) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/pltx_data(1) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/pltx_data(2) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/pltx_data(3) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/pltx_data(4) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/pltx_data(5) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/pltx_data(6) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/pltx_data(7) {-height 29 -radix hexadecimal}} /testbench/du_e/ipoe_b/pltx_data
add wave -noupdate -divider {New Divider}
add wave -noupdate -group eth_tx /testbench/du_e/ipoe_b/du_e/ethtx_e/pl_frm
add wave -noupdate -group eth_tx /testbench/du_e/ipoe_b/du_e/ethtx_e/pl_irdy
add wave -noupdate -group eth_tx /testbench/du_e/ipoe_b/du_e/ethtx_e/pl_trdy
add wave -noupdate -group eth_tx /testbench/du_e/ipoe_b/du_e/ethtx_e/pl_end
add wave -noupdate -group eth_tx -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ethtx_e/pl_data
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
add wave -noupdate -group ipv4_rx /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4rx_e/ipv4_frm
add wave -noupdate -group ipv4_rx /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4rx_e/ipv4_irdy
add wave -noupdate -group ipv4_rx -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4rx_e/ipv4_data
add wave -noupdate -group ipv4_rx /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4rx_e/ipv4len_irdy
add wave -noupdate -group ipv4_rx /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4rx_e/ipv4da_frm
add wave -noupdate -group ipv4_rx /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4rx_e/ipv4da_irdy
add wave -noupdate -group ipv4_rx /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4rx_e/ipv4sa_irdy
add wave -noupdate -group ipv4_rx /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4rx_e/ipv4proto_irdy
add wave -noupdate -group ipv4_rx /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4rx_e/pl_frm
add wave -noupdate -group ipv4_rx /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4rx_e/pl_irdy
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/pl_frm
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/pl_irdy
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/pl_trdy
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/pl_end
add wave -noupdate -group ipv4_tx -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/pl_data
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4_irdy
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4_trdy
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4_end
add wave -noupdate -group ipv4_tx -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4_data
add wave -noupdate -group ipv4_tx -expand -group ipv4a /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4a_frm
add wave -noupdate -group ipv4_tx -expand -group ipv4a /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4a_irdy
add wave -noupdate -group ipv4_tx -expand -group ipv4a /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4a_end
add wave -noupdate -group ipv4_tx -expand -group ipv4a -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4a_data
add wave -noupdate -group ipv4_tx -expand -group len -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4len_irdy
add wave -noupdate -group ipv4_tx -expand -group len -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/meta_b/len_b/datai
add wave -noupdate -group ipv4_tx -expand -group len -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/meta_b/len_b/datao
add wave -noupdate -group ipv4_tx -expand -group len -radix hexadecimal -childformat {{/testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4len_data(0) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4len_data(1) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4len_data(2) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4len_data(3) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4len_data(4) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4len_data(5) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4len_data(6) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4len_data(7) -radix hexadecimal}} -subitemconfig {/testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4len_data(0) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4len_data(1) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4len_data(2) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4len_data(3) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4len_data(4) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4len_data(5) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4len_data(6) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4len_data(7) {-height 29 -radix hexadecimal}} /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4len_data
add wave -noupdate -group ipv4_tx -group proto -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4proto_irdy
add wave -noupdate -group ipv4_tx -group proto -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4proto_trdy
add wave -noupdate -group ipv4_tx -group proto -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4proto_end
add wave -noupdate -group ipv4_tx -group proto -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4proto_data
add wave -noupdate -group udp4 /testbench/du_e/ipoe_b/du_e/ipv4_e/udp_e/plrx_frm
add wave -noupdate -group udp4 /testbench/du_e/ipoe_b/du_e/ipv4_e/udp_e/plrx_irdy
add wave -noupdate -group udp4 /testbench/du_e/ipoe_b/du_e/ipv4_e/udp_e/plrx_trdy
add wave -noupdate -group udp4 -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/udp_e/plrx_data
add wave -noupdate -group udp4 /testbench/du_e/ipoe_b/du_e/ipv4_e/udp_e/pltx_frm
add wave -noupdate -group udp4 /testbench/du_e/ipoe_b/du_e/ipv4_e/udp_e/pltx_irdy
add wave -noupdate -group udp4 /testbench/du_e/ipoe_b/du_e/ipv4_e/udp_e/pltx_trdy
add wave -noupdate -group udp4 -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/udp_e/pltx_data
add wave -noupdate -group udp4 /testbench/du_e/ipoe_b/du_e/ipv4_e/udp_e/pltx_end
add wave -noupdate -group udp4 /testbench/du_e/ipoe_b/du_e/ipv4_e/udp_e/udptx_frm
add wave -noupdate -group udp4 /testbench/du_e/ipoe_b/du_e/ipv4_e/udp_e/udptx_irdy
add wave -noupdate -group udp4 /testbench/du_e/ipoe_b/du_e/ipv4_e/udp_e/udptx_trdy
add wave -noupdate -group udp4 /testbench/du_e/ipoe_b/du_e/ipv4_e/udp_e/udptx_end
add wave -noupdate -group udp4 -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/udp_e/meta_b/len_datai
add wave -noupdate -group udp4 -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/udp_e/udptx_data
add wave -noupdate -group udp4 /testbench/du_e/ipoe_b/du_e/ipv4_e/udp_e/meta_b/sp_full
add wave -noupdate -group udp4 /testbench/du_e/ipoe_b/du_e/ipv4_e/udp_e/meta_b/dp_full
add wave -noupdate -group udp4 -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/udp_e/ppltx_data
add wave -noupdate -group udp4 /testbench/du_e/ipoe_b/du_e/ipv4_e/udp_e/udptx_e/hdr_end
add wave -noupdate -group udp4 -expand -group meta_b /testbench/du_e/ipoe_b/du_e/ipv4_e/udp_e/meta_b/sprx_irdy
add wave -noupdate -group udp4 -expand -group meta_b /testbench/du_e/ipoe_b/du_e/ipv4_e/udp_e/meta_b/sptx_irdy
add wave -noupdate -group udp4 -expand -group meta_b -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/udp_e/meta_b/sp_data
add wave -noupdate -group udp4 -expand -group meta_b /testbench/du_e/ipoe_b/du_e/ipv4_e/udp_e/meta_b/dprx_irdy
add wave -noupdate -group udp4 -expand -group meta_b /testbench/du_e/ipoe_b/du_e/ipv4_e/udp_e/meta_b/dptx_irdy
add wave -noupdate -group udp4 -expand -group meta_b -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/udp_e/meta_b/dp_data
add wave -noupdate -group udp4 -expand -group meta_b /testbench/du_e/ipoe_b/du_e/ipv4_e/udp_e/meta_b/lenrx_irdy
add wave -noupdate -group udp4 -expand -group meta_b -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/udp_e/meta_b/len_datai
add wave -noupdate -group udp4 -expand -group meta_b /testbench/du_e/ipoe_b/du_e/ipv4_e/udp_e/meta_b/lentx_irdy
add wave -noupdate -group udp4 -expand -group meta_b -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/udp_e/meta_b/len_b/datai
add wave -noupdate -group udp4 -expand -group meta_b -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/udp_e/meta_b/len_b/datao
add wave -noupdate -group udp4 -expand -group meta_b -radix hexadecimal -childformat {{/testbench/du_e/ipoe_b/du_e/ipv4_e/udp_e/meta_b/len_data(0) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/ipv4_e/udp_e/meta_b/len_data(1) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/ipv4_e/udp_e/meta_b/len_data(2) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/ipv4_e/udp_e/meta_b/len_data(3) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/ipv4_e/udp_e/meta_b/len_data(4) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/ipv4_e/udp_e/meta_b/len_data(5) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/ipv4_e/udp_e/meta_b/len_data(6) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/ipv4_e/udp_e/meta_b/len_data(7) -radix hexadecimal}} -subitemconfig {/testbench/du_e/ipoe_b/du_e/ipv4_e/udp_e/meta_b/len_data(0) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/ipv4_e/udp_e/meta_b/len_data(1) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/ipv4_e/udp_e/meta_b/len_data(2) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/ipv4_e/udp_e/meta_b/len_data(3) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/ipv4_e/udp_e/meta_b/len_data(4) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/ipv4_e/udp_e/meta_b/len_data(5) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/ipv4_e/udp_e/meta_b/len_data(6) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/ipv4_e/udp_e/meta_b/len_data(7) {-height 29 -radix hexadecimal}} /testbench/du_e/ipoe_b/du_e/ipv4_e/udp_e/meta_b/len_data
add wave -noupdate -group udp4 -group udp_rx /testbench/du_e/ipoe_b/du_e/ipv4_e/udp_e/udp_rx_e/udpsp_frm
add wave -noupdate -group udp4 -group udp_rx /testbench/du_e/ipoe_b/du_e/ipv4_e/udp_e/udp_rx_e/udpsp_irdy
add wave -noupdate -group udp4 -group udp_rx /testbench/du_e/ipoe_b/du_e/ipv4_e/udp_e/udp_rx_e/udpdp_frm
add wave -noupdate -group udp4 -group udp_rx /testbench/du_e/ipoe_b/du_e/ipv4_e/udp_e/udp_rx_e/udpdp_irdy
add wave -noupdate -group udp4 -group udp_rx /testbench/du_e/ipoe_b/du_e/ipv4_e/udp_e/udp_rx_e/udplen_frm
add wave -noupdate -group udp4 -group udp_rx /testbench/du_e/ipoe_b/du_e/ipv4_e/udp_e/udp_rx_e/udplen_irdy
add wave -noupdate -group icmpd -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/icmprx_frm
add wave -noupdate -group icmpd -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/buffer_e/rd_cntr
add wave -noupdate -group icmpd -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/icmprx_irdy
add wave -noupdate -group icmpd -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/icmprx_data
add wave -noupdate -group icmpd -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/icmptx_frm
add wave -noupdate -group icmpd /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/icmptx_irdy
add wave -noupdate -group icmpd /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/icmptx_trdy
add wave -noupdate -group icmpd /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/icmptx_end
add wave -noupdate -group icmpd -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/icmptx_data
add wave -noupdate -group icmpd -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/buffer_e/dst_data
add wave -noupdate -group icmpd /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/icmppltx_irdy
add wave -noupdate -group icmpd /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/icmppltx_trdy
add wave -noupdate -group icmpd /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/icmppltx_end
add wave -noupdate -group icmpd -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/icmppltx_data
add wave -noupdate -group icmpd /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/icmprply_e/metatx_end
add wave -noupdate -group icmpd /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/buffer_e/rollback
add wave -noupdate -group icmpd /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/buffer_e/commit
add wave -noupdate -group icmpd /testbench/du_e/ipoe_b/du_e/fifo_cmmt
add wave -noupdate -group icmpd /testbench/du_e/ipoe_b/du_e/fifo_rllbk
add wave -noupdate -group flow_e /testbench/du_e/ipoe_b/sioflow_e/rx_frm
add wave -noupdate -group flow_e /testbench/du_e/ipoe_b/sioflow_e/rx_irdy
add wave -noupdate -group flow_e /testbench/du_e/ipoe_b/sioflow_e/rx_trdy
add wave -noupdate -group flow_e -radix hexadecimal -childformat {{/testbench/du_e/ipoe_b/sioflow_e/rx_data(0) -radix hexadecimal} {/testbench/du_e/ipoe_b/sioflow_e/rx_data(1) -radix hexadecimal} {/testbench/du_e/ipoe_b/sioflow_e/rx_data(2) -radix hexadecimal} {/testbench/du_e/ipoe_b/sioflow_e/rx_data(3) -radix hexadecimal} {/testbench/du_e/ipoe_b/sioflow_e/rx_data(4) -radix hexadecimal} {/testbench/du_e/ipoe_b/sioflow_e/rx_data(5) -radix hexadecimal} {/testbench/du_e/ipoe_b/sioflow_e/rx_data(6) -radix hexadecimal} {/testbench/du_e/ipoe_b/sioflow_e/rx_data(7) -radix hexadecimal}} -subitemconfig {/testbench/du_e/ipoe_b/sioflow_e/rx_data(0) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/sioflow_e/rx_data(1) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/sioflow_e/rx_data(2) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/sioflow_e/rx_data(3) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/sioflow_e/rx_data(4) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/sioflow_e/rx_data(5) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/sioflow_e/rx_data(6) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/sioflow_e/rx_data(7) {-height 29 -radix hexadecimal}} /testbench/du_e/ipoe_b/sioflow_e/rx_data
add wave -noupdate -group flow_e /testbench/du_e/ipoe_b/sioflow_e/tx_frm
add wave -noupdate -group flow_e /testbench/du_e/ipoe_b/sioflow_e/tx_irdy
add wave -noupdate -group flow_e /testbench/du_e/ipoe_b/sioflow_e/tx_trdy
add wave -noupdate -group flow_e /testbench/du_e/ipoe_b/sioflow_e/tx_end
add wave -noupdate -group flow_e -radix hexadecimal /testbench/du_e/ipoe_b/sioflow_e/tx_data
add wave -noupdate -group flow_e /testbench/du_e/ipoe_b/sioflow_e/ackrply_req
add wave -noupdate -group flow_e /testbench/du_e/ipoe_b/sioflow_e/ackrply_rdy
add wave -noupdate -group flow_e /testbench/du_e/ipoe_b/sioflow_e/buffer_cmmt
add wave -noupdate -group flow_e /testbench/du_e/ipoe_b/sioflow_e/buffer_rllbk
add wave -noupdate -group flow_e /testbench/du_e/ipoe_b/sioflow_e/buffer_ovfl
add wave -noupdate -group flow_e -radix hexadecimal /testbench/du_e/ipoe_b/sioflow_e/rgtr_id
add wave -noupdate -group flow_e /testbench/du_e/ipoe_b/sioflow_e/acktx_b/ack_irdy
add wave -noupdate -group flow_e -radix hexadecimal /testbench/du_e/ipoe_b/sioflow_e/acktx_b/ack_data
add wave -noupdate -group flow_e /testbench/du_e/ipoe_b/sioflow_e/acktx_end
add wave -noupdate -group flow_e -radix hexadecimal /testbench/du_e/ipoe_b/sioflow_e/acktx_b/meta_data
add wave -noupdate -group flow_e /testbench/du_e/ipoe_b/sioflow_e/ackrx_dv
add wave -noupdate -group flow_e -radix hexadecimal /testbench/du_e/ipoe_b/sioflow_e/ackrx_data
add wave -noupdate -group fifo_e /testbench/du_e/ipoe_b/du_e/fifo_e/src_frm
add wave -noupdate -group fifo_e /testbench/du_e/ipoe_b/du_e/fifo_e/src_irdy
add wave -noupdate -group fifo_e /testbench/du_e/ipoe_b/du_e/fifo_e/src_trdy
add wave -noupdate -group fifo_e /testbench/du_e/ipoe_b/du_e/fifo_e/src_end
add wave -noupdate -group fifo_e -radix hexadecimal /testbench/du_e/ipoe_b/du_e/fifo_e/src_data
add wave -noupdate -group fifo_e /testbench/du_e/ipoe_b/du_e/fifo_e/dst_frm
add wave -noupdate -group fifo_e /testbench/du_e/ipoe_b/du_e/fifo_e/dst_irdy
add wave -noupdate -group fifo_e /testbench/du_e/ipoe_b/du_e/fifo_e/dst_trdy
add wave -noupdate -group fifo_e /testbench/du_e/ipoe_b/du_e/fifo_e/dst_end
add wave -noupdate -group fifo_e -radix hexadecimal /testbench/du_e/ipoe_b/du_e/fifo_e/dst_data
add wave -noupdate -group fifo_e /testbench/du_e/ipoe_b/du_e/fifo_e/rx_irdy
add wave -noupdate -group fifo_e /testbench/du_e/ipoe_b/du_e/fifo_e/rx_writ
add wave -noupdate -group fifo_e -radix hexadecimal /testbench/du_e/ipoe_b/du_e/fifo_e/rx_data
add wave -noupdate -group fifo_e /testbench/du_e/ipoe_b/du_e/fifo_e/tx_irdy
add wave -noupdate -group fifo_e /testbench/du_e/ipoe_b/du_e/fifo_e/tx_trdy
add wave -noupdate -group fifo_e -radix hexadecimal /testbench/du_e/ipoe_b/du_e/fifo_e/line__120/cntr
add wave -noupdate -group fifo_e -radix hexadecimal /testbench/du_e/ipoe_b/du_e/fifo_e/tx_data
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/buffer_e/src_frm
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/buffer_e/src_irdy
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/buffer_e/src_trdy
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/buffer_e/src_data
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/buffer_e/wr_ena
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/buffer_e/wr_ptr
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/buffer_e/wr_cntr
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/buffer_e/wr_cmp
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/buffer_e/rollback
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/buffer_e/commit
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/buffer_e/overflow
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/buffer_e/rd_cntr
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/buffer_e/dst_irdy1
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/buffer_e/dst_irdy
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/buffer_e/feed_ena
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/buffer_e/dst_trdy
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/buffer_e/max_depthgt1_g/latency_g/fill
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/buffer_e/max_depthgt1_g/latency_g/dstirdy_p/b(0)
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/buffer_e/max_depthgt1_g/latency_g/dstirdy_p/q(0)
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/buffer_e/max_depthgt1_g/latency_g/dstirdy_p/v(0)
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/buffer_e/max_depthgt1_g/rdata
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/buffer_e/max_depthgt1_g/latency_g/dstirdy_p/data
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/buffer_e/dst_data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {6000566 ps} 0} {{Cursor 2} {8963421 ps} 0}
quietly wave cursor active 2
configure wave -namecolwidth 277
configure wave -valuecolwidth 185
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
WaveRestoreZoom {8635296 ps} {9291546 ps}
