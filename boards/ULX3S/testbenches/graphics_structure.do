onerror {resume}
quietly virtual signal -install /testbench/du_e { (context /testbench/du_e )(graphics_e_dma_do_15 & graphics_e_dma_do_14 & graphics_e_dma_do_13 & graphics_e_dma_do_12 & graphics_e_dma_do_11 & graphics_e_dma_do_10 & graphics_e_dma_do_9 & graphics_e_dma_do_8 & graphics_e_dma_do_7 & graphics_e_dma_do_6 & graphics_e_dma_do_5 & graphics_e_dma_do_4 & graphics_e_dma_do_3 & graphics_e_dma_do_2 & graphics_e_dma_do_1 & graphics_e_dma_do_0 )} dma_do
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group sdram /testbench/du_e/sdram_clk
add wave -noupdate -expand -group sdram /testbench/du_e/sdram_cke
add wave -noupdate -expand -group sdram /testbench/du_e/sdram_csn
add wave -noupdate -expand -group sdram /testbench/du_e/sdram_wen
add wave -noupdate -expand -group sdram /testbench/du_e/sdram_rasn
add wave -noupdate -expand -group sdram /testbench/du_e/sdram_casn
add wave -noupdate -expand -group sdram -radix hexadecimal /testbench/du_e/sdram_ba
add wave -noupdate -expand -group sdram -radix hexadecimal /testbench/du_e/sdram_a
add wave -noupdate -expand -group sdram /testbench/du_e/sdram_dqm
add wave -noupdate -expand -group sdram -radix hexadecimal /testbench/du_e/sdram_d
add wave -noupdate /testbench/du_e/ctlr_clk
add wave -noupdate /testbench/du_e/graphics_e_dma_do_dv_1
add wave -noupdate -radix hexadecimal /testbench/du_e/dma_do
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1059594479330 fs} 0} {{Cursor 2} {1059558076440 fs} 0}
quietly wave cursor active 1
configure wave -namecolwidth 596
configure wave -valuecolwidth 100
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
WaveRestoreZoom {1059505898970 fs} {1059649569030 fs}
