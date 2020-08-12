onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/du_e/mii_debug_e/mii_txc
add wave -noupdate /testbench/du_e/mii_debug_e/mii_txen
add wave -noupdate -radix hexadecimal -childformat {{/testbench/du_e/mii_txd(0) -radix hexadecimal} {/testbench/du_e/mii_txd(1) -radix hexadecimal} {/testbench/du_e/mii_txd(2) -radix hexadecimal} {/testbench/du_e/mii_txd(3) -radix hexadecimal}} -subitemconfig {/testbench/du_e/mii_txd(0) {-height 15 -radix hexadecimal} /testbench/du_e/mii_txd(1) {-height 15 -radix hexadecimal} /testbench/du_e/mii_txd(2) {-height 15 -radix hexadecimal} /testbench/du_e/mii_txd(3) {-height 15 -radix hexadecimal}} /testbench/du_e/mii_txd
add wave -noupdate /testbench/du_e/mii_debug_e/arp_req
add wave -noupdate /testbench/du_e/mii_debug_e/mii_treq(0)
add wave -noupdate /testbench/du_e/mii_debug_e/mii_gnt(0)
add wave -noupdate /testbench/du_e/mii_debug_e/mii_rdy(0)
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/mii_debug_e/mii_gnt(1)
add wave -noupdate /testbench/du_e/mii_debug_e/mii_treq(1)
add wave -noupdate /testbench/du_e/mii_debug_e/mii_req(0)
add wave -noupdate /testbench/du_e/mii_debug_e/mii_req(1)
add wave -noupdate /testbench/du_e/mii_debug_e/mii_rdy(1)
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/mii_debug_e/mii_rxc
add wave -noupdate /testbench/du_e/mii_debug_e/mii_rxd
add wave -noupdate /testbench/du_e/mii_debug_e/mii_rxdv
add wave -noupdate /testbench/du_e/mii_debug_e/ethrx_e/eth_pre
add wave -noupdate /testbench/du_e/mii_debug_e/ethrx_e/hwda_rxdv
add wave -noupdate /testbench/du_e/mii_debug_e/ethrx_e/hwsa_rxdv
add wave -noupdate /testbench/du_e/mii_debug_e/ethrx_e/type_rxdv
add wave -noupdate /testbench/du_e/mii_debug_e/ctlr_b/typearp_equ
add wave -noupdate /testbench/du_e/mii_debug_e/ctlr_b/type_arp
add wave -noupdate /testbench/du_e/mii_debug_e/ctlr_b/arp_tpa
add wave -noupdate /testbench/du_e/mii_debug_e/ctlr_b/arpllccmp_e/mii_rxdv
add wave -noupdate /testbench/du_e/mii_debug_e/tp1
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/mii_debug_e/arptx_e/mii_txc
add wave -noupdate /testbench/du_e/mii_debug_e/arptx_e/mii_txen
add wave -noupdate /testbench/du_e/mii_debug_e/arptx_e/arp_frm
add wave -noupdate /testbench/du_e/mii_debug_e/arptx_e/sha_txen
add wave -noupdate /testbench/du_e/mii_debug_e/arptx_e/sha_txd
add wave -noupdate /testbench/du_e/mii_debug_e/arptx_e/spa_txen
add wave -noupdate /testbench/du_e/mii_debug_e/arptx_e/spa_txd
add wave -noupdate /testbench/du_e/mii_debug_e/arptx_e/tha_txen
add wave -noupdate /testbench/du_e/mii_debug_e/arptx_e/tpa_txen
add wave -noupdate /testbench/du_e/mii_debug_e/arptx_e/tha_txd
add wave -noupdate /testbench/du_e/mii_debug_e/arptx_e/tpa_txd
add wave -noupdate /testbench/du_e/mii_debug_e/arptx_e/arp_txen
add wave -noupdate /testbench/du_e/mii_debug_e/arptx_e/arp_txd
add wave -noupdate /testbench/du_e/mii_debug_e/arptx_e/pfx_txen
add wave -noupdate /testbench/du_e/mii_debug_e/arptx_e/pfx_txd
add wave -noupdate /testbench/du_e/mii_debug_e/myip4a_txen
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 2} {1035005 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 146
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
WaveRestoreZoom {0 ps} {2625 ns}
