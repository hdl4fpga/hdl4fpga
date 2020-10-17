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
add wave -noupdate -radix hexadecimal /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/mii_ipoe_e/ethrx_e/crc_e/mii_crc32
add wave -noupdate /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/mii_ipoe_e/ethrx_e/crc32_equ
add wave -noupdate /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/mii_ipoe_e/typeip4_rcvd
add wave -noupdate /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/mii_ipoe_e/myip4a_rcvd
add wave -noupdate /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/miisio_e/myport_rcvd
add wave -noupdate /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/miisio_e/udppl_rxdv
add wave -noupdate -radix hexadecimal /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/mii_ipoe_e/ethrx_e/eth_crc32
add wave -noupdate /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/buffer_p/des_irdy
add wave -noupdate /testbench/du_e/si_b/udpdaisy_e/so_frm
add wave -noupdate -radix hexadecimal /testbench/du_e/si_b/no_sidata
add wave -noupdate -radix hexadecimal /testbench/du_e/si_b/udpdaisy_e/sioudpp_e/buffer_p/des_data
add wave -noupdate /testbench/du_e/si_b/udpdaisy_e/so_irdy
add wave -noupdate -radix hexadecimal /testbench/du_e/si_b/udpdaisy_e/so_data
add wave -noupdate -radix hexadecimal /testbench/du_e/si_b/siosin_e/rgtr_data
add wave -noupdate -radix hexadecimal /testbench/du_e/si_b/siosin_e/rgtr_dv
add wave -noupdate -radix hexadecimal /testbench/du_e/si_b/siosin_e/rgtr_id
add wave -noupdate -radix hexadecimal -childformat {{/testbench/du_e/dmaio_addr(24) -radix hexadecimal} {/testbench/du_e/dmaio_addr(23) -radix hexadecimal} {/testbench/du_e/dmaio_addr(22) -radix hexadecimal} {/testbench/du_e/dmaio_addr(21) -radix hexadecimal} {/testbench/du_e/dmaio_addr(20) -radix hexadecimal} {/testbench/du_e/dmaio_addr(19) -radix hexadecimal} {/testbench/du_e/dmaio_addr(18) -radix hexadecimal} {/testbench/du_e/dmaio_addr(17) -radix hexadecimal} {/testbench/du_e/dmaio_addr(16) -radix hexadecimal} {/testbench/du_e/dmaio_addr(15) -radix hexadecimal} {/testbench/du_e/dmaio_addr(14) -radix hexadecimal} {/testbench/du_e/dmaio_addr(13) -radix hexadecimal} {/testbench/du_e/dmaio_addr(12) -radix hexadecimal} {/testbench/du_e/dmaio_addr(11) -radix hexadecimal} {/testbench/du_e/dmaio_addr(10) -radix hexadecimal} {/testbench/du_e/dmaio_addr(9) -radix hexadecimal} {/testbench/du_e/dmaio_addr(8) -radix hexadecimal} {/testbench/du_e/dmaio_addr(7) -radix hexadecimal} {/testbench/du_e/dmaio_addr(6) -radix hexadecimal} {/testbench/du_e/dmaio_addr(5) -radix hexadecimal} {/testbench/du_e/dmaio_addr(4) -radix hexadecimal} {/testbench/du_e/dmaio_addr(3) -radix hexadecimal} {/testbench/du_e/dmaio_addr(2) -radix hexadecimal}} -subitemconfig {/testbench/du_e/dmaio_addr(24) {-height 29 -radix hexadecimal} /testbench/du_e/dmaio_addr(23) {-height 29 -radix hexadecimal} /testbench/du_e/dmaio_addr(22) {-height 29 -radix hexadecimal} /testbench/du_e/dmaio_addr(21) {-height 29 -radix hexadecimal} /testbench/du_e/dmaio_addr(20) {-height 29 -radix hexadecimal} /testbench/du_e/dmaio_addr(19) {-height 29 -radix hexadecimal} /testbench/du_e/dmaio_addr(18) {-height 29 -radix hexadecimal} /testbench/du_e/dmaio_addr(17) {-height 29 -radix hexadecimal} /testbench/du_e/dmaio_addr(16) {-height 29 -radix hexadecimal} /testbench/du_e/dmaio_addr(15) {-height 29 -radix hexadecimal} /testbench/du_e/dmaio_addr(14) {-height 29 -radix hexadecimal} /testbench/du_e/dmaio_addr(13) {-height 29 -radix hexadecimal} /testbench/du_e/dmaio_addr(12) {-height 29 -radix hexadecimal} /testbench/du_e/dmaio_addr(11) {-height 29 -radix hexadecimal} /testbench/du_e/dmaio_addr(10) {-height 29 -radix hexadecimal} /testbench/du_e/dmaio_addr(9) {-height 29 -radix hexadecimal} /testbench/du_e/dmaio_addr(8) {-height 29 -radix hexadecimal} /testbench/du_e/dmaio_addr(7) {-height 29 -radix hexadecimal} /testbench/du_e/dmaio_addr(6) {-height 29 -radix hexadecimal} /testbench/du_e/dmaio_addr(5) {-height 29 -radix hexadecimal} /testbench/du_e/dmaio_addr(4) {-height 29 -radix hexadecimal} /testbench/du_e/dmaio_addr(3) {-height 29 -radix hexadecimal} /testbench/du_e/dmaio_addr(2) {-height 29 -radix hexadecimal}} /testbench/du_e/dmaio_addr
add wave -noupdate -radix hexadecimal /testbench/du_e/dmaio_len
add wave -noupdate /testbench/du_e/sio_clk
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/dmavideo_req
add wave -noupdate /testbench/du_e/dmavideo_rdy
add wave -noupdate -radix unsigned /testbench/du_e/dmavideo_len
add wave -noupdate -radix hexadecimal /testbench/du_e/dmavideo_addr
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/si_b/dmadata_e/dst_irdy
add wave -noupdate /testbench/du_e/si_b/dmadata_e/dst_irdy1
add wave -noupdate /testbench/du_e/dmacfgio_req
add wave -noupdate /testbench/du_e/dmacfgio_rdy
add wave -noupdate /testbench/du_e/dmaio_req
add wave -noupdate /testbench/du_e/dmaio_trdy
add wave -noupdate /testbench/du_e/dmaio_rdy
add wave -noupdate /testbench/du_e/ctlr_clk
add wave -noupdate /testbench/du_e/ctlr_di_dv
add wave -noupdate /testbench/du_e/ctlr_di_req
add wave -noupdate /testbench/du_e/si_b/dmadata_trdy
add wave -noupdate /testbench/du_e/si_b/line__377/q
add wave -noupdate -radix hexadecimal /testbench/du_e/ctlr_di
add wave -noupdate -radix hexadecimal -childformat {{/testbench/du_e/ddr_a(12) -radix hexadecimal} {/testbench/du_e/ddr_a(11) -radix hexadecimal} {/testbench/du_e/ddr_a(10) -radix hexadecimal} {/testbench/du_e/ddr_a(9) -radix hexadecimal} {/testbench/du_e/ddr_a(8) -radix hexadecimal} {/testbench/du_e/ddr_a(7) -radix hexadecimal} {/testbench/du_e/ddr_a(6) -radix hexadecimal} {/testbench/du_e/ddr_a(5) -radix hexadecimal} {/testbench/du_e/ddr_a(4) -radix hexadecimal} {/testbench/du_e/ddr_a(3) -radix hexadecimal} {/testbench/du_e/ddr_a(2) -radix hexadecimal} {/testbench/du_e/ddr_a(1) -radix hexadecimal} {/testbench/du_e/ddr_a(0) -radix hexadecimal}} -subitemconfig {/testbench/du_e/ddr_a(12) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(11) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(10) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(9) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(8) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(7) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(6) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(5) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(4) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(3) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(2) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(1) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_a(0) {-height 29 -radix hexadecimal}} /testbench/du_e/ddr_a
add wave -noupdate -radix hexadecimal -childformat {{/testbench/du_e/ddr_dq(15) -radix hexadecimal} {/testbench/du_e/ddr_dq(14) -radix hexadecimal} {/testbench/du_e/ddr_dq(13) -radix hexadecimal} {/testbench/du_e/ddr_dq(12) -radix hexadecimal} {/testbench/du_e/ddr_dq(11) -radix hexadecimal} {/testbench/du_e/ddr_dq(10) -radix hexadecimal} {/testbench/du_e/ddr_dq(9) -radix hexadecimal} {/testbench/du_e/ddr_dq(8) -radix hexadecimal} {/testbench/du_e/ddr_dq(7) -radix hexadecimal} {/testbench/du_e/ddr_dq(6) -radix hexadecimal} {/testbench/du_e/ddr_dq(5) -radix hexadecimal} {/testbench/du_e/ddr_dq(4) -radix hexadecimal} {/testbench/du_e/ddr_dq(3) -radix hexadecimal} {/testbench/du_e/ddr_dq(2) -radix hexadecimal} {/testbench/du_e/ddr_dq(1) -radix hexadecimal} {/testbench/du_e/ddr_dq(0) -radix hexadecimal}} -subitemconfig {/testbench/du_e/ddr_dq(15) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_dq(14) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_dq(13) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_dq(12) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_dq(11) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_dq(10) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_dq(9) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_dq(8) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_dq(7) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_dq(6) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_dq(5) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_dq(4) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_dq(3) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_dq(2) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_dq(1) {-height 29 -radix hexadecimal} /testbench/du_e/ddr_dq(0) {-height 29 -radix hexadecimal}} /testbench/du_e/ddr_dq
add wave -noupdate /testbench/du_e/ddr_ras
add wave -noupdate /testbench/du_e/ddr_cas
add wave -noupdate /testbench/du_e/ddr_we
add wave -noupdate /testbench/du_e/ddr_ba
add wave -noupdate /testbench/du_e/ddr_ckp
add wave -noupdate -expand -group micron /testbench/ddr_model_g/Clk
add wave -noupdate -expand -group micron /testbench/ddr_model_g/Ba
add wave -noupdate -expand -group micron -radix hexadecimal -childformat {{{/testbench/ddr_model_g/Addr[12]} -radix hexadecimal} {{/testbench/ddr_model_g/Addr[11]} -radix hexadecimal} {{/testbench/ddr_model_g/Addr[10]} -radix hexadecimal} {{/testbench/ddr_model_g/Addr[9]} -radix hexadecimal} {{/testbench/ddr_model_g/Addr[8]} -radix hexadecimal} {{/testbench/ddr_model_g/Addr[7]} -radix hexadecimal} {{/testbench/ddr_model_g/Addr[6]} -radix hexadecimal} {{/testbench/ddr_model_g/Addr[5]} -radix hexadecimal} {{/testbench/ddr_model_g/Addr[4]} -radix hexadecimal} {{/testbench/ddr_model_g/Addr[3]} -radix hexadecimal} {{/testbench/ddr_model_g/Addr[2]} -radix hexadecimal} {{/testbench/ddr_model_g/Addr[1]} -radix hexadecimal} {{/testbench/ddr_model_g/Addr[0]} -radix hexadecimal}} -subitemconfig {{/testbench/ddr_model_g/Addr[12]} {-height 29 -radix hexadecimal} {/testbench/ddr_model_g/Addr[11]} {-height 29 -radix hexadecimal} {/testbench/ddr_model_g/Addr[10]} {-height 29 -radix hexadecimal} {/testbench/ddr_model_g/Addr[9]} {-height 29 -radix hexadecimal} {/testbench/ddr_model_g/Addr[8]} {-height 29 -radix hexadecimal} {/testbench/ddr_model_g/Addr[7]} {-height 29 -radix hexadecimal} {/testbench/ddr_model_g/Addr[6]} {-height 29 -radix hexadecimal} {/testbench/ddr_model_g/Addr[5]} {-height 29 -radix hexadecimal} {/testbench/ddr_model_g/Addr[4]} {-height 29 -radix hexadecimal} {/testbench/ddr_model_g/Addr[3]} {-height 29 -radix hexadecimal} {/testbench/ddr_model_g/Addr[2]} {-height 29 -radix hexadecimal} {/testbench/ddr_model_g/Addr[1]} {-height 29 -radix hexadecimal} {/testbench/ddr_model_g/Addr[0]} {-height 29 -radix hexadecimal}} /testbench/ddr_model_g/Addr
add wave -noupdate -expand -group micron /testbench/ddr_model_g/Ras_n
add wave -noupdate -expand -group micron /testbench/ddr_model_g/Cas_n
add wave -noupdate -expand -group micron /testbench/ddr_model_g/We_n
add wave -noupdate -expand -group micron -radix hexadecimal -childformat {{{/testbench/ddr_model_g/Dq[15]} -radix hexadecimal} {{/testbench/ddr_model_g/Dq[14]} -radix hexadecimal} {{/testbench/ddr_model_g/Dq[13]} -radix hexadecimal} {{/testbench/ddr_model_g/Dq[12]} -radix hexadecimal} {{/testbench/ddr_model_g/Dq[11]} -radix hexadecimal} {{/testbench/ddr_model_g/Dq[10]} -radix hexadecimal} {{/testbench/ddr_model_g/Dq[9]} -radix hexadecimal} {{/testbench/ddr_model_g/Dq[8]} -radix hexadecimal} {{/testbench/ddr_model_g/Dq[7]} -radix hexadecimal} {{/testbench/ddr_model_g/Dq[6]} -radix hexadecimal} {{/testbench/ddr_model_g/Dq[5]} -radix hexadecimal} {{/testbench/ddr_model_g/Dq[4]} -radix hexadecimal} {{/testbench/ddr_model_g/Dq[3]} -radix hexadecimal} {{/testbench/ddr_model_g/Dq[2]} -radix hexadecimal} {{/testbench/ddr_model_g/Dq[1]} -radix hexadecimal} {{/testbench/ddr_model_g/Dq[0]} -radix hexadecimal}} -subitemconfig {{/testbench/ddr_model_g/Dq[15]} {-height 29 -radix hexadecimal} {/testbench/ddr_model_g/Dq[14]} {-height 29 -radix hexadecimal} {/testbench/ddr_model_g/Dq[13]} {-height 29 -radix hexadecimal} {/testbench/ddr_model_g/Dq[12]} {-height 29 -radix hexadecimal} {/testbench/ddr_model_g/Dq[11]} {-height 29 -radix hexadecimal} {/testbench/ddr_model_g/Dq[10]} {-height 29 -radix hexadecimal} {/testbench/ddr_model_g/Dq[9]} {-height 29 -radix hexadecimal} {/testbench/ddr_model_g/Dq[8]} {-height 29 -radix hexadecimal} {/testbench/ddr_model_g/Dq[7]} {-height 29 -radix hexadecimal} {/testbench/ddr_model_g/Dq[6]} {-height 29 -radix hexadecimal} {/testbench/ddr_model_g/Dq[5]} {-height 29 -radix hexadecimal} {/testbench/ddr_model_g/Dq[4]} {-height 29 -radix hexadecimal} {/testbench/ddr_model_g/Dq[3]} {-height 29 -radix hexadecimal} {/testbench/ddr_model_g/Dq[2]} {-height 29 -radix hexadecimal} {/testbench/ddr_model_g/Dq[1]} {-height 29 -radix hexadecimal} {/testbench/ddr_model_g/Dq[0]} {-height 29 -radix hexadecimal}} /testbench/ddr_model_g/Dq
add wave -noupdate -expand -group micron -expand /testbench/ddr_model_g/Dqs
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {206458000000 fs} 0}
quietly wave cursor active 1
configure wave -namecolwidth 234
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
WaveRestoreZoom {205588671680 fs} {207311328320 fs}
