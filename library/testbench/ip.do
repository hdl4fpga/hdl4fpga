onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/du/mii_ipcfg_e/eth_b/dhcp_txdv
add wave -noupdate -radix hexadecimal /testbench/du/mii_ipcfg_e/eth_b/dhcp_txd
add wave -noupdate -radix hexadecimal /testbench/du/mii_ipcfg_e/eth_b/ipdata_txd
add wave -noupdate /testbench/du/mii_ipcfg_e/eth_b/ipdata_txdv
add wave -noupdate /testbench/du/mii_ipcfg_e/eth_b/ip_b/ip4shdr_ena
add wave -noupdate -radix hexadecimal /testbench/du/mii_ipcfg_e/eth_b/ip_b/ip4shdr_txd
add wave -noupdate /testbench/du/mii_ipcfg_e/eth_b/ip_b/ip4pfx0_txdv
add wave -noupdate -radix hexadecimal /testbench/du/mii_ipcfg_e/eth_b/ip_b/ip4pfx0_txd
add wave -noupdate -radix hexadecimal /testbench/du/mii_ipcfg_e/eth_b/ip_b/ip4pfx_txd
add wave -noupdate /testbench/du/mii_ipcfg_e/eth_b/ip_b/ip4pfx_txdv
add wave -noupdate -radix hexadecimal /testbench/du/mii_ipcfg_e/eth_b/ip_b/ip4addr_txd
add wave -noupdate /testbench/du/mii_ipcfg_e/eth_b/ip_b/ip4addr_txdv
add wave -noupdate /testbench/du/mii_ipcfg_e/eth_b/ip_b/ip4hdr0_txdv
add wave -noupdate -radix hexadecimal /testbench/du/mii_ipcfg_e/eth_b/ip_b/ip4hdr0_txd
add wave -noupdate /testbench/du/mii_ipcfg_e/eth_b/ip_b/ip4hdr_txdv
add wave -noupdate -radix hexadecimal /testbench/du/mii_ipcfg_e/eth_b/ip_b/ip4hdr_txd
add wave -noupdate /testbench/du/mii_ipcfg_e/eth_b/ip_txdv
add wave -noupdate -radix hexadecimal /testbench/du/mii_ipcfg_e/eth_b/ip_txd
add wave -noupdate /testbench/du/mii_ipcfg_e/eth_b/tx_b/rxdv
add wave -noupdate -radix hexadecimal /testbench/du/mii_ipcfg_e/eth_b/tx_b/rxd
add wave -noupdate /testbench/du/mii_ipcfg_e/eth_b/tx_b/txdv
add wave -noupdate -radix hexadecimal /testbench/du/mii_ipcfg_e/eth_b/tx_b/txd
add wave -noupdate -radix unsigned /testbench/du/mii_ipcfg_e/eth_b/tx_b/miitx_ptr
add wave -noupdate /testbench/du/mii_ipcfg_e/eth_b/tx_b/iptype_req
add wave -noupdate /testbench/du/mii_ipcfg_e/eth_b/tx_b/dll_txdv
add wave -noupdate -radix hexadecimal /testbench/du/mii_ipcfg_e/eth_b/tx_b/dll_txd
add wave -noupdate /testbench/du/mii_ipcfg_e/mii_txdv
add wave -noupdate -radix hexadecimal /testbench/du/mii_ipcfg_e/mii_txd
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3130 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
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
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {4200 ns}
