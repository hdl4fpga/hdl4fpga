onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/du_e/mii_debug_e/mii_txen
add wave -noupdate -radix hexadecimal -childformat {{/testbench/du_e/mii_txd(0) -radix hexadecimal} {/testbench/du_e/mii_txd(1) -radix hexadecimal} {/testbench/du_e/mii_txd(2) -radix hexadecimal} {/testbench/du_e/mii_txd(3) -radix hexadecimal}} -subitemconfig {/testbench/du_e/mii_txd(0) {-height 29 -radix hexadecimal} /testbench/du_e/mii_txd(1) {-height 29 -radix hexadecimal} /testbench/du_e/mii_txd(2) {-height 29 -radix hexadecimal} /testbench/du_e/mii_txd(3) {-height 29 -radix hexadecimal}} /testbench/du_e/mii_txd
add wave -noupdate /testbench/du_e/mii_debug_e/ip4_e/mii_txc
add wave -noupdate /testbench/du_e/mii_debug_e/dscb_gnt
add wave -noupdate /testbench/du_e/mii_debug_e/dscb_rdy
add wave -noupdate /testbench/du_e/mii_debug_e/dscb_req
add wave -noupdate /testbench/du_e/mii_debug_e/mii_txc
add wave -noupdate -radix hexadecimal /testbench/du_e/mii_debug_e/ip4proto_tx
add wave -noupdate -radix hexadecimal /testbench/du_e/mii_debug_e/ip4_e/cksm_init
add wave -noupdate -radix hexadecimal /testbench/du_e/mii_debug_e/ip4_e/ip4proto
add wave -noupdate /testbench/du_e/mii_debug_e/ip4_e/ip4_txen
add wave -noupdate -radix hexadecimal /testbench/du_e/mii_debug_e/ip4_e/ip4_txd
add wave -noupdate -radix ascii /testbench/du_e/mii_debug_e/mii_display_e/cga_codes
add wave -noupdate /testbench/du_e/mii_debug_e/udp_gnt
add wave -noupdate /testbench/du_e/mii_debug_e/icmp_gnt
add wave -noupdate -radix hexadecimal /testbench/du_e/mii_debug_e/ip4_e/mii1checksum_e/cksm
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 2} {3780300420 fs} 1} {{Cursor 2} {1018261960 fs} 0}
quietly wave cursor active 2
configure wave -namecolwidth 236
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
WaveRestoreZoom {762207680 fs} {5223041700 fs}
