onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group sdram /testbench/du_e/sdram_clk
add wave -noupdate -expand -group sdram /testbench/du_e/sdram_cke
add wave -noupdate -expand -group sdram /testbench/du_e/sdram_csn
add wave -noupdate -expand -group sdram /testbench/du_e/sdram_rasn
add wave -noupdate -expand -group sdram /testbench/du_e/sdram_casn
add wave -noupdate -expand -group sdram /testbench/du_e/sdram_wen
add wave -noupdate -expand -group sdram -radix hexadecimal /testbench/du_e/sdram_a
add wave -noupdate -expand -group sdram /testbench/du_e/sdram_ba
add wave -noupdate -expand -group sdram /testbench/du_e/sdram_dqm
add wave -noupdate -expand -group sdram -radix hexadecimal /testbench/du_e/sdram_d
add wave -noupdate -expand -group uart /testbench/du_e/ftdi_rxd
add wave -noupdate -expand -group uart /testbench/du_e/ftdi_txd
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dmatrans_clk
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/ddrdma_row
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/ddrdma_col
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/graphics_e/dmacfg_clk
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/graphics_e/dmacfg_req
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/graphics_e/dmacfg_rdy
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/adapter_b/graphics_e/dma_len
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/adapter_b/graphics_e/dma_addr
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/graphics_e/dma_req
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/graphics_e/dma_rdy
add wave -noupdate /testbench/du_e/ctlr_clk
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/ctlr_trdy
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/adapter_b/graphics_e/ctlr_di_dv
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/adapter_b/graphics_e/ctlr_di
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/state_pre
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/leoc
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/ceoc
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/ctlr_refreq
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/refreq
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/restart
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/adapter_b/graphics_e/vram_e/wr_ptr
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/adapter_b/graphics_e/vram_e/wr_cntr
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/adapter_b/graphics_e/vram_e/wr_cmp
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/adapter_b/graphics_e/vram_e/rd_cntr
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/adapter_b/graphics_e/vram_e/rd_cmp
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/graphics_e/vram_e/max_depthgt1_g/mem_e/rd_data
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/graphics_e/video_clk
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/graphics_e/video_frm
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/graphics_e/video_hzon
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/graphics_e/video_vton
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/graphics_e/video_on
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/video_pixel
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {32419654096680 fs} 0} {{Cursor 2} {1038198422750 fs} 1} {{Cursor 3} {325289351850 fs} 0}
quietly wave cursor active 3
configure wave -namecolwidth 216
configure wave -valuecolwidth 169
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
WaveRestoreZoom {0 fs} {855555555560 fs}
