onerror {resume}
quietly virtual signal -install /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_b/col_e { /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_b/col_e/wr_cntr(1 to 3)} wr
quietly virtual signal -install /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_b/col_e { /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_b/col_e/rd_cntr(1 to 3)} rd
quietly virtual signal -install /testbench/du_e/grahics_e { (context /testbench/du_e/grahics_e )( sout_data(7) & sout_data(6) & sout_data(5) & sout_data(4) & sout_data(3) & sout_data(2) & sout_data(1) & sout_data(0) )} pp
quietly virtual signal -install /testbench/du_e/grahics_e { (context /testbench/du_e/grahics_e )( sout_data(7) & sout_data(6) & sout_data(5) & sout_data(4) & sout_data(3) & sout_data(2) & sout_data(1) & sout_data(0) )} soddata
quietly virtual signal -install /testbench/du_e/grahics_e { (context /testbench/du_e/grahics_e )( sin_data(7) & sin_data(6) & sin_data(5) & sin_data(4) & sin_data(3) & sin_data(2) & sin_data(1) & sin_data(0) )} sin_rdata
quietly virtual signal -install /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e { (context /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e )( tag_data(7) & tag_data(6) & tag_data(5) & tag_data(4) & tag_data(3) & tag_data(2) & tag_data(1) & tag_data(0) )} tag_rdata
quietly virtual signal -install /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e { (context /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e )( plrx_data(7) & plrx_data(6) & plrx_data(5) & plrx_data(4) & plrx_data(3) & plrx_data(2) & plrx_data(1) & plrx_data(0) )} plrx_rdata
quietly virtual signal -install /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e { (context /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e )( so_data(7) & so_data(6) & so_data(5) & so_data(4) & so_data(3) & so_data(2) & so_data(1) & so_data(0) )} so_rdata
quietly virtual signal -install /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/sio_flow_e { (context /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/sio_flow_e )( rx_data(7) & rx_data(6) & rx_data(5) & rx_data(4) & rx_data(3) & rx_data(2) & rx_data(1) & rx_data(0) )} so_rdata
quietly virtual signal -install /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/fifo_e { (context /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/fifo_e )( src_data(7) & src_data(6) & src_data(5) & src_data(4) & src_data(3) & src_data(2) & src_data(1) & src_data(0) )} src_rdata
quietly virtual signal -install /testbench/du_e/grahics_e { (context /testbench/du_e/grahics_e )( sout_data(7) & sout_data(6) & sout_data(5) & sout_data(4) & sout_data(3) & sout_data(2) & sout_data(1) & sout_data(0) )} sout_rdata
quietly virtual signal -install /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ethtx_e { (context /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ethtx_e )( mii_data(7) & mii_data(6) & mii_data(5) & mii_data(4) & mii_data(3) & mii_data(2) & mii_data(1) & mii_data(0) )} mii_rdata
quietly virtual signal -install /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/fifo_e { /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/fifo_e/tx_data(0 to 11)} tx_rdata
quietly virtual signal -install /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/icmpd_e/buffer_e/buffer_e { /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/icmpd_e/buffer_e/buffer_e/tx_data(0 to 4)} tx_rdata
quietly virtual signal -install /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/icmpd_e { (context /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/icmpd_e )( icmptx_data(7) & icmptx_data(6) & icmptx_data(5) & icmptx_data(4) & icmptx_data(3) & icmptx_data(2) & icmptx_data(1) & icmptx_data(0) )} xxx
quietly virtual signal -install /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/icmpd_e/buffer_e/buffer_e { (context /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/icmpd_e/buffer_e/buffer_e )( tx_data(8) & tx_data(7) & tx_data(6) & tx_data(5) & tx_data(4) & tx_data(3) & tx_data(2) & tx_data(1) & tx_data(0) )} xxx
quietly virtual signal -install /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/icmpd_e/buffer_e/buffer_e { /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/icmpd_e/buffer_e/buffer_e/rx_data(0 to 8)} xxxx
quietly virtual signal -install /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/icmpd_e/buffer_e/buffer_e { (context /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/icmpd_e/buffer_e/buffer_e )( rx_data(8) & rx_data(7) & rx_data(6) & rx_data(5) & rx_data(4) & rx_data(3) & rx_data(2) & rx_data(1) & rx_data(0) )} xxx001
quietly virtual signal -install /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/icmpd_e/buffer_e/buffer_e { /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/icmpd_e/buffer_e/buffer_e/rx_data(0 to 8)} rx_rdata
quietly virtual signal -install /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/icmpd_e/buffer_e/buffer_e { /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/icmpd_e/buffer_e/buffer_e/tx_data(0 to 8)} tx_rdata001
quietly virtual signal -install /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/fifo_e { (context /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/fifo_e )( tx_data(11) & tx_data(10) & tx_data(9) & tx_data(8) & tx_data(7) & tx_data(6) & tx_data(5) & tx_data(4) & tx_data(3) & tx_data(2) & tx_data(1) & tx_data(0) )} tx_rdata001
quietly WaveActivateNextPane {} 0
add wave -noupdate -group ethrx_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ethtx_e/mii_frm
add wave -noupdate -group ethrx_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ethtx_e/mii_end
add wave -noupdate -group ethrx_e -label mii_data -radix hexadecimal /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ethtx_e/mii_rdata
add wave -noupdate -group ethrx_e /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/refreq
add wave -noupdate -group ethrx_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/miirx_frm
add wave -noupdate -group ethrx_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/miirx_irdy
add wave -noupdate -group ethrx_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/miirx_trdy
add wave -noupdate -group ethrx_e -label miirx_data -radix hexadecimal -childformat {{/testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/icmpd_e/xxx(7) -radix hexadecimal} {/testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/icmpd_e/xxx(6) -radix hexadecimal} {/testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/icmpd_e/xxx(5) -radix hexadecimal} {/testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/icmpd_e/xxx(4) -radix hexadecimal} {/testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/icmpd_e/xxx(3) -radix hexadecimal} {/testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/icmpd_e/xxx(2) -radix hexadecimal} {/testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/icmpd_e/xxx(1) -radix hexadecimal} {/testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/icmpd_e/xxx(0) -radix hexadecimal}} -subitemconfig {/testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/icmpd_e/icmptx_data(7) {-radix hexadecimal} /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/icmpd_e/icmptx_data(6) {-radix hexadecimal} /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/icmpd_e/icmptx_data(5) {-radix hexadecimal} /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/icmpd_e/icmptx_data(4) {-radix hexadecimal} /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/icmpd_e/icmptx_data(3) {-radix hexadecimal} /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/icmpd_e/icmptx_data(2) {-radix hexadecimal} /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/icmpd_e/icmptx_data(1) {-radix hexadecimal} /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/icmpd_e/icmptx_data(0) {-radix hexadecimal}} /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/icmpd_e/xxx
add wave -noupdate -divider {New Divider}
add wave -noupdate -expand -group mii_rx /testbench/du_e/e_rx_clk
add wave -noupdate -expand -group mii_rx /testbench/du_e/e_rx_dv
add wave -noupdate -expand -group mii_rx -radix hexadecimal /testbench/du_e/e_rxd
add wave -noupdate -expand -group mii_tx /testbench/du_e/e_tx_clk
add wave -noupdate -expand -group mii_tx /testbench/du_e/e_txen
add wave -noupdate -expand -group mii_tx -radix hexadecimal /testbench/du_e/e_txd
add wave -noupdate -expand -group ddr /testbench/du_e/sd_ck_p
add wave -noupdate -expand -group ddr /testbench/du_e/sd_cs
add wave -noupdate -expand -group ddr /testbench/du_e/sd_cke
add wave -noupdate -expand -group ddr /testbench/du_e/sd_ras
add wave -noupdate -expand -group ddr /testbench/du_e/sd_cas
add wave -noupdate -expand -group ddr /testbench/du_e/sd_we
add wave -noupdate -expand -group ddr /testbench/du_e/sd_ba
add wave -noupdate -expand -group ddr -radix hexadecimal /testbench/du_e/sd_a
add wave -noupdate -expand -group ddr /testbench/du_e/sd_dqs
add wave -noupdate -expand -group ddr -radix hexadecimal /testbench/du_e/sd_dq
add wave -noupdate -expand -group ddr /testbench/du_e/sd_dm
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/clk0
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/sdrctlr_b/sdrctlr_e/ctlr_do_dv(0)
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/sdrctlr_b/sdrctlr_e/ctlr_do
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {138582500 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 218
configure wave -valuecolwidth 186
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
WaveRestoreZoom {138449273 ps} {139638727 ps}
