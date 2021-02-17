onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/du_e/mii_rxc
add wave -noupdate /testbench/du_e/mii_rxdv
add wave -noupdate -radix hexadecimal /testbench/du_e/mii_rxd
add wave -noupdate /testbench/du_e/mii_txen
add wave -noupdate -radix hexadecimal /testbench/du_e/mii_txd
add wave -noupdate /testbench/du_e/udpdaisy_e/sioudpp_e/mii_ipoe_e/dllfcs_vld
add wave -noupdate /testbench/du_e/udpdaisy_e/sioudpp_e/flow_e/buffer_cmmt
add wave -noupdate /testbench/du_e/udpdaisy_e/sioudpp_e/flow_e/buffer_rllk
add wave -noupdate /testbench/du_e/udpdaisy_e/sioudpp_e/flow_e/buffer_ovfl
add wave -noupdate /testbench/du_e/udpdaisy_e/sioudpp_e/mii_ipoe_e/mii_req
add wave -noupdate /testbench/du_e/udpdaisy_e/sioudpp_e/mii_ipoe_e/mii_gnt
add wave -noupdate /testbench/du_e/udpdaisy_e/sioudpp_e/mii_ipoe_e/mii_rdy
add wave -noupdate /testbench/du_e/udpdaisy_e/sioudpp_e/mii_ipoe_e/tx_req
add wave -noupdate /testbench/du_e/udpdaisy_e/sioudpp_e/mii_ipoe_e/tx_gnt
add wave -noupdate /testbench/du_e/udpdaisy_e/sioudpp_e/mii_ipoe_e/tx_rdy
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {32064689810 fs} 0}
quietly wave cursor active 1
configure wave -namecolwidth 237
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
WaveRestoreZoom {0 fs} {63 us}
