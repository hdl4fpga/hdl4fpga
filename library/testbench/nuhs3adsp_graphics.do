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
add wave -noupdate /testbench/du_e/si_b/siosin_e/sin_clk
add wave -noupdate /testbench/du_e/si_b/siosin_e/sin_frm
add wave -noupdate /testbench/du_e/si_b/siosin_e/sin_irdy
add wave -noupdate /testbench/du_e/si_b/siosin_e/sin_trdy
add wave -noupdate -radix hexadecimal /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/tx_hwda
add wave -noupdate -radix hexadecimal /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/tx_ipv4da
add wave -noupdate -radix hexadecimal /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/tx_ipport
add wave -noupdate /testbench/du_e/si_b/siodma_e/sio_frm
add wave -noupdate /testbench/du_e/si_b/siodma_e/so_irdy
add wave -noupdate /testbench/du_e/si_b/siodma_e/so_trdy
add wave -noupdate -radix hexadecimal /testbench/du_e/si_b/siodma_e/so_data
add wave -noupdate /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/si_trdy
add wave -noupdate /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/tx_b/des_frm
add wave -noupdate /testbench/du_e/si_b/siodma_e/sio_clk
add wave -noupdate /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/usr_gnt
add wave -noupdate /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/usr_trdy
add wave -noupdate /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/tx_b/des_frm
add wave -noupdate /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/tx_b/data_irdy
add wave -noupdate -radix hexadecimal /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/tx_b/xxx
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix hexadecimal /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/usr_txd
add wave -noupdate /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/usr_txen
add wave -noupdate /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/tx_b/rgtr_idv
add wave -noupdate -radix hexadecimal /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/tx_b/rgtr_id
add wave -noupdate /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/si_frm
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/si_b/udpdaisy_e/so_frm
add wave -noupdate /testbench/du_e/si_b/sou_frm
add wave -noupdate /testbench/du_e/si_b/siodmaio_irdy
add wave -noupdate /testbench/du_e/si_b/siodmaio_trdy
add wave -noupdate -radix hexadecimal /testbench/du_e/si_b/siodma_e/so_data
add wave -noupdate /testbench/du_e/si_b/siodma_e/so_end
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/tx_b/siosin_e/sin_irdy
add wave -noupdate /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/tx_b/siosin_e/sin_trdy
add wave -noupdate /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/tx_b/rgtr_frm
add wave -noupdate /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/tx_b/rgtr_irdy
add wave -noupdate /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/tx_b/rgtr_trdy
add wave -noupdate -radix hexadecimal /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/tx_b/des_data
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/tx_b/desser_e/des_frm
add wave -noupdate /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/tx_b/desser_e/des_irdy
add wave -noupdate /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/tx_b/desser_e/des_trdy
add wave -noupdate -radix hexadecimal /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/tx_b/des_data
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/tx_b/desser_e/ser_irdy
add wave -noupdate /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/tx_b/desser_e/ser_trdy
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {282506393860 fs} 0}
quietly wave cursor active 1
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
