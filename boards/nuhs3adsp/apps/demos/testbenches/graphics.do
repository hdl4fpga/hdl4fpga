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
quietly virtual signal -install /testbench/ethrx_e {/testbench/ethrx_e/mii_data  } mii_rdata
quietly virtual signal -install /testbench/ethrx_e {/testbench/ethrx_e/mii_rdata  } mii_rdata001
quietly virtual signal -install /testbench/ethrx_e { (context /testbench/ethrx_e )( mii_data(3) & mii_data(2) & mii_data(1) & mii_data(0) )} mii_rdata002
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
add wave -noupdate -divider {New Divider}
add wave -noupdate -expand -group mii_rx /testbench/du_e/mii_rxc
add wave -noupdate -expand -group mii_rx /testbench/du_e/mii_rxdv
add wave -noupdate -expand -group mii_rx -radix hexadecimal /testbench/du_e/mii_rxd
add wave -noupdate -group mii_tx /testbench/du_e/mii_txc
add wave -noupdate -group mii_tx /testbench/du_e/mii_txen
add wave -noupdate -group mii_tx -radix hexadecimal /testbench/du_e/mii_txd
add wave -noupdate -group ddr /testbench/du_e/ddr_ckp
add wave -noupdate -group ddr /testbench/du_e/ddr_cs
add wave -noupdate -group ddr /testbench/du_e/ddr_cke
add wave -noupdate -group ddr -divider {New Divider}
add wave -noupdate -group ddr /testbench/du_e/ddr_ras
add wave -noupdate -group ddr /testbench/du_e/ddr_cas
add wave -noupdate -group ddr /testbench/du_e/ddr_we
add wave -noupdate -group ddr -radix hexadecimal /testbench/du_e/ddr_ba
add wave -noupdate -group ddr -radix hexadecimal -childformat {{/testbench/du_e/ddr_a(12) -radix hexadecimal} {/testbench/du_e/ddr_a(11) -radix hexadecimal} {/testbench/du_e/ddr_a(10) -radix hexadecimal} {/testbench/du_e/ddr_a(9) -radix hexadecimal} {/testbench/du_e/ddr_a(8) -radix hexadecimal} {/testbench/du_e/ddr_a(7) -radix hexadecimal} {/testbench/du_e/ddr_a(6) -radix hexadecimal} {/testbench/du_e/ddr_a(5) -radix hexadecimal} {/testbench/du_e/ddr_a(4) -radix hexadecimal} {/testbench/du_e/ddr_a(3) -radix hexadecimal} {/testbench/du_e/ddr_a(2) -radix hexadecimal} {/testbench/du_e/ddr_a(1) -radix hexadecimal} {/testbench/du_e/ddr_a(0) -radix hexadecimal}} -subitemconfig {/testbench/du_e/ddr_a(12) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(11) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(10) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(9) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(8) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(7) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(6) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(5) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(4) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(3) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(2) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(1) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(0) {-height 29 -radix hexadecimal}} /testbench/du_e/ddr_a
add wave -noupdate -group ddr -divider {New Divider}
add wave -noupdate -group ddr -expand /testbench/du_e/ddr_dqs
add wave -noupdate -group ddr -radix hexadecimal /testbench/du_e/ddr_dq
add wave -noupdate -group ddr /testbench/du_e/ddr_st_dqs
add wave -noupdate -group ddr /testbench/du_e/ddr_st_lp_dqs
add wave -noupdate -divider {New Divider}
add wave -noupdate -group ethrx_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ethtx_e/mii_frm
add wave -noupdate -group ethrx_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ethtx_e/mii_end
add wave -noupdate -group ethrx_e -label mii_data -radix hexadecimal /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ethtx_e/mii_rdata
add wave -noupdate -group ethrx_e /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_refreq
add wave -noupdate -group ethrx_e /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/refreq
add wave -noupdate -group ethrx_e /testbench/ethrx_e/mii_clk
add wave -noupdate -group ethrx_e -label mii_data -radix hexadecimal /testbench/ethrx_e/mii_rdata002
add wave -noupdate -group ethrx_e /testbench/ethrx_e/fcs_sb
add wave -noupdate -group ethrx_e /testbench/ethrx_e/fcs_vld
add wave -noupdate -group ethrx_e -radix hexadecimal /testbench/ethrx_e/fcs_rem
add wave -noupdate -group ethrx_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/miirx_frm
add wave -noupdate -group ethrx_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/miirx_irdy
add wave -noupdate -group ethrx_e /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/miirx_trdy
add wave -noupdate -group ethrx_e -label miirx_data -radix hexadecimal -childformat {{/testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/icmpd_e/xxx(7) -radix hexadecimal} {/testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/icmpd_e/xxx(6) -radix hexadecimal} {/testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/icmpd_e/xxx(5) -radix hexadecimal} {/testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/icmpd_e/xxx(4) -radix hexadecimal} {/testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/icmpd_e/xxx(3) -radix hexadecimal} {/testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/icmpd_e/xxx(2) -radix hexadecimal} {/testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/icmpd_e/xxx(1) -radix hexadecimal} {/testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/icmpd_e/xxx(0) -radix hexadecimal}} -subitemconfig {/testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/icmpd_e/icmptx_data(7) {-radix hexadecimal} /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/icmpd_e/icmptx_data(6) {-radix hexadecimal} /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/icmpd_e/icmptx_data(5) {-radix hexadecimal} /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/icmpd_e/icmptx_data(4) {-radix hexadecimal} /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/icmpd_e/icmptx_data(3) {-radix hexadecimal} /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/icmpd_e/icmptx_data(2) {-radix hexadecimal} /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/icmpd_e/icmptx_data(1) {-radix hexadecimal} /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/icmpd_e/icmptx_data(0) {-radix hexadecimal}} /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/icmpd_e/xxx
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/ddrphy_e/phy_sto(3)
add wave -noupdate /testbench/du_e/ddrphy_e/phy_dqso(3)
add wave -noupdate -expand -group ddrctlr /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/strx_lat
add wave -noupdate -expand -group ddrctlr /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/rwnx_lat
add wave -noupdate -expand -group ddrctlr /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/dqszx_lat
add wave -noupdate -expand -group ddrctlr /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/dqsx_lat
add wave -noupdate -expand -group ddrctlr /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/dqzx_lat
add wave -noupdate -expand -group ddrctlr /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/rdfifo_lat
add wave -noupdate -expand -group ddrctlr /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/lwr
add wave -noupdate -expand -group ddrctlr /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/lrcd
add wave -noupdate -expand -group ddrctlr /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/lrfc
add wave -noupdate -expand -group ddrctlr /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/lrp
add wave -noupdate -expand -group ddrctlr /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/wwnx_lat
add wave -noupdate -expand -group ddrctlr /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/wid_lat
add wave -noupdate -radix hexadecimal /testbench/du_e/ddrphy_e/phy_sto
add wave -noupdate -expand /testbench/du_e/ddrphy_e/phy_dqso
add wave -noupdate -radix hexadecimal -childformat {{/testbench/du_e/ddrphy_e/phy_dqo(31) -radix hexadecimal} {/testbench/du_e/ddrphy_e/phy_dqo(30) -radix hexadecimal} {/testbench/du_e/ddrphy_e/phy_dqo(29) -radix hexadecimal} {/testbench/du_e/ddrphy_e/phy_dqo(28) -radix hexadecimal} {/testbench/du_e/ddrphy_e/phy_dqo(27) -radix hexadecimal} {/testbench/du_e/ddrphy_e/phy_dqo(26) -radix hexadecimal} {/testbench/du_e/ddrphy_e/phy_dqo(25) -radix hexadecimal} {/testbench/du_e/ddrphy_e/phy_dqo(24) -radix hexadecimal} {/testbench/du_e/ddrphy_e/phy_dqo(23) -radix hexadecimal} {/testbench/du_e/ddrphy_e/phy_dqo(22) -radix hexadecimal} {/testbench/du_e/ddrphy_e/phy_dqo(21) -radix hexadecimal} {/testbench/du_e/ddrphy_e/phy_dqo(20) -radix hexadecimal} {/testbench/du_e/ddrphy_e/phy_dqo(19) -radix hexadecimal} {/testbench/du_e/ddrphy_e/phy_dqo(18) -radix hexadecimal} {/testbench/du_e/ddrphy_e/phy_dqo(17) -radix hexadecimal} {/testbench/du_e/ddrphy_e/phy_dqo(16) -radix hexadecimal} {/testbench/du_e/ddrphy_e/phy_dqo(15) -radix hexadecimal} {/testbench/du_e/ddrphy_e/phy_dqo(14) -radix hexadecimal} {/testbench/du_e/ddrphy_e/phy_dqo(13) -radix hexadecimal} {/testbench/du_e/ddrphy_e/phy_dqo(12) -radix hexadecimal} {/testbench/du_e/ddrphy_e/phy_dqo(11) -radix hexadecimal} {/testbench/du_e/ddrphy_e/phy_dqo(10) -radix hexadecimal} {/testbench/du_e/ddrphy_e/phy_dqo(9) -radix hexadecimal} {/testbench/du_e/ddrphy_e/phy_dqo(8) -radix hexadecimal} {/testbench/du_e/ddrphy_e/phy_dqo(7) -radix hexadecimal} {/testbench/du_e/ddrphy_e/phy_dqo(6) -radix hexadecimal} {/testbench/du_e/ddrphy_e/phy_dqo(5) -radix hexadecimal} {/testbench/du_e/ddrphy_e/phy_dqo(4) -radix hexadecimal} {/testbench/du_e/ddrphy_e/phy_dqo(3) -radix hexadecimal} {/testbench/du_e/ddrphy_e/phy_dqo(2) -radix hexadecimal} {/testbench/du_e/ddrphy_e/phy_dqo(1) -radix hexadecimal} {/testbench/du_e/ddrphy_e/phy_dqo(0) -radix hexadecimal}} -subitemconfig {/testbench/du_e/ddrphy_e/phy_dqo(31) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/phy_dqo(30) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/phy_dqo(29) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/phy_dqo(28) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/phy_dqo(27) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/phy_dqo(26) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/phy_dqo(25) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/phy_dqo(24) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/phy_dqo(23) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/phy_dqo(22) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/phy_dqo(21) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/phy_dqo(20) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/phy_dqo(19) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/phy_dqo(18) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/phy_dqo(17) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/phy_dqo(16) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/phy_dqo(15) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/phy_dqo(14) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/phy_dqo(13) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/phy_dqo(12) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/phy_dqo(11) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/phy_dqo(10) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/phy_dqo(9) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/phy_dqo(8) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/phy_dqo(7) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/phy_dqo(6) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/phy_dqo(5) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/phy_dqo(4) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/phy_dqo(3) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/phy_dqo(2) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/phy_dqo(1) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/phy_dqo(0) {-height 29 -radix hexadecimal}} /testbench/du_e/ddrphy_e/phy_dqo
add wave -noupdate /testbench/du_e/ddrphy_e/clk0
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do_dv
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {153576325 ps} 0} {{Cursor 2} {155114409 ps} 0}
quietly wave cursor active 2
configure wave -namecolwidth 218
configure wave -valuecolwidth 219
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
WaveRestoreZoom {155055321 ps} {155108713 ps}
