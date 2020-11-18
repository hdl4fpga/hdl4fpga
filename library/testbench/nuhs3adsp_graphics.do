onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/du_e/mii_rxc
add wave -noupdate /testbench/du_e/mii_rxdv
add wave -noupdate -radix hexadecimal /testbench/du_e/mii_rxd
add wave -noupdate /testbench/du_e/mii_txc
add wave -noupdate /testbench/du_e/mii_txen
add wave -noupdate -radix hexadecimal /testbench/du_e/mii_txd
add wave -noupdate /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/mii_ipoe_e/txc_rxdv
add wave -noupdate -radix hexadecimal -childformat {{/testbench/du_e/si_b/udpdaisy_e/sioudpp_e/mii_ipoe_e/txc_rxd(0) -radix hexadecimal} {/testbench/du_e/si_b/udpdaisy_e/sioudpp_e/mii_ipoe_e/txc_rxd(1) -radix hexadecimal} {/testbench/du_e/si_b/udpdaisy_e/sioudpp_e/mii_ipoe_e/txc_rxd(2) -radix hexadecimal} {/testbench/du_e/si_b/udpdaisy_e/sioudpp_e/mii_ipoe_e/txc_rxd(3) -radix hexadecimal}} -subitemconfig {/testbench/du_e/si_b/udpdaisy_e/sioudpp_e/mii_ipoe_e/txc_rxd(0) {-height 29 -radix hexadecimal} /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/mii_ipoe_e/txc_rxd(1) {-height 29 -radix hexadecimal} /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/mii_ipoe_e/txc_rxd(2) {-height 29 -radix hexadecimal} /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/mii_ipoe_e/txc_rxd(3) {-height 29 -radix hexadecimal}} /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/mii_ipoe_e/txc_rxd
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix hexadecimal /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/miisio_e/dll_hwda
add wave -noupdate /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/mii_ipoe_e/extern_gnt
add wave -noupdate -radix hexadecimal /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/mii_ipoe_e/hwda_tx
add wave -noupdate /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/mii_ipoe_e/ethtx_e/pl_txen
add wave -noupdate /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/mii_ipoe_e/ethtx_e/hwda_txen
add wave -noupdate -radix hexadecimal /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/mii_ipoe_e/ethtx_e/eth_ptr
add wave -noupdate /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/mii_ipoe_e/mii_gnt
add wave -noupdate -expand /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/miisio_e/mii_gnt
add wave -noupdate /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/mysrv_gnt
add wave -noupdate -expand /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/miisio_e/mii_req
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/si_frm
add wave -noupdate -radix hexadecimal /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/tx_ack
add wave -noupdate -radix hexadecimal /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/tx_hwda
add wave -noupdate -radix hexadecimal /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/tx_ipv4da
add wave -noupdate -radix hexadecimal /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/tx_udplen
add wave -noupdate -radix hexadecimal /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/tx_ipport
add wave -noupdate /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/tx_b/des_frm
add wave -noupdate /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/usr_req
add wave -noupdate /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/usr_gnt
add wave -noupdate /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/usr_rdy
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {36311608960 fs} 0} {{Cursor 2} {259441955190 fs} 0}
quietly wave cursor active 2
configure wave -namecolwidth 249
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
WaveRestoreZoom {0 fs} {315 us}
