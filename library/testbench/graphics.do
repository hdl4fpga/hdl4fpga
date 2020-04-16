onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/du_e/xtal
add wave -noupdate /testbench/du_e/mii_rxc
add wave -noupdate /testbench/du_e/mii_rxdv
add wave -noupdate -radix hexadecimal /testbench/du_e/mii_txd
add wave -noupdate /testbench/du_e/ddrsys_clks
add wave -noupdate /testbench/du_e/dmactlr_e/ctlr_act
add wave -noupdate /testbench/du_e/dmactlr_e/dmatrans_e/s1
add wave -noupdate /testbench/du_e/dmactlr_e/dmatrans_e/ctlr_pre
add wave -noupdate /testbench/du_e/dmactlr_e/dmatrans_e/ctlr_idl
add wave -noupdate -radix hexadecimal /testbench/du_e/dmactlr_e/ctlr_a
add wave -noupdate /testbench/du_e/ddrctlr_e/ctlr_refreq
add wave -noupdate /testbench/du_e/ddr_st_lp_dqs
add wave -noupdate /testbench/du_e/ddr_st_dqs
add wave -noupdate /testbench/du_e/graphics_e/vram_e/mem_e/rd_clk
add wave -noupdate /testbench/du_e/graphics_e/vram_e/mem_e/rd_addr
add wave -noupdate /testbench/du_e/graphics_e/vram_e/mem_e/rd_data
add wave -noupdate /testbench/du_e/graphics_e/vram_e/mem_e/wr_clk
add wave -noupdate /testbench/du_e/graphics_e/vram_e/mem_e/wr_ena
add wave -noupdate /testbench/du_e/graphics_e/vram_e/mem_e/wr_addr
add wave -noupdate /testbench/du_e/graphics_e/vram_e/mem_e/wr_data
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/scopeio_export_b/dmadata_e/dst_clk
add wave -noupdate /testbench/du_e/scopeio_export_b/dmadata_e/dst_irdy
add wave -noupdate /testbench/du_e/scopeio_export_b/dmadata_e/dst_trdy
add wave -noupdate /testbench/du_e/dmacfgio_req
add wave -noupdate /testbench/du_e/dmacfgio_rdy
add wave -noupdate /testbench/du_e/dmaio_req
add wave -noupdate /testbench/du_e/dmaio_rdy
add wave -noupdate /testbench/du_e/dmaio_dv
add wave -noupdate -radix hexadecimal -childformat {{/testbench/du_e/dmaio_addr(25) -radix hexadecimal} {/testbench/du_e/dmaio_addr(24) -radix hexadecimal} {/testbench/du_e/dmaio_addr(23) -radix hexadecimal} {/testbench/du_e/dmaio_addr(22) -radix hexadecimal} {/testbench/du_e/dmaio_addr(21) -radix hexadecimal} {/testbench/du_e/dmaio_addr(20) -radix hexadecimal} {/testbench/du_e/dmaio_addr(19) -radix hexadecimal} {/testbench/du_e/dmaio_addr(18) -radix hexadecimal} {/testbench/du_e/dmaio_addr(17) -radix hexadecimal} {/testbench/du_e/dmaio_addr(16) -radix hexadecimal} {/testbench/du_e/dmaio_addr(15) -radix hexadecimal} {/testbench/du_e/dmaio_addr(14) -radix hexadecimal} {/testbench/du_e/dmaio_addr(13) -radix hexadecimal} {/testbench/du_e/dmaio_addr(12) -radix hexadecimal} {/testbench/du_e/dmaio_addr(11) -radix hexadecimal} {/testbench/du_e/dmaio_addr(10) -radix hexadecimal} {/testbench/du_e/dmaio_addr(9) -radix hexadecimal} {/testbench/du_e/dmaio_addr(8) -radix hexadecimal} {/testbench/du_e/dmaio_addr(7) -radix hexadecimal} {/testbench/du_e/dmaio_addr(6) -radix hexadecimal} {/testbench/du_e/dmaio_addr(5) -radix hexadecimal} {/testbench/du_e/dmaio_addr(4) -radix hexadecimal} {/testbench/du_e/dmaio_addr(3) -radix hexadecimal} {/testbench/du_e/dmaio_addr(2) -radix hexadecimal}} -subitemconfig {/testbench/du_e/dmaio_addr(25) {-height 29 -radix hexadecimal} /testbench/du_e/dmaio_addr(24) {-height 29 -radix hexadecimal} /testbench/du_e/dmaio_addr(23) {-height 29 -radix hexadecimal} /testbench/du_e/dmaio_addr(22) {-height 29 -radix hexadecimal} /testbench/du_e/dmaio_addr(21) {-height 29 -radix hexadecimal} /testbench/du_e/dmaio_addr(20) {-height 29 -radix hexadecimal} /testbench/du_e/dmaio_addr(19) {-height 29 -radix hexadecimal} /testbench/du_e/dmaio_addr(18) {-height 29 -radix hexadecimal} /testbench/du_e/dmaio_addr(17) {-height 29 -radix hexadecimal} /testbench/du_e/dmaio_addr(16) {-height 29 -radix hexadecimal} /testbench/du_e/dmaio_addr(15) {-height 29 -radix hexadecimal} /testbench/du_e/dmaio_addr(14) {-height 29 -radix hexadecimal} /testbench/du_e/dmaio_addr(13) {-height 29 -radix hexadecimal} /testbench/du_e/dmaio_addr(12) {-height 29 -radix hexadecimal} /testbench/du_e/dmaio_addr(11) {-height 29 -radix hexadecimal} /testbench/du_e/dmaio_addr(10) {-height 29 -radix hexadecimal} /testbench/du_e/dmaio_addr(9) {-height 29 -radix hexadecimal} /testbench/du_e/dmaio_addr(8) {-height 29 -radix hexadecimal} /testbench/du_e/dmaio_addr(7) {-height 29 -radix hexadecimal} /testbench/du_e/dmaio_addr(6) {-height 29 -radix hexadecimal} /testbench/du_e/dmaio_addr(5) {-height 29 -radix hexadecimal} /testbench/du_e/dmaio_addr(4) {-height 29 -radix hexadecimal} /testbench/du_e/dmaio_addr(3) {-height 29 -radix hexadecimal} /testbench/du_e/dmaio_addr(2) {-height 29 -radix hexadecimal}} /testbench/du_e/dmaio_addr
add wave -noupdate -radix hexadecimal /testbench/du_e/dmaio_len
add wave -noupdate /testbench/du_e/dmacfgvideo_req
add wave -noupdate /testbench/du_e/dmacfgvideo_rdy
add wave -noupdate /testbench/du_e/dmavideo_req
add wave -noupdate /testbench/du_e/dmavideo_rdy
add wave -noupdate -radix hexadecimal /testbench/du_e/dmavideo_len
add wave -noupdate -radix hexadecimal /testbench/du_e/dmavideo_addr
add wave -noupdate -divider graphics
add wave -noupdate -radix hexadecimal /testbench/du_e/graphics_e/dma_req
add wave -noupdate -radix hexadecimal /testbench/du_e/graphics_e/dma_rdy
add wave -noupdate -radix hexadecimal /testbench/du_e/graphics_e/dma_len
add wave -noupdate -radix hexadecimal /testbench/du_e/graphics_e/dma_addr
add wave -noupdate -radix hexadecimal /testbench/du_e/graphics_e/ctlr_di_dv
add wave -noupdate -radix hexadecimal /testbench/du_e/graphics_e/ctlr_di
add wave -noupdate -radix hexadecimal /testbench/du_e/graphics_e/video_clk
add wave -noupdate -radix hexadecimal /testbench/du_e/graphics_e/video_hzon
add wave -noupdate /testbench/du_e/graphics_e/hzon_edge
add wave -noupdate -radix hexadecimal -childformat {{/testbench/du_e/graphics_e/video_pixel(0) -radix hexadecimal} {/testbench/du_e/graphics_e/video_pixel(1) -radix hexadecimal} {/testbench/du_e/graphics_e/video_pixel(2) -radix hexadecimal} {/testbench/du_e/graphics_e/video_pixel(3) -radix hexadecimal} {/testbench/du_e/graphics_e/video_pixel(4) -radix hexadecimal} {/testbench/du_e/graphics_e/video_pixel(5) -radix hexadecimal} {/testbench/du_e/graphics_e/video_pixel(6) -radix hexadecimal} {/testbench/du_e/graphics_e/video_pixel(7) -radix hexadecimal} {/testbench/du_e/graphics_e/video_pixel(8) -radix hexadecimal} {/testbench/du_e/graphics_e/video_pixel(9) -radix hexadecimal} {/testbench/du_e/graphics_e/video_pixel(10) -radix hexadecimal} {/testbench/du_e/graphics_e/video_pixel(11) -radix hexadecimal} {/testbench/du_e/graphics_e/video_pixel(12) -radix hexadecimal} {/testbench/du_e/graphics_e/video_pixel(13) -radix hexadecimal} {/testbench/du_e/graphics_e/video_pixel(14) -radix hexadecimal} {/testbench/du_e/graphics_e/video_pixel(15) -radix hexadecimal} {/testbench/du_e/graphics_e/video_pixel(16) -radix hexadecimal} {/testbench/du_e/graphics_e/video_pixel(17) -radix hexadecimal} {/testbench/du_e/graphics_e/video_pixel(18) -radix hexadecimal} {/testbench/du_e/graphics_e/video_pixel(19) -radix hexadecimal} {/testbench/du_e/graphics_e/video_pixel(20) -radix hexadecimal} {/testbench/du_e/graphics_e/video_pixel(21) -radix hexadecimal} {/testbench/du_e/graphics_e/video_pixel(22) -radix hexadecimal} {/testbench/du_e/graphics_e/video_pixel(23) -radix hexadecimal} {/testbench/du_e/graphics_e/video_pixel(24) -radix hexadecimal} {/testbench/du_e/graphics_e/video_pixel(25) -radix hexadecimal} {/testbench/du_e/graphics_e/video_pixel(26) -radix hexadecimal} {/testbench/du_e/graphics_e/video_pixel(27) -radix hexadecimal} {/testbench/du_e/graphics_e/video_pixel(28) -radix hexadecimal} {/testbench/du_e/graphics_e/video_pixel(29) -radix hexadecimal} {/testbench/du_e/graphics_e/video_pixel(30) -radix hexadecimal} {/testbench/du_e/graphics_e/video_pixel(31) -radix hexadecimal}} -subitemconfig {/testbench/du_e/graphics_e/video_pixel(0) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/video_pixel(1) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/video_pixel(2) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/video_pixel(3) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/video_pixel(4) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/video_pixel(5) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/video_pixel(6) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/video_pixel(7) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/video_pixel(8) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/video_pixel(9) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/video_pixel(10) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/video_pixel(11) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/video_pixel(12) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/video_pixel(13) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/video_pixel(14) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/video_pixel(15) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/video_pixel(16) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/video_pixel(17) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/video_pixel(18) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/video_pixel(19) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/video_pixel(20) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/video_pixel(21) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/video_pixel(22) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/video_pixel(23) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/video_pixel(24) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/video_pixel(25) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/video_pixel(26) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/video_pixel(27) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/video_pixel(28) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/video_pixel(29) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/video_pixel(30) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/video_pixel(31) {-height 29 -radix hexadecimal}} /testbench/du_e/graphics_e/video_pixel
add wave -noupdate -radix hexadecimal /testbench/du_e/graphics_e/video_vton
add wave -noupdate /testbench/du_e/graphics_e/vton_edge
add wave -noupdate /testbench/du_e/graphics_e/video_frm
add wave -noupdate -radix hexadecimal /testbench/du_e/graphics_e/level
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/scopeio_export_b/dmadata_e/src_clk
add wave -noupdate /testbench/du_e/scopeio_export_b/dmadata_e/src_frm
add wave -noupdate /testbench/du_e/scopeio_export_b/dmadata_e/src_irdy
add wave -noupdate /testbench/du_e/scopeio_export_b/dmadata_e/src_trdy
add wave -noupdate -radix hexadecimal /testbench/du_e/scopeio_export_b/dmadata_e/src_data
add wave -noupdate /testbench/du_e/scopeio_export_b/dmadata_e/dst_clk
add wave -noupdate /testbench/du_e/scopeio_export_b/dmadata_e/dst_frm
add wave -noupdate /testbench/du_e/scopeio_export_b/dmadata_e/dst_irdy1
add wave -noupdate /testbench/du_e/scopeio_export_b/dmadata_e/dst_irdy
add wave -noupdate /testbench/du_e/scopeio_export_b/dmadata_e/dst_trdy
add wave -noupdate -radix hexadecimal /testbench/du_e/scopeio_export_b/dmadata_e/dst_data
add wave -noupdate -radix hexadecimal /testbench/du_e/scopeio_export_b/dmadata_e/rd_addr
add wave -noupdate -divider dmactlr
add wave -noupdate /testbench/du_e/dmactlr_e/dma_clk
add wave -noupdate -expand /testbench/du_e/dmactlr_e/dmacfg_req
add wave -noupdate -expand /testbench/du_e/dmactlr_e/dmacfg_rdy
add wave -noupdate -radix hexadecimal /testbench/du_e/dmactlr_e/dev_len
add wave -noupdate -radix hexadecimal /testbench/du_e/dmactlr_e/dev_addr
add wave -noupdate /testbench/du_e/dmactlr_e/dev_we
add wave -noupdate /testbench/du_e/dmactlr_e/dev_req
add wave -noupdate /testbench/du_e/dmactlr_e/dev_rdy
add wave -noupdate /testbench/du_e/dmactlr_e/dmatrans_req
add wave -noupdate /testbench/du_e/dmactlr_e/dmatrans_rdy
add wave -noupdate -divider {New Divider}
add wave -noupdate -expand /testbench/du_e/dmactlr_e/dmatransgnt_e/dev_req
add wave -noupdate /testbench/du_e/dmactlr_e/dmatransgnt_e/dev_gnt
add wave -noupdate /testbench/du_e/dmactlr_e/dmatransgnt_e/dev_rdy
add wave -noupdate -divider DDRCTLR
add wave -noupdate /testbench/du_e/ddrctlr_e/ctlr_irdy
add wave -noupdate /testbench/du_e/ddrctlr_e/ctlr_rw
add wave -noupdate /testbench/du_e/ddrctlr_e/ctlr_trdy
add wave -noupdate /testbench/du_e/ddrctlr_e/ctlr_act
add wave -noupdate /testbench/du_e/ddrctlr_e/ctlr_cas
add wave -noupdate -radix hexadecimal /testbench/du_e/ddrctlr_e/ctlr_di
add wave -noupdate /testbench/du_e/ddrctlr_e/ctlr_di_dv
add wave -noupdate /testbench/du_e/ddrctlr_e/ctlr_di_req
add wave -noupdate /testbench/du_e/ddrctlr_e/ctlr_dm
add wave -noupdate /testbench/du_e/ddrctlr_e/ctlr_do_dv(0)
add wave -noupdate /testbench/du_e/ddrctlr_e/phy_ras
add wave -noupdate /testbench/du_e/ddrctlr_e/phy_cas
add wave -noupdate /testbench/du_e/ddrctlr_e/phy_we
add wave -noupdate /testbench/du_e/ddrctlr_e/phy_dmi
add wave -noupdate /testbench/du_e/ddrctlr_e/phy_dmt
add wave -noupdate /testbench/du_e/ddrctlr_e/phy_dmo
add wave -noupdate -radix hexadecimal /testbench/du_e/ddrctlr_e/phy_dqi
add wave -noupdate -radix binary -childformat {{/testbench/du_e/ddrctlr_e/phy_dqt(3) -radix binary} {/testbench/du_e/ddrctlr_e/phy_dqt(2) -radix binary} {/testbench/du_e/ddrctlr_e/phy_dqt(1) -radix binary} {/testbench/du_e/ddrctlr_e/phy_dqt(0) -radix binary}} -subitemconfig {/testbench/du_e/ddrctlr_e/phy_dqt(3) {-height 29 -radix binary} /testbench/du_e/ddrctlr_e/phy_dqt(2) {-height 29 -radix binary} /testbench/du_e/ddrctlr_e/phy_dqt(1) {-height 29 -radix binary} /testbench/du_e/ddrctlr_e/phy_dqt(0) {-height 29 -radix binary}} /testbench/du_e/ddrctlr_e/phy_dqt
add wave -noupdate -radix hexadecimal -childformat {{/testbench/du_e/ddrctlr_e/phy_dqo(31) -radix hexadecimal} {/testbench/du_e/ddrctlr_e/phy_dqo(30) -radix hexadecimal} {/testbench/du_e/ddrctlr_e/phy_dqo(29) -radix hexadecimal} {/testbench/du_e/ddrctlr_e/phy_dqo(28) -radix hexadecimal} {/testbench/du_e/ddrctlr_e/phy_dqo(27) -radix hexadecimal} {/testbench/du_e/ddrctlr_e/phy_dqo(26) -radix hexadecimal} {/testbench/du_e/ddrctlr_e/phy_dqo(25) -radix hexadecimal} {/testbench/du_e/ddrctlr_e/phy_dqo(24) -radix hexadecimal} {/testbench/du_e/ddrctlr_e/phy_dqo(23) -radix hexadecimal} {/testbench/du_e/ddrctlr_e/phy_dqo(22) -radix hexadecimal} {/testbench/du_e/ddrctlr_e/phy_dqo(21) -radix hexadecimal} {/testbench/du_e/ddrctlr_e/phy_dqo(20) -radix hexadecimal} {/testbench/du_e/ddrctlr_e/phy_dqo(19) -radix hexadecimal} {/testbench/du_e/ddrctlr_e/phy_dqo(18) -radix hexadecimal} {/testbench/du_e/ddrctlr_e/phy_dqo(17) -radix hexadecimal} {/testbench/du_e/ddrctlr_e/phy_dqo(16) -radix hexadecimal} {/testbench/du_e/ddrctlr_e/phy_dqo(15) -radix hexadecimal} {/testbench/du_e/ddrctlr_e/phy_dqo(14) -radix hexadecimal} {/testbench/du_e/ddrctlr_e/phy_dqo(13) -radix hexadecimal} {/testbench/du_e/ddrctlr_e/phy_dqo(12) -radix hexadecimal} {/testbench/du_e/ddrctlr_e/phy_dqo(11) -radix hexadecimal} {/testbench/du_e/ddrctlr_e/phy_dqo(10) -radix hexadecimal} {/testbench/du_e/ddrctlr_e/phy_dqo(9) -radix hexadecimal} {/testbench/du_e/ddrctlr_e/phy_dqo(8) -radix hexadecimal} {/testbench/du_e/ddrctlr_e/phy_dqo(7) -radix hexadecimal} {/testbench/du_e/ddrctlr_e/phy_dqo(6) -radix hexadecimal} {/testbench/du_e/ddrctlr_e/phy_dqo(5) -radix hexadecimal} {/testbench/du_e/ddrctlr_e/phy_dqo(4) -radix hexadecimal} {/testbench/du_e/ddrctlr_e/phy_dqo(3) -radix hexadecimal} {/testbench/du_e/ddrctlr_e/phy_dqo(2) -radix hexadecimal} {/testbench/du_e/ddrctlr_e/phy_dqo(1) -radix hexadecimal} {/testbench/du_e/ddrctlr_e/phy_dqo(0) -radix hexadecimal}} -subitemconfig {/testbench/du_e/ddrctlr_e/phy_dqo(31) {-height 29 -radix hexadecimal} /testbench/du_e/ddrctlr_e/phy_dqo(30) {-height 29 -radix hexadecimal} /testbench/du_e/ddrctlr_e/phy_dqo(29) {-height 29 -radix hexadecimal} /testbench/du_e/ddrctlr_e/phy_dqo(28) {-height 29 -radix hexadecimal} /testbench/du_e/ddrctlr_e/phy_dqo(27) {-height 29 -radix hexadecimal} /testbench/du_e/ddrctlr_e/phy_dqo(26) {-height 29 -radix hexadecimal} /testbench/du_e/ddrctlr_e/phy_dqo(25) {-height 29 -radix hexadecimal} /testbench/du_e/ddrctlr_e/phy_dqo(24) {-height 29 -radix hexadecimal} /testbench/du_e/ddrctlr_e/phy_dqo(23) {-height 29 -radix hexadecimal} /testbench/du_e/ddrctlr_e/phy_dqo(22) {-height 29 -radix hexadecimal} /testbench/du_e/ddrctlr_e/phy_dqo(21) {-height 29 -radix hexadecimal} /testbench/du_e/ddrctlr_e/phy_dqo(20) {-height 29 -radix hexadecimal} /testbench/du_e/ddrctlr_e/phy_dqo(19) {-height 29 -radix hexadecimal} /testbench/du_e/ddrctlr_e/phy_dqo(18) {-height 29 -radix hexadecimal} /testbench/du_e/ddrctlr_e/phy_dqo(17) {-height 29 -radix hexadecimal} /testbench/du_e/ddrctlr_e/phy_dqo(16) {-height 29 -radix hexadecimal} /testbench/du_e/ddrctlr_e/phy_dqo(15) {-height 29 -radix hexadecimal} /testbench/du_e/ddrctlr_e/phy_dqo(14) {-height 29 -radix hexadecimal} /testbench/du_e/ddrctlr_e/phy_dqo(13) {-height 29 -radix hexadecimal} /testbench/du_e/ddrctlr_e/phy_dqo(12) {-height 29 -radix hexadecimal} /testbench/du_e/ddrctlr_e/phy_dqo(11) {-height 29 -radix hexadecimal} /testbench/du_e/ddrctlr_e/phy_dqo(10) {-height 29 -radix hexadecimal} /testbench/du_e/ddrctlr_e/phy_dqo(9) {-height 29 -radix hexadecimal} /testbench/du_e/ddrctlr_e/phy_dqo(8) {-height 29 -radix hexadecimal} /testbench/du_e/ddrctlr_e/phy_dqo(7) {-height 29 -radix hexadecimal} /testbench/du_e/ddrctlr_e/phy_dqo(6) {-height 29 -radix hexadecimal} /testbench/du_e/ddrctlr_e/phy_dqo(5) {-height 29 -radix hexadecimal} /testbench/du_e/ddrctlr_e/phy_dqo(4) {-height 29 -radix hexadecimal} /testbench/du_e/ddrctlr_e/phy_dqo(3) {-height 29 -radix hexadecimal} /testbench/du_e/ddrctlr_e/phy_dqo(2) {-height 29 -radix hexadecimal} /testbench/du_e/ddrctlr_e/phy_dqo(1) {-height 29 -radix hexadecimal} /testbench/du_e/ddrctlr_e/phy_dqo(0) {-height 29 -radix hexadecimal}} /testbench/du_e/ddrctlr_e/phy_dqo
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/ddrsys_clks
add wave -noupdate /testbench/du_e/ddrphy_rst
add wave -noupdate /testbench/du_e/ddrphy_cke
add wave -noupdate /testbench/du_e/ddrphy_cs
add wave -noupdate /testbench/du_e/ddrphy_ras
add wave -noupdate /testbench/du_e/ddrphy_cas
add wave -noupdate /testbench/du_e/ddrphy_we
add wave -noupdate /testbench/du_e/ddrphy_odt
add wave -noupdate -radix hexadecimal /testbench/du_e/ddrphy_b
add wave -noupdate -radix hexadecimal /testbench/du_e/ddrphy_a
add wave -noupdate /testbench/du_e/ddrphy_dqsi
add wave -noupdate /testbench/du_e/ddrphy_dqst
add wave -noupdate /testbench/du_e/ddrphy_dqso
add wave -noupdate /testbench/du_e/ddrphy_dmi
add wave -noupdate /testbench/du_e/ddrphy_dmt
add wave -noupdate /testbench/du_e/ddrphy_dmo
add wave -noupdate -radix hexadecimal -childformat {{/testbench/du_e/ddrphy_dqi(31) -radix hexadecimal} {/testbench/du_e/ddrphy_dqi(30) -radix hexadecimal} {/testbench/du_e/ddrphy_dqi(29) -radix hexadecimal} {/testbench/du_e/ddrphy_dqi(28) -radix hexadecimal} {/testbench/du_e/ddrphy_dqi(27) -radix hexadecimal} {/testbench/du_e/ddrphy_dqi(26) -radix hexadecimal} {/testbench/du_e/ddrphy_dqi(25) -radix hexadecimal} {/testbench/du_e/ddrphy_dqi(24) -radix hexadecimal} {/testbench/du_e/ddrphy_dqi(23) -radix hexadecimal} {/testbench/du_e/ddrphy_dqi(22) -radix hexadecimal} {/testbench/du_e/ddrphy_dqi(21) -radix hexadecimal} {/testbench/du_e/ddrphy_dqi(20) -radix hexadecimal} {/testbench/du_e/ddrphy_dqi(19) -radix hexadecimal} {/testbench/du_e/ddrphy_dqi(18) -radix hexadecimal} {/testbench/du_e/ddrphy_dqi(17) -radix hexadecimal} {/testbench/du_e/ddrphy_dqi(16) -radix hexadecimal} {/testbench/du_e/ddrphy_dqi(15) -radix hexadecimal} {/testbench/du_e/ddrphy_dqi(14) -radix hexadecimal} {/testbench/du_e/ddrphy_dqi(13) -radix hexadecimal} {/testbench/du_e/ddrphy_dqi(12) -radix hexadecimal} {/testbench/du_e/ddrphy_dqi(11) -radix hexadecimal} {/testbench/du_e/ddrphy_dqi(10) -radix hexadecimal} {/testbench/du_e/ddrphy_dqi(9) -radix hexadecimal} {/testbench/du_e/ddrphy_dqi(8) -radix hexadecimal} {/testbench/du_e/ddrphy_dqi(7) -radix hexadecimal} {/testbench/du_e/ddrphy_dqi(6) -radix hexadecimal} {/testbench/du_e/ddrphy_dqi(5) -radix hexadecimal} {/testbench/du_e/ddrphy_dqi(4) -radix hexadecimal} {/testbench/du_e/ddrphy_dqi(3) -radix hexadecimal} {/testbench/du_e/ddrphy_dqi(2) -radix hexadecimal} {/testbench/du_e/ddrphy_dqi(1) -radix hexadecimal} {/testbench/du_e/ddrphy_dqi(0) -radix hexadecimal}} -subitemconfig {/testbench/du_e/ddrphy_dqi(31) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_dqi(30) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_dqi(29) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_dqi(28) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_dqi(27) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_dqi(26) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_dqi(25) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_dqi(24) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_dqi(23) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_dqi(22) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_dqi(21) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_dqi(20) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_dqi(19) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_dqi(18) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_dqi(17) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_dqi(16) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_dqi(15) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_dqi(14) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_dqi(13) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_dqi(12) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_dqi(11) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_dqi(10) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_dqi(9) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_dqi(8) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_dqi(7) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_dqi(6) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_dqi(5) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_dqi(4) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_dqi(3) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_dqi(2) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_dqi(1) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_dqi(0) {-height 29 -radix hexadecimal}} /testbench/du_e/ddrphy_dqi
add wave -noupdate /testbench/du_e/ddrphy_dqt
add wave -noupdate -radix hexadecimal -childformat {{/testbench/du_e/ddrphy_dqo(31) -radix hexadecimal} {/testbench/du_e/ddrphy_dqo(30) -radix hexadecimal} {/testbench/du_e/ddrphy_dqo(29) -radix hexadecimal} {/testbench/du_e/ddrphy_dqo(28) -radix hexadecimal} {/testbench/du_e/ddrphy_dqo(27) -radix hexadecimal} {/testbench/du_e/ddrphy_dqo(26) -radix hexadecimal} {/testbench/du_e/ddrphy_dqo(25) -radix hexadecimal} {/testbench/du_e/ddrphy_dqo(24) -radix hexadecimal} {/testbench/du_e/ddrphy_dqo(23) -radix hexadecimal} {/testbench/du_e/ddrphy_dqo(22) -radix hexadecimal} {/testbench/du_e/ddrphy_dqo(21) -radix hexadecimal} {/testbench/du_e/ddrphy_dqo(20) -radix hexadecimal} {/testbench/du_e/ddrphy_dqo(19) -radix hexadecimal} {/testbench/du_e/ddrphy_dqo(18) -radix hexadecimal} {/testbench/du_e/ddrphy_dqo(17) -radix hexadecimal} {/testbench/du_e/ddrphy_dqo(16) -radix hexadecimal} {/testbench/du_e/ddrphy_dqo(15) -radix hexadecimal} {/testbench/du_e/ddrphy_dqo(14) -radix hexadecimal} {/testbench/du_e/ddrphy_dqo(13) -radix hexadecimal} {/testbench/du_e/ddrphy_dqo(12) -radix hexadecimal} {/testbench/du_e/ddrphy_dqo(11) -radix hexadecimal} {/testbench/du_e/ddrphy_dqo(10) -radix hexadecimal} {/testbench/du_e/ddrphy_dqo(9) -radix hexadecimal} {/testbench/du_e/ddrphy_dqo(8) -radix hexadecimal} {/testbench/du_e/ddrphy_dqo(7) -radix hexadecimal} {/testbench/du_e/ddrphy_dqo(6) -radix hexadecimal} {/testbench/du_e/ddrphy_dqo(5) -radix hexadecimal} {/testbench/du_e/ddrphy_dqo(4) -radix hexadecimal} {/testbench/du_e/ddrphy_dqo(3) -radix hexadecimal} {/testbench/du_e/ddrphy_dqo(2) -radix hexadecimal} {/testbench/du_e/ddrphy_dqo(1) -radix hexadecimal} {/testbench/du_e/ddrphy_dqo(0) -radix hexadecimal}} -subitemconfig {/testbench/du_e/ddrphy_dqo(31) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_dqo(30) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_dqo(29) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_dqo(28) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_dqo(27) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_dqo(26) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_dqo(25) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_dqo(24) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_dqo(23) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_dqo(22) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_dqo(21) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_dqo(20) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_dqo(19) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_dqo(18) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_dqo(17) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_dqo(16) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_dqo(15) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_dqo(14) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_dqo(13) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_dqo(12) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_dqo(11) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_dqo(10) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_dqo(9) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_dqo(8) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_dqo(7) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_dqo(6) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_dqo(5) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_dqo(4) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_dqo(3) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_dqo(2) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_dqo(1) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_dqo(0) {-height 29 -radix hexadecimal}} /testbench/du_e/ddrphy_dqo
add wave -noupdate /testbench/du_e/ddrphy_sto
add wave -noupdate /testbench/du_e/ddrphy_sti
add wave -noupdate -radix hexadecimal /testbench/du_e/ddr_dqo
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {211882679 ps} 0} {{Cursor 2} {513519474 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 276
configure wave -valuecolwidth 119
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
configure wave -timelineunits ps
update
WaveRestoreZoom {211295149 ps} {211934993 ps}
