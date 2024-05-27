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
add wave -noupdate /testbench/du_e/udpdaisy_e/sioudpp_e/mii_ipoe_e/tx_req
add wave -noupdate /testbench/du_e/udpdaisy_e/sioudpp_e/mii_ipoe_e/tx_gnt
add wave -noupdate /testbench/du_e/udpdaisy_e/sioudpp_e/mii_ipoe_e/icmp_gnt
add wave -noupdate /testbench/du_e/udpdaisy_e/sioudpp_e/mii_ipoe_e/icmp_req
add wave -noupdate /testbench/du_e/udpdaisy_e/sioudpp_e/mii_ipoe_e/ip4_b/icmp_txen
add wave -noupdate -radix hexadecimal /testbench/du_e/udpdaisy_e/sioudpp_e/mii_ipoe_e/ip4_b/icmp_txd
add wave -noupdate -radix hexadecimal /testbench/du_e/udpdaisy_e/sioudpp_e/mii_ipoe_e/ip4_b/icmp_b/icmpcksm_data
add wave -noupdate -radix hexadecimal /testbench/du_e/udpdaisy_e/sioudpp_e/mii_ipoe_e/ip4_b/icmp_b/icmprply_cksm
add wave -noupdate /testbench/du_e/udpdaisy_e/sioudpp_e/mii_ipoe_e/ip4_b/icmp_b/icmppl_txen
add wave -noupdate -radix hexadecimal /testbench/du_e/udpdaisy_e/sioudpp_e/mii_ipoe_e/ip4_b/icmp_b/icmppl_txd
add wave -noupdate -expand /testbench/du_e/udpdaisy_e/sioudpp_e/mii_ipoe_e/arbiter_b/req
add wave -noupdate -expand /testbench/du_e/udpdaisy_e/sioudpp_e/mii_ipoe_e/arbiter_b/gnt
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {33235005000 fs} 0}
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
WaveRestoreZoom {24305005 ps} {34805005 ps}
