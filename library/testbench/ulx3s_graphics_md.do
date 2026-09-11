onerror {resume}
quietly virtual signal -install /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/rxserlzr_e {/testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/rxserlzr_e/dst_data  } rev_data
quietly virtual signal -install /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e { (context /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e )( srzrx_data(7) & srzrx_data(6) & srzrx_data(5) & srzrx_data(4) & srzrx_data(3) & srzrx_data(2) & srzrx_data(1) & srzrx_data(0) )} rev_srzrx_data
quietly virtual signal -install /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e { (context /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e )( pylrx_data(7) & pylrx_data(6) & pylrx_data(5) & pylrx_data(4) & pylrx_data(3) & pylrx_data(2) & pylrx_data(1) & pylrx_data(0) )} rev_pylrx_data
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {CGA CODE}
add wave -noupdate /testbench/du_e/video_g/ser_debug_e/ser_display_e/cga_we
add wave -noupdate -radix ascii /testbench/du_e/video_g/ser_debug_e/ser_display_e/cga_codes
add wave -noupdate -divider RX
add wave -noupdate /testbench/rmii_clk
add wave -noupdate /testbench/rmii_rxdv
add wave -noupdate -radix binary /testbench/rmii_rxd
add wave -noupdate /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/fcs_sb
add wave -noupdate /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/fcs_vld
add wave -noupdate -divider TX
add wave -noupdate /testbench/rmii_txen
add wave -noupdate -radix hexadecimal -childformat {{/testbench/rmii_txd(0) -radix hexadecimal} {/testbench/rmii_txd(1) -radix hexadecimal}} -subitemconfig {/testbench/rmii_txd(0) {-height 20 -radix hexadecimal} /testbench/rmii_txd(1) {-height 20 -radix hexadecimal}} /testbench/rmii_txd
add wave -noupdate /testbench/tb_ipoe_b/tbipoe_e/tbehrx_e/fcs_sb
add wave -noupdate /testbench/tb_ipoe_b/tbipoe_e/tbehrx_e/fcs_vld
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/udppylrx_frm
add wave -noupdate /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/udppylrx_irdy
add wave -noupdate /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/udppylrx_trdy
add wave -noupdate -radix binary -childformat {{/testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/udppylrx_data(0) -radix hexadecimal} {/testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/udppylrx_data(1) -radix hexadecimal}} -subitemconfig {/testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/udppylrx_data(0) {-height 20 -radix hexadecimal} /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/udppylrx_data(1) {-height 20 -radix hexadecimal}} /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/udppylrx_data
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/srzrx_frm
add wave -noupdate /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/srzrx_irdy
add wave -noupdate /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/srzrx_trdy
add wave -noupdate -radix hexadecimal -childformat {{/testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/srzrx_data(0) -radix hexadecimal} {/testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/srzrx_data(1) -radix hexadecimal} {/testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/srzrx_data(2) -radix hexadecimal} {/testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/srzrx_data(3) -radix hexadecimal} {/testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/srzrx_data(4) -radix hexadecimal} {/testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/srzrx_data(5) -radix hexadecimal} {/testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/srzrx_data(6) -radix hexadecimal} {/testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/srzrx_data(7) -radix hexadecimal}} -subitemconfig {/testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/srzrx_data(0) {-height 20 -radix hexadecimal} /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/srzrx_data(1) {-height 20 -radix hexadecimal} /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/srzrx_data(2) {-height 20 -radix hexadecimal} /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/srzrx_data(3) {-height 20 -radix hexadecimal} /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/srzrx_data(4) {-height 20 -radix hexadecimal} /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/srzrx_data(5) {-height 20 -radix hexadecimal} /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/srzrx_data(6) {-height 20 -radix hexadecimal} /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/srzrx_data(7) {-height 20 -radix hexadecimal}} /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/srzrx_data
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/rev_srzrx_data
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/pylfcs_sb
add wave -noupdate /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/pylfcs_vld
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/sio_flow_e/rx_clk
add wave -noupdate /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/sio_flow_e/rx_frm
add wave -noupdate /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/sio_flow_e/rx_irdy
add wave -noupdate /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/sio_flow_e/rx_trdy
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/sio_flow_e/rx_data
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -expand /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/sio_flow_e/rgtr0_acts
add wave -noupdate -expand /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/sio_flow_e/rgtr0_frms
add wave -noupdate -expand /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/sio_flow_e/rgtr0_irdys
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {5073821360 fs} 0} {{Cursor 2} {5775382470 fs} 0}
quietly wave cursor active 1
configure wave -namecolwidth 178
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
WaveRestoreZoom {3211733950 fs} {6365480590 fs}
