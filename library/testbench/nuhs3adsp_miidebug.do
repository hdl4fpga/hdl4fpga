onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/ethtx_e/mii_txc
add wave -noupdate /testbench/eth_txen
add wave -noupdate -radix hexadecimal /testbench/eth_txd
add wave -noupdate -radix hexadecimal /testbench/txfrm_ptr
add wave -noupdate /testbench/mii_rxdv
add wave -noupdate -radix hexadecimal /testbench/mii_rxd
add wave -noupdate /testbench/mii_rxc
add wave -noupdate -radix hexadecimal /testbench/ethtx_e/llc_txen
add wave -noupdate -radix hexadecimal /testbench/ethtx_e/llc_txd
add wave -noupdate /testbench/ethtx_e/dll_e/lat_txen
add wave -noupdate -radix hexadecimal /testbench/ethtx_e/dll_e/lat_txd
add wave -noupdate -radix hexadecimal /testbench/ethtx_e/dll_e/fcs_p/cntr
add wave -noupdate /testbench/ethtx_e/dll_e/fcs_p/cy
add wave -noupdate /testbench/ethtx_e/dll_e/fcs_p/q
add wave -noupdate -radix hexadecimal /testbench/ethtx_e/dll_e/crc32
add wave -noupdate /testbench/ethtx_e/dll_e/crc32_init
add wave -noupdate /testbench/ethtx_e/dll_e/crc32_txen
add wave -noupdate /testbench/ethtx_e/dll_e/mii_txen
add wave -noupdate -radix hexadecimal /testbench/ethtx_e/dll_e/mii_txd
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {13607948060 fs} 0}
quietly wave cursor active 1
configure wave -namecolwidth 288
configure wave -valuecolwidth 352
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
WaveRestoreZoom {2723512440 fs} {25058786360 fs}
