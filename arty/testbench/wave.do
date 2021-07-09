onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/rst
add wave -noupdate /testbench/clk
add wave -noupdate /testbench/btn
add wave -noupdate /testbench/du_e/ipoe_b/du_e/miitx_frm
add wave -noupdate /testbench/du_e/ipoe_b/du_e/miitx_irdy
add wave -noupdate /testbench/du_e/ipoe_b/du_e/miitx_trdy
add wave -noupdate /testbench/du_e/ipoe_b/du_e/miitx_end
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/du_e/miitx_data
add wave -noupdate /testbench/du_e/eth_tx_clk
add wave -noupdate /testbench/du_e/eth_tx_en
add wave -noupdate -radix hexadecimal /testbench/du_e/eth_txd
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {320610690 fs} 0}
quietly wave cursor active 1
configure wave -namecolwidth 301
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
WaveRestoreZoom {0 fs} {5250 ns}
