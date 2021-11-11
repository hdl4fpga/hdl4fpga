onerror {resume}
quietly virtual signal -install /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e { (context /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e )(rollback & buffer_e/data_e/commit &buffer_e/data_e/wr_cntr &buffer_e/data_e/wr_ptr &buffer_e/data_e/rd_cntr & buffer_e/data_e/dst_trdy & buffer_e/data_e/dst_irdy )} fifo
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
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/hxd
add wave -noupdate /testbench/du_e/ipoe_b/htb_e/eth1_e/sio_frm
add wave -noupdate -radix unsigned /testbench/du_e/ipoe_b/htb_e/eth1_e/line__52/cntr
add wave -noupdate -radix hexadecimal -childformat {{/testbench/du_e/ipoe_b/htb_e/eth1_e/so_data(0) -radix hexadecimal} {/testbench/du_e/ipoe_b/htb_e/eth1_e/so_data(1) -radix hexadecimal} {/testbench/du_e/ipoe_b/htb_e/eth1_e/so_data(2) -radix hexadecimal} {/testbench/du_e/ipoe_b/htb_e/eth1_e/so_data(3) -radix hexadecimal}} -subitemconfig {/testbench/du_e/ipoe_b/htb_e/eth1_e/so_data(0) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/htb_e/eth1_e/so_data(1) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/htb_e/eth1_e/so_data(2) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/htb_e/eth1_e/so_data(3) {-height 29 -radix hexadecimal}} /testbench/du_e/ipoe_b/htb_e/eth1_e/so_data
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
add wave -noupdate -expand -group eth_tx /testbench/du_e/ipoe_b/du_e/ethtx_e/pl_frm
add wave -noupdate -expand -group eth_tx /testbench/du_e/ipoe_b/du_e/ethtx_e/pl_irdy
add wave -noupdate -expand -group eth_tx /testbench/du_e/ipoe_b/du_e/ethtx_e/pl_trdy
add wave -noupdate -expand -group eth_tx /testbench/du_e/ipoe_b/du_e/ethtx_e/pl_end
add wave -noupdate -expand -group eth_tx -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ethtx_e/pl_data
add wave -noupdate -expand -group eth_tx /testbench/du_e/ipoe_b/du_e/miitx_frm
add wave -noupdate -expand -group eth_tx /testbench/du_e/ipoe_b/du_e/miitx_irdy
add wave -noupdate -expand -group eth_tx /testbench/du_e/ipoe_b/du_e/miitx_trdy
add wave -noupdate -expand -group eth_tx /testbench/du_e/ipoe_b/du_e/miitx_end
add wave -noupdate -expand -group eth_tx -radix hexadecimal -childformat {{/testbench/du_e/ipoe_b/du_e/miitx_data(0) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/miitx_data(1) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/miitx_data(2) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/miitx_data(3) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/miitx_data(4) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/miitx_data(5) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/miitx_data(6) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/miitx_data(7) -radix hexadecimal}} -subitemconfig {/testbench/du_e/ipoe_b/du_e/miitx_data(0) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/miitx_data(1) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/miitx_data(2) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/miitx_data(3) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/miitx_data(4) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/miitx_data(5) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/miitx_data(6) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/miitx_data(7) {-height 29 -radix hexadecimal}} /testbench/du_e/ipoe_b/du_e/miitx_data
add wave -noupdate -expand -group eth_tx /testbench/du_e/ipoe_b/du_e/ethtx_e/minpkt
add wave -noupdate -expand -group eth_tx /testbench/du_e/ipoe_b/du_e/ethtx_e/fcs_mode
add wave -noupdate -expand -group eth_tx /testbench/du_e/ipoe_b/du_e/ethtx_e/fcs_irdy
add wave -noupdate -expand -group eth_tx -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ethtx_e/fcs_data
add wave -noupdate -expand -group eth_tx -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ethtx_e/fcs_crc
add wave -noupdate -expand -group eth_tx /testbench/du_e/ipoe_b/du_e/ethtx_e/fcs_end
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
add wave -noupdate -expand -group ipv4_tx /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/mii_clk
add wave -noupdate -expand -group ipv4_tx /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/pl_frm
add wave -noupdate -expand -group ipv4_tx /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/pl_irdy
add wave -noupdate -expand -group ipv4_tx /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/pl_trdy
add wave -noupdate -expand -group ipv4_tx /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/pl_end
add wave -noupdate -expand -group ipv4_tx -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/pl_data
add wave -noupdate -expand -group ipv4_tx /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/post
add wave -noupdate -expand -group ipv4_tx /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/metatx_end
add wave -noupdate -expand -group ipv4_tx -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/frm_ptr
add wave -noupdate -expand -group ipv4_tx /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4proto_frm
add wave -noupdate -expand -group ipv4_tx /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4proto_irdy
add wave -noupdate -expand -group ipv4_tx /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4proto_trdy
add wave -noupdate -expand -group ipv4_tx /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4proto_end
add wave -noupdate -expand -group ipv4_tx /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4_irdy
add wave -noupdate -expand -group ipv4_tx /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4_trdy
add wave -noupdate -expand -group ipv4_tx /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4_end
add wave -noupdate -expand -group ipv4_tx -radix hexadecimal -childformat {{/testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4_data(0) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4_data(1) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4_data(2) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4_data(3) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4_data(4) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4_data(5) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4_data(6) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4_data(7) -radix hexadecimal}} -subitemconfig {/testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4_data(0) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4_data(1) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4_data(2) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4_data(3) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4_data(4) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4_data(5) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4_data(6) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4_data(7) {-height 29 -radix hexadecimal}} /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4_data
add wave -noupdate -expand -group ipv4_tx /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/cksm_irdy
add wave -noupdate -expand -group ipv4_tx -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/cksm_data
add wave -noupdate -expand -group ipv4_tx -group ipv4a /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4a_frm
add wave -noupdate -expand -group ipv4_tx -group ipv4a /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4a_irdy
add wave -noupdate -expand -group ipv4_tx -group ipv4a /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4a_end
add wave -noupdate -expand -group ipv4_tx -group ipv4a -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4a_data
add wave -noupdate -expand -group ipv4_tx -group len -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4len_irdy
add wave -noupdate -expand -group ipv4_tx -group len /testbench/du_e/ipoe_b/du_e/ipv4_e/iplentx_irdy
add wave -noupdate -expand -group ipv4_tx -group len -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/meta_b/len_b/datai
add wave -noupdate -expand -group ipv4_tx -group len -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/meta_b/len_b/datao
add wave -noupdate -expand -group ipv4_tx -group len -radix hexadecimal -childformat {{/testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4len_data(0) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4len_data(1) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4len_data(2) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4len_data(3) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4len_data(4) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4len_data(5) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4len_data(6) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4len_data(7) -radix hexadecimal}} -subitemconfig {/testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4len_data(0) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4len_data(1) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4len_data(2) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4len_data(3) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4len_data(4) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4len_data(5) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4len_data(6) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4len_data(7) {-height 29 -radix hexadecimal}} /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4len_data
add wave -noupdate -expand -group ipv4_tx -group proto -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4proto_irdy
add wave -noupdate -expand -group ipv4_tx -group proto -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4proto_trdy
add wave -noupdate -expand -group ipv4_tx -group proto -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4proto_end
add wave -noupdate -expand -group ipv4_tx -group proto -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4proto_data
add wave -noupdate -expand -group icmpd -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/icmprx_frm
add wave -noupdate -expand -group icmpd -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/icmprx_irdy
add wave -noupdate -expand -group icmpd -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/icmprx_data
add wave -noupdate -expand -group icmpd -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/icmptx_frm
add wave -noupdate -expand -group icmpd /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/icmptx_irdy
add wave -noupdate -expand -group icmpd /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/icmptx_trdy
add wave -noupdate -expand -group icmpd /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/icmptx_end
add wave -noupdate -expand -group icmpd -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/icmptx_data
add wave -noupdate -expand -group icmpd /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/icmppltx_irdy
add wave -noupdate -expand -group icmpd /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/icmppltx_trdy
add wave -noupdate -expand -group icmpd /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/icmppltx_end
add wave -noupdate -expand -group icmpd -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/icmppltx_data
add wave -noupdate -expand -group icmpd /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/icmprply_e/metatx_end
add wave -noupdate -expand -group icmpd /testbench/du_e/ipoe_b/du_e/fifo_cmmt
add wave -noupdate -expand -group icmpd /testbench/du_e/ipoe_b/du_e/fifo_rllbk
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
add wave -noupdate -group fifo_e -radix hexadecimal /testbench/du_e/ipoe_b/du_e/fifo_e/tx_data
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_trdy
add wave -noupdate /testbench/du_e/ipoe_b/du_e/arbiter_b/dev_req(0)
add wave -noupdate /testbench/du_e/ipoe_b/du_e/arbiter_b/dev_gnt(0)
add wave -noupdate /testbench/du_e/ipoe_b/du_e/arbiter_b/dev_req(1)
add wave -noupdate /testbench/du_e/ipoe_b/du_e/arbiter_b/dev_gnt(1)
add wave -noupdate -group arpd /testbench/du_e/ipoe_b/du_e/arpd_e/mii_clk
add wave -noupdate -group arpd /testbench/du_e/ipoe_b/du_e/arpd_e/arprx_frm
add wave -noupdate -group arpd /testbench/du_e/ipoe_b/du_e/arpd_e/arprx_irdy
add wave -noupdate -group arpd -radix hexadecimal /testbench/du_e/ipoe_b/du_e/arpd_e/arprx_data
add wave -noupdate -group arpd /testbench/du_e/ipoe_b/du_e/arpd_e/arpdtx_req
add wave -noupdate -group arpd /testbench/du_e/ipoe_b/du_e/arpd_e/arpdtx_rdy
add wave -noupdate -group arpd /testbench/du_e/ipoe_b/du_e/arpd_e/sparx_irdy
add wave -noupdate -group arpd /testbench/du_e/ipoe_b/du_e/arpd_e/sparx_trdy
add wave -noupdate -group arpd /testbench/du_e/ipoe_b/du_e/arpd_e/sparx_end
add wave -noupdate -group arpd /testbench/du_e/ipoe_b/du_e/arpd_e/sparx_equ
add wave -noupdate -group arpd /testbench/du_e/ipoe_b/du_e/arpd_e/tparx_vld
add wave -noupdate -group arpd /testbench/du_e/ipoe_b/du_e/arpd_e/spatx_frm
add wave -noupdate -group arpd /testbench/du_e/ipoe_b/du_e/arpd_e/spatx_irdy
add wave -noupdate -group arpd /testbench/du_e/ipoe_b/du_e/arpd_e/spatx_trdy
add wave -noupdate -group arpd /testbench/du_e/ipoe_b/du_e/arpd_e/spatx_end
add wave -noupdate -group arpd -radix hexadecimal /testbench/du_e/ipoe_b/du_e/arpd_e/spatx_data
add wave -noupdate -group arpd /testbench/du_e/ipoe_b/du_e/arpd_e/arpdtx_frm
add wave -noupdate -group arpd /testbench/du_e/ipoe_b/du_e/arpd_e/dlltx_full
add wave -noupdate -group arpd /testbench/du_e/ipoe_b/du_e/arpd_e/arpdtx_irdy
add wave -noupdate -group arpd /testbench/du_e/ipoe_b/du_e/arpd_e/arpdtx_trdy
add wave -noupdate -group arpd /testbench/du_e/ipoe_b/du_e/arpd_e/arpdtx_end
add wave -noupdate -group arpd -radix hexadecimal /testbench/du_e/ipoe_b/du_e/arpd_e/arpdtx_data
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/icmprx_frm
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/icmp_req
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/icmp_rdy
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/icmptx_frm
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/icmptx_irdy
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/icmptx_trdy
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/icmptx_end
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/metatx_end
add wave -noupdate -expand -group txt_buffer /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/rx_writ
add wave -noupdate -expand -group txt_buffer /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/rx_irdy
add wave -noupdate -expand -group txt_buffer -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/rx_data
add wave -noupdate -expand -group txt_buffer -radix hexadecimal -childformat {{/testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/tx_data(0) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/tx_data(1) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/tx_data(2) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/tx_data(3) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/tx_data(4) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/tx_data(5) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/tx_data(6) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/tx_data(7) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/tx_data(8) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/tx_data(9) -radix hexadecimal}} -subitemconfig {/testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/tx_data(0) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/tx_data(1) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/tx_data(2) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/tx_data(3) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/tx_data(4) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/tx_data(5) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/tx_data(6) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/tx_data(7) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/tx_data(8) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/tx_data(9) {-height 29 -radix hexadecimal}} /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/tx_data
add wave -noupdate -expand -group txt_buffer /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/tx_trdy
add wave -noupdate -expand -group txt_buffer /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/src_frm
add wave -noupdate -expand -group txt_buffer /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/src_end
add wave -noupdate -expand -group txt_buffer /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/src_irdy
add wave -noupdate -expand -group txt_buffer /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/src_trdy
add wave -noupdate -expand -group txt_buffer /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/do_irdy
add wave -noupdate -expand -group txt_buffer /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/dst_frm
add wave -noupdate -expand -group txt_buffer /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/dst_irdy
add wave -noupdate -expand -group txt_buffer /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/dst_trdy
add wave -noupdate -expand -group txt_buffer /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/dst_end
add wave -noupdate -expand -group txt_buffer -expand -group fifo /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/data_e/rollback
add wave -noupdate -expand -group txt_buffer -expand -group fifo /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/data_e/commit
add wave -noupdate -expand -group txt_buffer -expand -group fifo -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/data_e/wr_cntr
add wave -noupdate -expand -group txt_buffer -expand -group fifo -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/data_e/wr_ptr
add wave -noupdate -expand -group txt_buffer -expand -group fifo -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/data_e/rd_cntr
add wave -noupdate -expand -group txt_buffer -expand -group fifo /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/data_e/dst_irdy
add wave -noupdate -expand -group txt_buffer -expand -group fifo /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/data_e/dst_trdy
add wave -noupdate -expand -group txt_buffer -expand -group fifo -radix hexadecimal -childformat {{/testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/data_e/dst_data(0) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/data_e/dst_data(1) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/data_e/dst_data(2) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/data_e/dst_data(3) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/data_e/dst_data(4) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/data_e/dst_data(5) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/data_e/dst_data(6) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/data_e/dst_data(7) -radix hexadecimal}} -subitemconfig {/testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/data_e/dst_data(0) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/data_e/dst_data(1) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/data_e/dst_data(2) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/data_e/dst_data(3) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/data_e/dst_data(4) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/data_e/dst_data(5) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/data_e/dst_data(6) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/data_e/dst_data(7) {-height 29 -radix hexadecimal}} /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/data_e/dst_data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {4635427 ps} 0} {{Cursor 2} {5367624 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 282
configure wave -valuecolwidth 157
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
WaveRestoreZoom {0 ps} {10500 ns}
