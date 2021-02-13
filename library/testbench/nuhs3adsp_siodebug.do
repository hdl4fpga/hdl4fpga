onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/du_e/mii_rxc
add wave -noupdate /testbench/du_e/mii_rxdv
add wave -noupdate -radix hexadecimal /testbench/du_e/mii_rxd
add wave -noupdate /testbench/du_e/mii_txen
add wave -noupdate /testbench/du_e/mii_txc
add wave -noupdate -radix hexadecimal /testbench/du_e/mii_txd
add wave -noupdate /testbench/du_e/udpdaisy_e/sioudpp_e/mii_ipoe_e/dllfcs_vld
add wave -noupdate /testbench/du_e/udpdaisy_e/sioudpp_e/flow_e/buffer_cmmt
add wave -noupdate /testbench/du_e/udpdaisy_e/sioudpp_e/flow_e/buffer_rllk
add wave -noupdate /testbench/du_e/udpdaisy_e/sioudpp_e/flow_e/buffer_ovfl
add wave -noupdate -expand /testbench/du_e/udpdaisy_e/sioudpp_e/mii_ipoe_e/mii_gnt
add wave -noupdate /testbench/du_e/udpdaisy_e/sioudpp_e/flow_req
add wave -noupdate /testbench/du_e/udpdaisy_e/sioudpp_e/tx_b/siosin_e/sin_frm
add wave -noupdate /testbench/du_e/udpdaisy_e/sioudpp_e/tx_b/siosin_e/sin_irdy
add wave -noupdate /testbench/du_e/udpdaisy_e/sioudpp_e/tx_b/siosin_e/sin_trdy
add wave -noupdate -radix hexadecimal /testbench/du_e/udpdaisy_e/sioudpp_e/tx_b/siosin_e/sin_data
add wave -noupdate -radix hexadecimal /testbench/du_e/udpdaisy_e/sioudpp_e/tx_b/rgtr_id
add wave -noupdate /testbench/du_e/udpdaisy_e/sioudpp_e/tx_b/siosin_e/sin_clk
add wave -noupdate /testbench/du_e/udpdaisy_e/sioudpp_e/mii_ipoe_e/udppl_txen
add wave -noupdate -radix hexadecimal /testbench/du_e/udpdaisy_e/sioudpp_e/mii_ipoe_e/udppl_txd
add wave -noupdate -radix hexadecimal /testbench/du_e/udpdaisy_e/sioudpp_e/flow_hwdatx
add wave -noupdate -radix hexadecimal /testbench/du_e/udpdaisy_e/sioudpp_e/flow_ipv4datx
add wave -noupdate -radix hexadecimal /testbench/du_e/udpdaisy_e/sioudpp_e/flow_udpdptx
add wave -noupdate -radix hexadecimal /testbench/du_e/udpdaisy_e/sioudpp_e/flow_udpsptx
add wave -noupdate -radix hexadecimal /testbench/du_e/udpdaisy_e/sioudpp_e/flow_udplentx
add wave -noupdate -expand /testbench/du_e/udpdaisy_e/sioudpp_e/mii_ipoe_e/mii_rdy
add wave -noupdate /testbench/du_e/udpdaisy_e/sioudpp_e/mii_ipoe_e/arbiter_b/ena
add wave -noupdate /testbench/du_e/udpdaisy_e/sioudpp_e/mii_ipoe_e/arbiter_b/req
add wave -noupdate /testbench/du_e/udpdaisy_e/sioudpp_e/mii_ipoe_e/arbiter_b/miignt_e/gnt(2)
add wave -noupdate /testbench/du_e/udpdaisy_e/sioudpp_e/mii_ipoe_e/arbiter_b/req(2)
add wave -noupdate /testbench/du_e/udpdaisy_e/sioudpp_e/mii_ipoe_e/arbiter_b/line__226/cntr
add wave -noupdate /testbench/du_e/udpdaisy_e/sioudpp_e/mii_ipoe_e/mii_rdy(2)
add wave -noupdate /testbench/du_e/mii_txen
add wave -noupdate /testbench/du_e/udpdaisy_e/sioudpp_e/mii_ipoe_e/arbiter_b/line__226/q
add wave -noupdate /testbench/du_e/udpdaisy_e/sioudpp_e/mii_ipoe_e/arbiter_b/miignt_e/req(2)
add wave -noupdate -expand /testbench/du_e/udpdaisy_e/sioudpp_e/mii_ipoe_e/arbiter_b/miignt_e/gnt
add wave -noupdate -expand /testbench/du_e/udpdaisy_e/sioudpp_e/mii_ipoe_e/arbiter_b/miignt_e/req
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {25395005000 fs} 0}
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
WaveRestoreZoom {24968442500 fs} {25821567500 fs}
