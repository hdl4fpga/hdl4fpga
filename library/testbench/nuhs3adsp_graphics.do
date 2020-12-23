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
add wave -noupdate -radix hexadecimal /testbench/du_e/dmaio_len
add wave -noupdate -radix hexadecimal /testbench/du_e/dmaio_addr
add wave -noupdate /testbench/du_e/ddr_ckp
add wave -noupdate /testbench/du_e/ddr_cas
add wave -noupdate /testbench/du_e/ddr_ras
add wave -noupdate /testbench/du_e/ddr_we
add wave -noupdate /testbench/du_e/ddr_ba
add wave -noupdate -radix hexadecimal -childformat {{/testbench/du_e/ddr_a(12) -radix hexadecimal} {/testbench/du_e/ddr_a(11) -radix hexadecimal} {/testbench/du_e/ddr_a(10) -radix hexadecimal} {/testbench/du_e/ddr_a(9) -radix hexadecimal} {/testbench/du_e/ddr_a(8) -radix hexadecimal} {/testbench/du_e/ddr_a(7) -radix hexadecimal} {/testbench/du_e/ddr_a(6) -radix hexadecimal} {/testbench/du_e/ddr_a(5) -radix hexadecimal} {/testbench/du_e/ddr_a(4) -radix hexadecimal} {/testbench/du_e/ddr_a(3) -radix hexadecimal} {/testbench/du_e/ddr_a(2) -radix hexadecimal} {/testbench/du_e/ddr_a(1) -radix hexadecimal} {/testbench/du_e/ddr_a(0) -radix hexadecimal}} -subitemconfig {/testbench/du_e/ddr_a(12) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(11) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(10) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(9) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(8) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(7) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(6) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(5) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(4) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(3) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(2) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(1) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(0) {-height 29 -radix hexadecimal}} /testbench/du_e/ddr_a
add wave -noupdate -expand /testbench/du_e/ddr_dqs
add wave -noupdate -radix hexadecimal /testbench/du_e/ddr_dq
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 2} {201237188870 fs} 0} {{Cursor 3} {333999578160 fs} 0}
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
WaveRestoreZoom {0 fs} {420 us}
