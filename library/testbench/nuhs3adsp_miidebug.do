onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/du_e/mii_debug_e/mii_txc
add wave -noupdate /testbench/du_e/mii_debug_e/mii_treq
add wave -noupdate -radix hexadecimal /testbench/du_e/mii_debug_e/mii_txd
add wave -noupdate /testbench/du_e/mii_debug_e/mii_txen
add wave -noupdate /testbench/du_e/mii_debug_e/arptx_e/arp_treq
add wave -noupdate /testbench/du_e/mii_debug_e/arptx_e/arp_trdy
add wave -noupdate /testbench/du_e/mii_debug_e/arptx_e/arp_txen
add wave -noupdate -radix hexadecimal /testbench/du_e/mii_debug_e/arptx_e/arp_txd
add wave -noupdate /testbench/du_e/mii_debug_e/arptx_e/tha_txen
add wave -noupdate /testbench/du_e/mii_debug_e/arptx_e/pfx_txen
add wave -noupdate /testbench/du_e/mii_debug_e/arptx_e/ipsa_txen
add wave -noupdate /testbench/du_e/mii_debug_e/arptx_e/arp_treq
add wave -noupdate /testbench/du_e/mii_debug_e/ethtx_e/eth_txen
add wave -noupdate -radix hexadecimal /testbench/du_e/mii_debug_e/ethtx_e/eth_txd
add wave -noupdate /testbench/du_e/mii_debug_e/ethtx_e/dll_e/pre_txen
add wave -noupdate /testbench/du_e/mii_debug_e/ethtx_e/dll_e/crc32_txen
add wave -noupdate -radix hexadecimal /testbench/du_e/mii_debug_e/ethtx_e/dll_e/crc32_txd
add wave -noupdate -radix hexadecimal /testbench/du_e/mii_debug_e/ethtx_e/pl_txd
add wave -noupdate /testbench/du_e/mii_debug_e/ethtx_e/lat_txen
add wave -noupdate -radix hexadecimal /testbench/du_e/mii_debug_e/ethtx_e/lat_txd
add wave -noupdate /testbench/du_e/mii_debug_e/ethtx_e/dll_txen
add wave -noupdate -radix hexadecimal -childformat {{/testbench/du_e/mii_debug_e/ethtx_e/dll_txd(0) -radix hexadecimal} {/testbench/du_e/mii_debug_e/ethtx_e/dll_txd(1) -radix hexadecimal} {/testbench/du_e/mii_debug_e/ethtx_e/dll_txd(2) -radix hexadecimal} {/testbench/du_e/mii_debug_e/ethtx_e/dll_txd(3) -radix hexadecimal}} -subitemconfig {/testbench/du_e/mii_debug_e/ethtx_e/dll_txd(0) {-height 29 -radix hexadecimal} /testbench/du_e/mii_debug_e/ethtx_e/dll_txd(1) {-height 29 -radix hexadecimal} /testbench/du_e/mii_debug_e/ethtx_e/dll_txd(2) {-height 29 -radix hexadecimal} /testbench/du_e/mii_debug_e/ethtx_e/dll_txd(3) {-height 29 -radix hexadecimal}} /testbench/du_e/mii_debug_e/ethtx_e/dll_txd
add wave -noupdate /testbench/du_e/mii_debug_e/ethtx_e/hwda_txen
add wave -noupdate -radix hexadecimal /testbench/du_e/mii_debug_e/ethtx_e/hwda_txd
add wave -noupdate /testbench/du_e/mii_debug_e/ethtx_e/pl_txen
add wave -noupdate /testbench/du_e/mii_debug_e/ethtx_e/padd_txen
add wave -noupdate -radix hexadecimal /testbench/du_e/mii_debug_e/ethtx_e/padd_txd
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/mii_debug_e/iptx_e/mii_txc
add wave -noupdate /testbench/du_e/mii_debug_e/iptx_e/pl_txen
add wave -noupdate /testbench/du_e/mii_debug_e/iptx_e/pl_txd
add wave -noupdate /testbench/du_e/mii_debug_e/iptx_e/ip4len_treq
add wave -noupdate /testbench/du_e/mii_debug_e/iptx_e/ip4len_trdy
add wave -noupdate /testbench/du_e/mii_debug_e/iptx_e/ip4len_txen
add wave -noupdate /testbench/du_e/mii_debug_e/iplen_e/mii_treq
add wave -noupdate /testbench/du_e/mii_debug_e/iplen_e/mii_trdy
add wave -noupdate /testbench/du_e/mii_debug_e/iplen_e/mii_txen
add wave -noupdate /testbench/du_e/mii_debug_e/iptx_e/ip4len_txd
add wave -noupdate /testbench/du_e/mii_debug_e/iptx_e/ip4sa_treq
add wave -noupdate /testbench/du_e/mii_debug_e/iptx_e/ip4sa_trdy
add wave -noupdate /testbench/du_e/mii_debug_e/iptx_e/ip4sa_txen
add wave -noupdate /testbench/du_e/mii_debug_e/iptx_e/ip4sa_txd
add wave -noupdate /testbench/du_e/mii_debug_e/iptx_e/ip4da_treq
add wave -noupdate /testbench/du_e/mii_debug_e/iptx_e/ip4da_trdy
add wave -noupdate /testbench/du_e/mii_debug_e/iptx_e/ip4da_txen
add wave -noupdate /testbench/du_e/mii_debug_e/iptx_e/ip4da_txd
add wave -noupdate /testbench/du_e/mii_debug_e/iptx_e/ip4_txen
add wave -noupdate /testbench/du_e/mii_debug_e/iptx_e/ip4shdr_txen
add wave -noupdate /testbench/du_e/mii_debug_e/iptx_e/lenlat_txen
add wave -noupdate -radix hexadecimal /testbench/du_e/mii_debug_e/iptx_e/lenlat_txd
add wave -noupdate /testbench/du_e/mii_debug_e/iptx_e/ip4alat_txen
add wave -noupdate /testbench/du_e/mii_debug_e/iptx_e/ip4_txd
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1408996 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 219
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
WaveRestoreZoom {727604 ps} {2090388 ps}
