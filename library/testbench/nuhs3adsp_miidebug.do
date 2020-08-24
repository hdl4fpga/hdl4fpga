onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/du_e/mii_debug_e/mii_txc
add wave -noupdate /testbench/du_e/mii_debug_e/mii_txen
add wave -noupdate -radix hexadecimal -childformat {{/testbench/du_e/mii_txd(0) -radix hexadecimal} {/testbench/du_e/mii_txd(1) -radix hexadecimal} {/testbench/du_e/mii_txd(2) -radix hexadecimal} {/testbench/du_e/mii_txd(3) -radix hexadecimal}} -subitemconfig {/testbench/du_e/mii_txd(0) {-height 15 -radix hexadecimal} /testbench/du_e/mii_txd(1) {-height 15 -radix hexadecimal} /testbench/du_e/mii_txd(2) {-height 15 -radix hexadecimal} /testbench/du_e/mii_txd(3) {-height 15 -radix hexadecimal}} /testbench/du_e/mii_txd
add wave -noupdate /testbench/du_e/mii_debug_e/ip4_e/mii_txc
add wave -noupdate /testbench/du_e/mii_debug_e/ip4_e/pl_len
add wave -noupdate /testbench/du_e/mii_debug_e/ip4_e/pl_txen
add wave -noupdate /testbench/du_e/mii_debug_e/ip4_e/pl_txd
add wave -noupdate /testbench/du_e/mii_debug_e/ip4_e/ip4sa
add wave -noupdate /testbench/du_e/mii_debug_e/ip4_e/ip4da
add wave -noupdate /testbench/du_e/mii_debug_e/ip4_e/ip4_ptr
add wave -noupdate /testbench/du_e/mii_debug_e/ip4_e/ip4_txen
add wave -noupdate /testbench/du_e/mii_debug_e/ip4_e/ip4_txd
add wave -noupdate /testbench/du_e/sw1
add wave -noupdate /testbench/du_e/mii_debug_e/pkt_req
add wave -noupdate /testbench/du_e/mii_debug_e/ip4_e/pkt_len
add wave -noupdate /testbench/du_e/mii_debug_e/ip4_e/cksm_txd
add wave -noupdate /testbench/du_e/mii_debug_e/ip4_e/ip4len_txen
add wave -noupdate /testbench/du_e/mii_debug_e/ip4_e/ip4da_txen
add wave -noupdate /testbench/du_e/mii_debug_e/ip4_e/ip4sa_txen
add wave -noupdate /testbench/du_e/mii_debug_e/ip4_e/lenlat_txen
add wave -noupdate /testbench/du_e/mii_debug_e/ip4_e/cksmd_txen
add wave -noupdate /testbench/du_e/mii_debug_e/ip4_e/alat_txen
add wave -noupdate /testbench/du_e/mii_debug_e/ip4_e/pllat_txen
add wave -noupdate /testbench/du_e/mii_debug_e/ip4_req
add wave -noupdate /testbench/du_e/mii_debug_e/ip4_e/line__91/txen
add wave -noupdate /testbench/du_e/mii_debug_e/ip4_e/ip4shdr_txen
add wave -noupdate -radix hexadecimal /testbench/du_e/mii_debug_e/ip4_e/ip4shdr_txd
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 2} {1715005 ps} 0}
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
WaveRestoreZoom {454203 ps} {2975808 ps}
