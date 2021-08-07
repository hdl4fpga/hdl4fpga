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
add wave -noupdate -expand -group eth_receiver /testbench/ethrx_e/mii_clk
add wave -noupdate -expand -group eth_receiver /testbench/ethrx_e/mii_frm
add wave -noupdate -expand -group eth_receiver /testbench/ethrx_e/mii_irdy
add wave -noupdate -expand -group eth_receiver -radix hexadecimal /testbench/ethrx_e/mii_data
add wave -noupdate -expand -group eth_receiver -expand -group crc /testbench/ethrx_e/crc_equ
add wave -noupdate -expand -group eth_receiver -expand -group crc /testbench/ethrx_e/crc_sb
add wave -noupdate -expand -group eth_receiver -expand -group crc -radix hexadecimal /testbench/ethrx_e/crc_rem
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix ascii /testbench/du_e/ser_debug_e/video_b/ser_display_e/cga_codes
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
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/icmprx_frm
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/icmptyperx_frm
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/icmpcoderx_frm
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/icmpcksmrx_frm
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/icmpcksmrx_irdy
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/cksmrx_b/ci
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/cksmrx_b/adj_data
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/cksmrx_b/data
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/icmpdata_irdy
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/memrx_data
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/cksmrx_b/co
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/buffer_e/dst_irdy
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/icmprply_e/icmp_frm
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/icmprply_e/pl_irdy
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/icmprply_e/pl_trdy
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/buffer_e/wr_ptr
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/buffer_e/wr_cntr
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/dlltx_full
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/nettx_full
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/icmptx_trdy
add wave -noupdate /testbench/du_e/ipoe_b/du_e/meta_b/hwda_e/si_irdy
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/buffer_e/dst_trdy
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/buffer_e/buffer_e/buffer_e/rd_cntr
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/icmprply_e/frm_ptr
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/icmpcksmtx_frm
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/memtx_data
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/cksmtx_b/data
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/cksmtx_b/ci
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/cksmtx_b/co
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/icmpd_e/icmppltx_data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {9052800 ps} 0} {{Cursor 2} {5521883 ps} 0}
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
WaveRestoreZoom {5072507 ps} {6058795 ps}
