onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/du_e/mii_rxc
add wave -noupdate /testbench/du_e/mii_rxdv
add wave -noupdate -radix hexadecimal /testbench/du_e/mii_rxd
add wave -noupdate /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/mii_ipoe_e/txc_rxdv
add wave -noupdate -radix hexadecimal -childformat {{/testbench/du_e/si_b/udpdaisy_e/sioudpp_e/mii_ipoe_e/txc_rxd(0) -radix hexadecimal} {/testbench/du_e/si_b/udpdaisy_e/sioudpp_e/mii_ipoe_e/txc_rxd(1) -radix hexadecimal} {/testbench/du_e/si_b/udpdaisy_e/sioudpp_e/mii_ipoe_e/txc_rxd(2) -radix hexadecimal} {/testbench/du_e/si_b/udpdaisy_e/sioudpp_e/mii_ipoe_e/txc_rxd(3) -radix hexadecimal}} -subitemconfig {/testbench/du_e/si_b/udpdaisy_e/sioudpp_e/mii_ipoe_e/txc_rxd(0) {-height 29 -radix hexadecimal} /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/mii_ipoe_e/txc_rxd(1) {-height 29 -radix hexadecimal} /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/mii_ipoe_e/txc_rxd(2) {-height 29 -radix hexadecimal} /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/mii_ipoe_e/txc_rxd(3) {-height 29 -radix hexadecimal}} /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/mii_ipoe_e/txc_rxd
add wave -noupdate -radix hexadecimal /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/mii_ipoe_e/ethrx_e/crc_e/mii_crc32
add wave -noupdate /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/mii_ipoe_e/ethrx_e/crc32_equ
add wave -noupdate /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/mii_ipoe_e/typeip4_rcvd
add wave -noupdate /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/mii_ipoe_e/myip4a_rcvd
add wave -noupdate /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/miisio_e/myport_rcvd
add wave -noupdate /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/miisio_e/udppl_rxdv
add wave -noupdate -radix hexadecimal /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/buffer_p/wr_ptr
add wave -noupdate -radix hexadecimal /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/buffer_p/wr_cntr
add wave -noupdate -radix hexadecimal /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/buffer_p/rd_cntr
add wave -noupdate /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/buffer_p/des_irdy
add wave -noupdate /testbench/du_e/si_b/udpdaisy_e/so_frm
add wave -noupdate /testbench/du_e/si_b/udpdaisy_e/so_irdy
add wave -noupdate -radix hexadecimal /testbench/du_e/si_b/udpdaisy_e/so_data
add wave -noupdate -radix hexadecimal /testbench/du_e/si_b/siosin_e/rgtr_data
add wave -noupdate -radix hexadecimal /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/buffer_p/des_data
add wave -noupdate -radix hexadecimal /testbench/du_e/si_b/no_sidata
add wave -noupdate -radix hexadecimal /testbench/du_e/si_b/siosin_e/rgtr_dv
add wave -noupdate -radix hexadecimal /testbench/du_e/si_b/siosin_e/rgtr_id
add wave -noupdate -radix hexadecimal /testbench/du_e/dmaio_addr
add wave -noupdate -radix hexadecimal /testbench/du_e/dmaio_len
add wave -noupdate /testbench/du_e/mii_txc
add wave -noupdate /testbench/du_e/mii_txen
add wave -noupdate /testbench/du_e/mii_txd
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {47907652840 fs} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 569
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
WaveRestoreZoom {0 fs} {84 us}
