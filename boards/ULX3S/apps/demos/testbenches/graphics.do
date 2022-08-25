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
add wave -noupdate /testbench/du_e/ctlr_clk
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/ctlr_trdy
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/state_pre
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/leoc
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/ceoc
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/ctlr_refreq
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/refreq
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/restart
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dmatrans_rdy
add wave -noupdate -expand /testbench/du_e/grahics_e/dmactlr_b/dev_do_dv
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/ctlr_do
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/graphics_e/serdes_g/serdes_e/serdes_frm
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/graphics_e/serdes_g/serdes_e/ser_irdy
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/graphics_e/serdes_g/serdes_e/ser_trdy
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/adapter_b/graphics_e/serdes_g/serdes_e/ser_data
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/graphics_e/vram_e/src_clk
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/graphics_e/vram_e/src_frm
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/graphics_e/vram_e/src_irdy
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/adapter_b/graphics_e/vram_e/src_data
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/graphics_e/debug_dmacfg_req
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/graphics_e/debug_dmacfg_rdy
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/graphics_e/debug_dma_req
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/graphics_e/debug_dma_rdy
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/adapter_b/graphics_e/dma_len
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/adapter_b/graphics_e/dma_addr
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/graphics_e/video_clk
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/graphics_e/video_frm
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/graphics_e/video_hzon
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/graphics_e/video_vton
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/adapter_b/graphics_e/video_word
add wave -noupdate /testbench/du_e/grahics_e/adapter_b/graphics_e/video_on
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1030290000000 fs} 0} {{Cursor 2} {1038198422750 fs} 0}
quietly wave cursor active 2
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
WaveRestoreZoom {1038047229430 fs} {1038268066030 fs}
