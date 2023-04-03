onerror {resume}
quietly virtual signal -install /testbench/du_e { (context /testbench/du_e )(graphics_e_dma_do_15 & graphics_e_dma_do_14 & graphics_e_dma_do_13 & graphics_e_dma_do_12 & graphics_e_dma_do_11 & graphics_e_dma_do_10 & graphics_e_dma_do_9 & graphics_e_dma_do_8 & graphics_e_dma_do_7 & graphics_e_dma_do_6 & graphics_e_dma_do_5 & graphics_e_dma_do_4 & graphics_e_dma_do_3 & graphics_e_dma_do_2 & graphics_e_dma_do_0 & graphics_e_dma_do_1 )} dma_do
quietly virtual signal -install /testbench/du_e { (context /testbench/du_e )(ctlrphy_dqi_15 & ctlrphy_dqi_14 & ctlrphy_dqi_13 & ctlrphy_dqi_12 & ctlrphy_dqi_11 & ctlrphy_dqi_10 & ctlrphy_dqi_9 & ctlrphy_dqi_8 & ctlrphy_dqi_7 & ctlrphy_dqi_6 & ctlrphy_dqi_5 & ctlrphy_dqi_4 & ctlrphy_dqi_3 & ctlrphy_dqi_2 & ctlrphy_dqi_1 & ctlrphy_dqi_0 )} ctlrphy_dqi
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/du_e/ctlr_clk
add wave -noupdate /testbench/du_e/graphics_e_ctlrphy_sto_0
add wave -noupdate /testbench/du_e/graphics_e_dma_do_dv_1
add wave -noupdate -radix hexadecimal -childformat {{/testbench/du_e/dma_do(15) -radix hexadecimal} {/testbench/du_e/dma_do(14) -radix hexadecimal} {/testbench/du_e/dma_do(13) -radix hexadecimal} {/testbench/du_e/dma_do(12) -radix hexadecimal} {/testbench/du_e/dma_do(11) -radix hexadecimal} {/testbench/du_e/dma_do(10) -radix hexadecimal} {/testbench/du_e/dma_do(9) -radix hexadecimal} {/testbench/du_e/dma_do(8) -radix hexadecimal} {/testbench/du_e/dma_do(7) -radix hexadecimal} {/testbench/du_e/dma_do(6) -radix hexadecimal} {/testbench/du_e/dma_do(5) -radix hexadecimal} {/testbench/du_e/dma_do(4) -radix hexadecimal} {/testbench/du_e/dma_do(3) -radix hexadecimal} {/testbench/du_e/dma_do(2) -radix hexadecimal} {/testbench/du_e/dma_do(1) -radix hexadecimal} {/testbench/du_e/dma_do(0) -radix hexadecimal}} -subitemconfig {/testbench/du_e/graphics_e_dma_do_15 {-radix hexadecimal} /testbench/du_e/graphics_e_dma_do_14 {-radix hexadecimal} /testbench/du_e/graphics_e_dma_do_13 {-radix hexadecimal} /testbench/du_e/graphics_e_dma_do_12 {-radix hexadecimal} /testbench/du_e/graphics_e_dma_do_11 {-radix hexadecimal} /testbench/du_e/graphics_e_dma_do_10 {-radix hexadecimal} /testbench/du_e/graphics_e_dma_do_9 {-radix hexadecimal} /testbench/du_e/graphics_e_dma_do_8 {-radix hexadecimal} /testbench/du_e/graphics_e_dma_do_7 {-radix hexadecimal} /testbench/du_e/graphics_e_dma_do_6 {-radix hexadecimal} /testbench/du_e/graphics_e_dma_do_5 {-radix hexadecimal} /testbench/du_e/graphics_e_dma_do_4 {-radix hexadecimal} /testbench/du_e/graphics_e_dma_do_3 {-radix hexadecimal} /testbench/du_e/graphics_e_dma_do_2 {-radix hexadecimal} /testbench/du_e/graphics_e_dma_do_0 {-radix hexadecimal} /testbench/du_e/graphics_e_dma_do_1 {-radix hexadecimal}} /testbench/du_e/dma_do
add wave -noupdate -radix hexadecimal /testbench/du_e/ctlrphy_dqi
add wave -noupdate /testbench/du_e/sdram_clk
add wave -noupdate /testbench/du_e/sdram_cke
add wave -noupdate /testbench/du_e/sdram_csn
add wave -noupdate /testbench/du_e/sdram_wen
add wave -noupdate /testbench/du_e/sdram_rasn
add wave -noupdate /testbench/du_e/sdram_casn
add wave -noupdate -radix hexadecimal /testbench/du_e/sdram_ba
add wave -noupdate -radix hexadecimal /testbench/du_e/sdram_a
add wave -noupdate /testbench/du_e/sdram_dqm
add wave -noupdate -radix hexadecimal /testbench/du_e/sdram_d
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1059566131000 fs} 0} {{Cursor 2} {1059551131000 fs} 0}
quietly wave cursor active 2
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
