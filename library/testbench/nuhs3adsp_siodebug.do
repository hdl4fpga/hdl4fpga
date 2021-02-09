onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/du_e/mii_rxc
add wave -noupdate /testbench/du_e/mii_rxdv
add wave -noupdate -radix hexadecimal /testbench/du_e/mii_rxd
add wave -noupdate /testbench/du_e/mii_txc
add wave -noupdate /testbench/du_e/mii_txen
add wave -noupdate -radix hexadecimal /testbench/du_e/mii_txd
add wave -noupdate /testbench/du_e/udpdaisy_e/sioudpp_e/mii_ipoe_e/dllfcs_vld
add wave -noupdate /testbench/du_e/udpdaisy_e/sioudpp_e/flow_e/buffer_cmmt
add wave -noupdate /testbench/du_e/udpdaisy_e/sioudpp_e/flow_e/buffer_rllk
add wave -noupdate /testbench/du_e/udpdaisy_e/sioudpp_e/flow_e/buffer_ovfl
add wave -noupdate /testbench/du_e/udpdaisy_e/sioudpp_e/flow_e/rx_b/sigseq_e/rgtr_dv
add wave -noupdate /testbench/du_e/udpdaisy_e/sioudpp_e/flow_e/rx_b/sigseq_e/rgtr_id
add wave -noupdate -radix hexadecimal /testbench/du_e/udpdaisy_e/sioudpp_e/flow_e/rx_b/sigseq_e/rgtr_data
add wave -noupdate -radix hexadecimal /testbench/du_e/udpdaisy_e/sioudpp_e/flow_e/rx_b/sigseq_e/data
add wave -noupdate /testbench/du_e/udpdaisy_e/sioudpp_e/mii_ipoe_e/mii_gnt
add wave -noupdate -radix hexadecimal /testbench/du_e/udpdaisy_e/sioudpp_e/flow_e/phyo_frm
add wave -noupdate -radix hexadecimal /testbench/du_e/udpdaisy_e/sioudpp_e/flow_e/phyo_irdy
add wave -noupdate -radix hexadecimal /testbench/du_e/udpdaisy_e/sioudpp_e/flow_e/phyo_data
add wave -noupdate -radix hexadecimal /testbench/du_e/udpdaisy_e/sioudpp_e/flow_hwdatx
add wave -noupdate -radix hexadecimal /testbench/du_e/udpdaisy_e/sioudpp_e/flow_ipv4datx
add wave -noupdate -radix hexadecimal /testbench/du_e/udpdaisy_e/sioudpp_e/flow_udpdptx
add wave -noupdate -radix hexadecimal /testbench/du_e/udpdaisy_e/sioudpp_e/flow_udpsptx
add wave -noupdate -radix hexadecimal /testbench/du_e/udpdaisy_e/sioudpp_e/flow_udplentx
add wave -noupdate -radix hexadecimal /testbench/du_e/udpdaisy_e/sioudpp_e/flow_e/phyo_trdy
add wave -noupdate /testbench/du_e/udpdaisy_e/sioudpp_e/flow_frm
add wave -noupdate -radix hexadecimal /testbench/du_e/udpdaisy_e/sioudpp_e/tx_b/rgtr_data
add wave -noupdate -radix hexadecimal /testbench/du_e/udpdaisy_e/sioudpp_e/flow_data
add wave -noupdate -radix hexadecimal /testbench/du_e/udpdaisy_e/sioudpp_e/udppl_txen
add wave -noupdate -radix hexadecimal /testbench/du_e/udpdaisy_e/sioudpp_e/udppl_txd
add wave -noupdate /testbench/du_e/udpdaisy_e/sioudpp_e/tx_b/siosin_e/sin_frm
add wave -noupdate -radix hexadecimal /testbench/du_e/udpdaisy_e/sioudpp_e/tx_b/siosin_e/line__52/rid
add wave -noupdate -radix hexadecimal /testbench/du_e/udpdaisy_e/sioudpp_e/tx_b/siosin_e/rgtr_id
add wave -noupdate -radix hexadecimal /testbench/du_e/udpdaisy_e/sioudpp_e/tx_b/rgtr_id
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {28595005000 fs} 0}
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
WaveRestoreZoom {26875957790 fs} {30314052210 fs}
