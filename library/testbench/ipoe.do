onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/du_e/mii_rxc
add wave -noupdate /testbench/du_e/mii_rxdv
add wave -noupdate -radix hexadecimal /testbench/du_e/mii_rxd
add wave -noupdate -radix hexadecimal /testbench/du_e/mii_debug_e/mii_du/mii_ptr
add wave -noupdate -radix hexadecimal -childformat {{/testbench/du_e/mii_debug_e/mii_display_e/serdes_e/des_data(0) -radix hexadecimal} {/testbench/du_e/mii_debug_e/mii_display_e/serdes_e/des_data(1) -radix hexadecimal} {/testbench/du_e/mii_debug_e/mii_display_e/serdes_e/des_data(2) -radix hexadecimal} {/testbench/du_e/mii_debug_e/mii_display_e/serdes_e/des_data(3) -radix hexadecimal} {/testbench/du_e/mii_debug_e/mii_display_e/serdes_e/des_data(4) -radix hexadecimal} {/testbench/du_e/mii_debug_e/mii_display_e/serdes_e/des_data(5) -radix hexadecimal} {/testbench/du_e/mii_debug_e/mii_display_e/serdes_e/des_data(6) -radix hexadecimal} {/testbench/du_e/mii_debug_e/mii_display_e/serdes_e/des_data(7) -radix hexadecimal}} -subitemconfig {/testbench/du_e/mii_debug_e/mii_display_e/serdes_e/des_data(0) {-height 29 -radix hexadecimal} /testbench/du_e/mii_debug_e/mii_display_e/serdes_e/des_data(1) {-height 29 -radix hexadecimal} /testbench/du_e/mii_debug_e/mii_display_e/serdes_e/des_data(2) {-height 29 -radix hexadecimal} /testbench/du_e/mii_debug_e/mii_display_e/serdes_e/des_data(3) {-height 29 -radix hexadecimal} /testbench/du_e/mii_debug_e/mii_display_e/serdes_e/des_data(4) {-height 29 -radix hexadecimal} /testbench/du_e/mii_debug_e/mii_display_e/serdes_e/des_data(5) {-height 29 -radix hexadecimal} /testbench/du_e/mii_debug_e/mii_display_e/serdes_e/des_data(6) {-height 29 -radix hexadecimal} /testbench/du_e/mii_debug_e/mii_display_e/serdes_e/des_data(7) {-height 29 -radix hexadecimal}} /testbench/du_e/mii_debug_e/mii_display_e/serdes_e/des_data
add wave -noupdate /testbench/du_e/mii_debug_e/mii_du/eth_macd
add wave -noupdate /testbench/du_e/mii_debug_e/mii_du/eth_bcst
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {9113866420 fs} 0}
quietly wave cursor active 1
configure wave -namecolwidth 258
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
WaveRestoreZoom {14119667380 fs} {16098964880 fs}
