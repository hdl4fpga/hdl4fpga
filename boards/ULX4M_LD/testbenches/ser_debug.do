onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /testbench/du_e/uartrx_e/debug_rxd
add wave -noupdate /testbench/du_e/uartrx_e/debug_rxdv
add wave -noupdate -radix hexadecimal /testbench/du_e/uarttx_e/debug_txen
add wave -noupdate -radix hexadecimal /testbench/du_e/uarttx_e/debug_txd
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/siodayahdlc_e/siohdlc_e/hdlcdll_rx_e/fcs_sb
add wave -noupdate /testbench/du_e/siodayahdlc_e/siohdlc_e/hdlcdll_rx_e/fcs_vld
add wave -noupdate -radix hexadecimal /testbench/du_e/siodayahdlc_e/siohdlc_e/hdlcdll_rx_e/hdlcsyncrx_data
add wave -noupdate /testbench/du_e/siodayahdlc_e/siohdlc_e/hdlcdll_rx_e/hdlcsyncrx_irdy
add wave -noupdate /testbench/du_e/siodayahdlc_e/siohdlc_e/hdlcdll_rx_e/hdlcrx_irdy
add wave -noupdate -radix hexadecimal /testbench/du_e/siodayahdlc_e/siohdlc_e/hdlcdll_rx_e/hdlcrx_data
add wave -noupdate /testbench/du_e/siodayahdlc_e/siohdlc_e/flow_e/buffer_cmmt
add wave -noupdate -radix hexadecimal /testbench/du_e/siodayahdlc_e/siohdlc_e/flow_e/rx_b/line__165/last
add wave -noupdate /testbench/du_e/siodayahdlc_e/siohdlc_e/flow_e/pkt_dup
add wave -noupdate -radix hexadecimal /testbench/du_e/siodayahdlc_e/siohdlc_e/flow_e/rx_b/rgtr_id
add wave -noupdate /testbench/du_e/siodayahdlc_e/siohdlc_e/flow_e/flow_frm
add wave -noupdate /testbench/du_e/siodayahdlc_e/siohdlc_e/flow_e/flow_trdy
add wave -noupdate /testbench/du_e/siodayahdlc_e/siohdlc_e/flow_e/flow_irdy(0)
add wave -noupdate /testbench/du_e/siodayahdlc_e/siohdlc_e/flow_e/flow_data
add wave -noupdate /testbench/du_e/siodayahdlc_e/siohdlc_e/flow_e/artibiter_b/req
add wave -noupdate /testbench/du_e/siodayahdlc_e/siohdlc_e/flow_e/artibiter_b/gnt
add wave -noupdate /testbench/du_e/siodayahdlc_e/siohdlc_e/flow_e/phyo_frm
add wave -noupdate /testbench/du_e/siodayahdlc_e/siohdlc_e/flow_e/des_irdy(0)
add wave -noupdate -radix hexadecimal /testbench/du_e/siodayahdlc_e/siohdlc_e/flow_e/sigram_e/len
add wave -noupdate /testbench/du_e/siodayahdlc_e/siohdlc_e/flow_e/sigram_e/si_frm
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {47945924760 fs} 0}
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
WaveRestoreZoom {20250 ns} {125250 ns}
