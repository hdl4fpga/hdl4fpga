onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/du_e/mii_rxc
add wave -noupdate /testbench/du_e/mii_rxdv
add wave -noupdate -radix hexadecimal /testbench/du_e/mii_rxd
add wave -noupdate /testbench/du_e/mii_txc
add wave -noupdate /testbench/du_e/mii_txen
add wave -noupdate -radix hexadecimal /testbench/du_e/mii_txd
add wave -noupdate /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/mii_ipoe_e/txc_rxdv
add wave -noupdate -radix hexadecimal -childformat {{/testbench/du_e/si_b/udpdaisy_e/sioudpp_e/mii_ipoe_e/txc_rxd(0) -radix hexadecimal} {/testbench/du_e/si_b/udpdaisy_e/sioudpp_e/mii_ipoe_e/txc_rxd(1) -radix hexadecimal} {/testbench/du_e/si_b/udpdaisy_e/sioudpp_e/mii_ipoe_e/txc_rxd(2) -radix hexadecimal} {/testbench/du_e/si_b/udpdaisy_e/sioudpp_e/mii_ipoe_e/txc_rxd(3) -radix hexadecimal}} -subitemconfig {/testbench/du_e/si_b/udpdaisy_e/sioudpp_e/mii_ipoe_e/txc_rxd(0) {-height 29 -radix hexadecimal} /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/mii_ipoe_e/txc_rxd(1) {-height 29 -radix hexadecimal} /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/mii_ipoe_e/txc_rxd(2) {-height 29 -radix hexadecimal} /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/mii_ipoe_e/txc_rxd(3) {-height 29 -radix hexadecimal}} /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/mii_ipoe_e/txc_rxd
add wave -noupdate -radix hexadecimal /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/mii_ipoe_e/ethrx_e/crc_e/mii_crc32
add wave -noupdate /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/mii_ipoe_e/ethrx_e/crc32_equ
add wave -noupdate /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/mii_ipoe_e/typeip4_rcvd
add wave -noupdate /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/mii_ipoe_e/myip4a_rcvd
add wave -noupdate /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/miisio_e/myport_rcvd
add wave -noupdate /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/miisio_e/udppl_rxdv
add wave -noupdate -radix hexadecimal /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/mii_ipoe_e/ethrx_e/eth_crc32
add wave -noupdate /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/buffer_p/des_irdy
add wave -noupdate /testbench/du_e/si_b/udpdaisy_e/so_frm
add wave -noupdate -radix hexadecimal /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/buffer_p/des_data
add wave -noupdate /testbench/du_e/si_b/udpdaisy_e/so_irdy
add wave -noupdate -radix hexadecimal /testbench/du_e/si_b/udpdaisy_e/so_data
add wave -noupdate -radix hexadecimal -childformat {{/testbench/du_e/si_b/siosin_e/rgtr_data(31) -radix hexadecimal} {/testbench/du_e/si_b/siosin_e/rgtr_data(30) -radix hexadecimal} {/testbench/du_e/si_b/siosin_e/rgtr_data(29) -radix hexadecimal} {/testbench/du_e/si_b/siosin_e/rgtr_data(28) -radix hexadecimal} {/testbench/du_e/si_b/siosin_e/rgtr_data(27) -radix hexadecimal} {/testbench/du_e/si_b/siosin_e/rgtr_data(26) -radix hexadecimal} {/testbench/du_e/si_b/siosin_e/rgtr_data(25) -radix hexadecimal} {/testbench/du_e/si_b/siosin_e/rgtr_data(24) -radix hexadecimal} {/testbench/du_e/si_b/siosin_e/rgtr_data(23) -radix hexadecimal} {/testbench/du_e/si_b/siosin_e/rgtr_data(22) -radix hexadecimal} {/testbench/du_e/si_b/siosin_e/rgtr_data(21) -radix hexadecimal} {/testbench/du_e/si_b/siosin_e/rgtr_data(20) -radix hexadecimal} {/testbench/du_e/si_b/siosin_e/rgtr_data(19) -radix hexadecimal} {/testbench/du_e/si_b/siosin_e/rgtr_data(18) -radix hexadecimal} {/testbench/du_e/si_b/siosin_e/rgtr_data(17) -radix hexadecimal} {/testbench/du_e/si_b/siosin_e/rgtr_data(16) -radix hexadecimal} {/testbench/du_e/si_b/siosin_e/rgtr_data(15) -radix hexadecimal} {/testbench/du_e/si_b/siosin_e/rgtr_data(14) -radix hexadecimal} {/testbench/du_e/si_b/siosin_e/rgtr_data(13) -radix hexadecimal} {/testbench/du_e/si_b/siosin_e/rgtr_data(12) -radix hexadecimal} {/testbench/du_e/si_b/siosin_e/rgtr_data(11) -radix hexadecimal} {/testbench/du_e/si_b/siosin_e/rgtr_data(10) -radix hexadecimal} {/testbench/du_e/si_b/siosin_e/rgtr_data(9) -radix hexadecimal} {/testbench/du_e/si_b/siosin_e/rgtr_data(8) -radix hexadecimal} {/testbench/du_e/si_b/siosin_e/rgtr_data(7) -radix hexadecimal} {/testbench/du_e/si_b/siosin_e/rgtr_data(6) -radix hexadecimal} {/testbench/du_e/si_b/siosin_e/rgtr_data(5) -radix hexadecimal} {/testbench/du_e/si_b/siosin_e/rgtr_data(4) -radix hexadecimal} {/testbench/du_e/si_b/siosin_e/rgtr_data(3) -radix hexadecimal} {/testbench/du_e/si_b/siosin_e/rgtr_data(2) -radix hexadecimal} {/testbench/du_e/si_b/siosin_e/rgtr_data(1) -radix hexadecimal} {/testbench/du_e/si_b/siosin_e/rgtr_data(0) -radix hexadecimal}} -subitemconfig {/testbench/du_e/si_b/siosin_e/rgtr_data(31) {-height 29 -radix hexadecimal} /testbench/du_e/si_b/siosin_e/rgtr_data(30) {-height 29 -radix hexadecimal} /testbench/du_e/si_b/siosin_e/rgtr_data(29) {-height 29 -radix hexadecimal} /testbench/du_e/si_b/siosin_e/rgtr_data(28) {-height 29 -radix hexadecimal} /testbench/du_e/si_b/siosin_e/rgtr_data(27) {-height 29 -radix hexadecimal} /testbench/du_e/si_b/siosin_e/rgtr_data(26) {-height 29 -radix hexadecimal} /testbench/du_e/si_b/siosin_e/rgtr_data(25) {-height 29 -radix hexadecimal} /testbench/du_e/si_b/siosin_e/rgtr_data(24) {-height 29 -radix hexadecimal} /testbench/du_e/si_b/siosin_e/rgtr_data(23) {-height 29 -radix hexadecimal} /testbench/du_e/si_b/siosin_e/rgtr_data(22) {-height 29 -radix hexadecimal} /testbench/du_e/si_b/siosin_e/rgtr_data(21) {-height 29 -radix hexadecimal} /testbench/du_e/si_b/siosin_e/rgtr_data(20) {-height 29 -radix hexadecimal} /testbench/du_e/si_b/siosin_e/rgtr_data(19) {-height 29 -radix hexadecimal} /testbench/du_e/si_b/siosin_e/rgtr_data(18) {-height 29 -radix hexadecimal} /testbench/du_e/si_b/siosin_e/rgtr_data(17) {-height 29 -radix hexadecimal} /testbench/du_e/si_b/siosin_e/rgtr_data(16) {-height 29 -radix hexadecimal} /testbench/du_e/si_b/siosin_e/rgtr_data(15) {-height 29 -radix hexadecimal} /testbench/du_e/si_b/siosin_e/rgtr_data(14) {-height 29 -radix hexadecimal} /testbench/du_e/si_b/siosin_e/rgtr_data(13) {-height 29 -radix hexadecimal} /testbench/du_e/si_b/siosin_e/rgtr_data(12) {-height 29 -radix hexadecimal} /testbench/du_e/si_b/siosin_e/rgtr_data(11) {-height 29 -radix hexadecimal} /testbench/du_e/si_b/siosin_e/rgtr_data(10) {-height 29 -radix hexadecimal} /testbench/du_e/si_b/siosin_e/rgtr_data(9) {-height 29 -radix hexadecimal} /testbench/du_e/si_b/siosin_e/rgtr_data(8) {-height 29 -radix hexadecimal} /testbench/du_e/si_b/siosin_e/rgtr_data(7) {-height 29 -radix hexadecimal} /testbench/du_e/si_b/siosin_e/rgtr_data(6) {-height 29 -radix hexadecimal} /testbench/du_e/si_b/siosin_e/rgtr_data(5) {-height 29 -radix hexadecimal} /testbench/du_e/si_b/siosin_e/rgtr_data(4) {-height 29 -radix hexadecimal} /testbench/du_e/si_b/siosin_e/rgtr_data(3) {-height 29 -radix hexadecimal} /testbench/du_e/si_b/siosin_e/rgtr_data(2) {-height 29 -radix hexadecimal} /testbench/du_e/si_b/siosin_e/rgtr_data(1) {-height 29 -radix hexadecimal} /testbench/du_e/si_b/siosin_e/rgtr_data(0) {-height 29 -radix hexadecimal}} /testbench/du_e/si_b/siosin_e/rgtr_data
add wave -noupdate -radix hexadecimal /testbench/du_e/si_b/siosin_e/rgtr_dv
add wave -noupdate -radix hexadecimal /testbench/du_e/si_b/siosin_e/rgtr_id
add wave -noupdate -radix hexadecimal -childformat {{/testbench/du_e/dmaio_addr(24) -radix hexadecimal} {/testbench/du_e/dmaio_addr(23) -radix hexadecimal} {/testbench/du_e/dmaio_addr(22) -radix hexadecimal} {/testbench/du_e/dmaio_addr(21) -radix hexadecimal} {/testbench/du_e/dmaio_addr(20) -radix hexadecimal} {/testbench/du_e/dmaio_addr(19) -radix hexadecimal} {/testbench/du_e/dmaio_addr(18) -radix hexadecimal} {/testbench/du_e/dmaio_addr(17) -radix hexadecimal} {/testbench/du_e/dmaio_addr(16) -radix hexadecimal} {/testbench/du_e/dmaio_addr(15) -radix hexadecimal} {/testbench/du_e/dmaio_addr(14) -radix hexadecimal} {/testbench/du_e/dmaio_addr(13) -radix hexadecimal} {/testbench/du_e/dmaio_addr(12) -radix hexadecimal} {/testbench/du_e/dmaio_addr(11) -radix hexadecimal} {/testbench/du_e/dmaio_addr(10) -radix hexadecimal} {/testbench/du_e/dmaio_addr(9) -radix hexadecimal} {/testbench/du_e/dmaio_addr(8) -radix hexadecimal} {/testbench/du_e/dmaio_addr(7) -radix hexadecimal} {/testbench/du_e/dmaio_addr(6) -radix hexadecimal} {/testbench/du_e/dmaio_addr(5) -radix hexadecimal} {/testbench/du_e/dmaio_addr(4) -radix hexadecimal} {/testbench/du_e/dmaio_addr(3) -radix hexadecimal} {/testbench/du_e/dmaio_addr(2) -radix hexadecimal}} -subitemconfig {/testbench/du_e/dmaio_addr(24) {-height 29 -radix hexadecimal} /testbench/du_e/dmaio_addr(23) {-height 29 -radix hexadecimal} /testbench/du_e/dmaio_addr(22) {-height 29 -radix hexadecimal} /testbench/du_e/dmaio_addr(21) {-height 29 -radix hexadecimal} /testbench/du_e/dmaio_addr(20) {-height 29 -radix hexadecimal} /testbench/du_e/dmaio_addr(19) {-height 29 -radix hexadecimal} /testbench/du_e/dmaio_addr(18) {-height 29 -radix hexadecimal} /testbench/du_e/dmaio_addr(17) {-height 29 -radix hexadecimal} /testbench/du_e/dmaio_addr(16) {-height 29 -radix hexadecimal} /testbench/du_e/dmaio_addr(15) {-height 29 -radix hexadecimal} /testbench/du_e/dmaio_addr(14) {-height 29 -radix hexadecimal} /testbench/du_e/dmaio_addr(13) {-height 29 -radix hexadecimal} /testbench/du_e/dmaio_addr(12) {-height 29 -radix hexadecimal} /testbench/du_e/dmaio_addr(11) {-height 29 -radix hexadecimal} /testbench/du_e/dmaio_addr(10) {-height 29 -radix hexadecimal} /testbench/du_e/dmaio_addr(9) {-height 29 -radix hexadecimal} /testbench/du_e/dmaio_addr(8) {-height 29 -radix hexadecimal} /testbench/du_e/dmaio_addr(7) {-height 29 -radix hexadecimal} /testbench/du_e/dmaio_addr(6) {-height 29 -radix hexadecimal} /testbench/du_e/dmaio_addr(5) {-height 29 -radix hexadecimal} /testbench/du_e/dmaio_addr(4) {-height 29 -radix hexadecimal} /testbench/du_e/dmaio_addr(3) {-height 29 -radix hexadecimal} /testbench/du_e/dmaio_addr(2) {-height 29 -radix hexadecimal}} /testbench/du_e/dmaio_addr
add wave -noupdate -radix hexadecimal /testbench/du_e/dmaio_len
add wave -noupdate /testbench/du_e/sio_clk
add wave -noupdate /testbench/du_e/si_b/dmaaddr_e/dst_clk
add wave -noupdate /testbench/du_e/si_b/dmaaddr_e/dst_mode
add wave -noupdate /testbench/du_e/si_b/dmaaddr_e/dst_frm
add wave -noupdate -radix hexadecimal /testbench/du_e/si_b/dmaaddr_e/dst_data
add wave -noupdate /testbench/du_e/si_b/dmaaddr_e/dst_irdy
add wave -noupdate /testbench/du_e/dmacfgio_req
add wave -noupdate /testbench/du_e/si_b/dmaaddr_e/dst_trdy
add wave -noupdate /testbench/du_e/dmacfgio_rdy
add wave -noupdate /testbench/du_e/dmaio_req
add wave -noupdate /testbench/du_e/dmaio_rdy
add wave -noupdate -divider dmadata
add wave -noupdate /testbench/du_e/si_b/dmadata_e/src_frm
add wave -noupdate /testbench/du_e/si_b/dmadata_e/src_irdy
add wave -noupdate /testbench/du_e/si_b/dmadata_e/src_trdy
add wave -noupdate -radix hexadecimal /testbench/du_e/si_b/dmadata_e/wr_cntr
add wave -noupdate -radix hexadecimal /testbench/du_e/si_b/dmadata_e/rd_cntr
add wave -noupdate /testbench/du_e/si_b/dmadata_e/dst_irdy
add wave -noupdate /testbench/du_e/si_b/dmadata_e/dst_irdy1
add wave -noupdate /testbench/du_e/si_b/dmadata_e/feed_ena
add wave -noupdate -divider {graphics controller}
add wave -noupdate /testbench/du_e/dmacfg_clk
add wave -noupdate /testbench/du_e/dmacfgvideo_req
add wave -noupdate /testbench/du_e/dmacfgvideo_rdy
add wave -noupdate /testbench/du_e/dmavideo_req
add wave -noupdate /testbench/du_e/dmavideo_rdy
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/adapter_b/graphics_e/mydma_rdy
add wave -noupdate /testbench/du_e/adapter_b/graphics_e/vt_req
add wave -noupdate /testbench/du_e/adapter_b/graphics_e/hz_req
add wave -noupdate /testbench/du_e/adapter_b/sync_e/video_hzon
add wave -noupdate /testbench/du_e/adapter_b/graphics_e/dma_req
add wave -noupdate /testbench/du_e/adapter_b/graphics_e/dma_rdy
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/dmacfg_req(0)
add wave -noupdate /testbench/du_e/dmacfg_rdy(0)
add wave -noupdate -expand /testbench/du_e/dmacfg_req
add wave -noupdate -expand /testbench/du_e/dmacfg_rdy
add wave -noupdate -radix unsigned /testbench/du_e/dmavideo_len
add wave -noupdate -radix hexadecimal /testbench/du_e/dmavideo_addr
add wave -noupdate /testbench/du_e/dmacfgio_req
add wave -noupdate /testbench/du_e/dmaio_trdy
add wave -noupdate /testbench/du_e/dmacfgio_rdy
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/dmaio_req
add wave -noupdate /testbench/du_e/dmaio_rdy
add wave -noupdate /testbench/du_e/ctlr_clk
add wave -noupdate /testbench/du_e/ctlr_di_req
add wave -noupdate /testbench/du_e/ctlr_di_dv
add wave -noupdate -radix hexadecimal /testbench/du_e/ctlr_di
add wave -noupdate /testbench/du_e/dmacfg_req(0)
add wave -noupdate /testbench/du_e/dmacfg_rdy(0)
add wave -noupdate -radix hexadecimal -childformat {{/testbench/du_e/ddr_a(12) -radix hexadecimal} {/testbench/du_e/ddr_a(11) -radix hexadecimal} {/testbench/du_e/ddr_a(10) -radix hexadecimal} {/testbench/du_e/ddr_a(9) -radix hexadecimal} {/testbench/du_e/ddr_a(8) -radix hexadecimal} {/testbench/du_e/ddr_a(7) -radix hexadecimal} {/testbench/du_e/ddr_a(6) -radix hexadecimal} {/testbench/du_e/ddr_a(5) -radix hexadecimal} {/testbench/du_e/ddr_a(4) -radix hexadecimal} {/testbench/du_e/ddr_a(3) -radix hexadecimal} {/testbench/du_e/ddr_a(2) -radix hexadecimal} {/testbench/du_e/ddr_a(1) -radix hexadecimal} {/testbench/du_e/ddr_a(0) -radix hexadecimal}} -subitemconfig {/testbench/du_e/ddr_a(12) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(11) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(10) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(9) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(8) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(7) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(6) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(5) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(4) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(3) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(2) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(1) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(0) {-height 29 -radix hexadecimal}} /testbench/du_e/ddr_a
add wave -noupdate -expand /testbench/du_e/ddr_dqs
add wave -noupdate -radix hexadecimal -childformat {{/testbench/du_e/ddr_dq(15) -radix hexadecimal} {/testbench/du_e/ddr_dq(14) -radix hexadecimal} {/testbench/du_e/ddr_dq(13) -radix hexadecimal} {/testbench/du_e/ddr_dq(12) -radix hexadecimal} {/testbench/du_e/ddr_dq(11) -radix hexadecimal} {/testbench/du_e/ddr_dq(10) -radix hexadecimal} {/testbench/du_e/ddr_dq(9) -radix hexadecimal} {/testbench/du_e/ddr_dq(8) -radix hexadecimal} {/testbench/du_e/ddr_dq(7) -radix hexadecimal} {/testbench/du_e/ddr_dq(6) -radix hexadecimal} {/testbench/du_e/ddr_dq(5) -radix hexadecimal} {/testbench/du_e/ddr_dq(4) -radix hexadecimal} {/testbench/du_e/ddr_dq(3) -radix hexadecimal} {/testbench/du_e/ddr_dq(2) -radix hexadecimal} {/testbench/du_e/ddr_dq(1) -radix hexadecimal} {/testbench/du_e/ddr_dq(0) -radix hexadecimal}} -subitemconfig {/testbench/du_e/ddr_dq(15) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_dq(14) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_dq(13) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_dq(12) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_dq(11) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_dq(10) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_dq(9) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_dq(8) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_dq(7) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_dq(6) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_dq(5) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_dq(4) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_dq(3) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_dq(2) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_dq(1) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_dq(0) {-height 29 -radix hexadecimal}} /testbench/du_e/ddr_dq
add wave -noupdate /testbench/du_e/ddr_ras
add wave -noupdate /testbench/du_e/ddr_cas
add wave -noupdate /testbench/du_e/ddr_we
add wave -noupdate /testbench/du_e/ddr_ba
add wave -noupdate /testbench/du_e/ddr_ckp
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 fs} 0}
quietly wave cursor active 0
configure wave -namecolwidth 249
configure wave -valuecolwidth 165
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
WaveRestoreZoom {247863070010 fs} {251964632570 fs}
