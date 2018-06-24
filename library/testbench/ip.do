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
add wave -noupdate /testbench/du/mii_ipcfg_e/eth_b/ip_b/ip4addr_rxdv
add wave -noupdate -radix hexadecimal /testbench/du/mii_ipcfg_e/eth_b/ip_b/ip4addr_rxd
add wave -noupdate -radix hexadecimal /testbench/du/mii_ipcfg_e/eth_b/ip_b/ip4pfx_txd
add wave -noupdate /testbench/du/mii_ipcfg_e/eth_b/ip_b/ip4pfx_txdv
add wave -noupdate /testbench/du/mii_ipcfg_e/mii_txc
add wave -noupdate /testbench/du/mii_ipcfg_e/eth_b/ip_b/ip4daddr_ena
add wave -noupdate -radix hexadecimal /testbench/du/mii_ipcfg_e/eth_b/ip_b/ip4daddr_txd
add wave -noupdate /testbench/du/mii_ipcfg_e/eth_b/ip_b/ip4saddr_ena
add wave -noupdate -radix hexadecimal /testbench/du/mii_ipcfg_e/eth_b/ip_b/ip4saddr_txd
add wave -noupdate -radix hexadecimal /testbench/du/mii_ipcfg_e/eth_b/ip_b/ip4addr_txd
add wave -noupdate /testbench/du/mii_ipcfg_e/eth_b/ip_b/ip4addr_txdv
add wave -noupdate /testbench/du/mii_ipcfg_e/eth_b/ip_b/ip4hdr0_txdv
add wave -noupdate -radix hexadecimal /testbench/du/mii_ipcfg_e/eth_b/ip_b/ip4hdr0_txd
add wave -noupdate /testbench/du/mii_ipcfg_e/eth_b/ip_b/chksum_b/ip4cksm_rxdv
add wave -noupdate -radix hexadecimal /testbench/du/mii_ipcfg_e/eth_b/ip_b/chksum_b/ip4cksm_rxd
add wave -noupdate /testbench/du/mii_ipcfg_e/eth_b/ip_b/chksum_b/cksm_txdv
add wave -noupdate -radix hexadecimal /testbench/du/mii_ipcfg_e/eth_b/ip_b/chksum_b/cksm_txd
add wave -noupdate -radix hexadecimal /testbench/du/mii_ipcfg_e/eth_b/ip_b/ip4cksm_txdv
add wave -noupdate -radix hexadecimal -childformat {{/testbench/du/mii_ipcfg_e/eth_b/ip_b/ip4cksm_txd(0) -radix hexadecimal} {/testbench/du/mii_ipcfg_e/eth_b/ip_b/ip4cksm_txd(1) -radix hexadecimal} {/testbench/du/mii_ipcfg_e/eth_b/ip_b/ip4cksm_txd(2) -radix hexadecimal} {/testbench/du/mii_ipcfg_e/eth_b/ip_b/ip4cksm_txd(3) -radix hexadecimal}} -subitemconfig {/testbench/du/mii_ipcfg_e/eth_b/ip_b/ip4cksm_txd(0) {-height 16 -radix hexadecimal} /testbench/du/mii_ipcfg_e/eth_b/ip_b/ip4cksm_txd(1) {-height 16 -radix hexadecimal} /testbench/du/mii_ipcfg_e/eth_b/ip_b/ip4cksm_txd(2) {-height 16 -radix hexadecimal} /testbench/du/mii_ipcfg_e/eth_b/ip_b/ip4cksm_txd(3) {-height 16 -radix hexadecimal}} /testbench/du/mii_ipcfg_e/eth_b/ip_b/ip4cksm_txd
add wave -noupdate /testbench/du/mii_ipcfg_e/eth_b/ip_b/ip4hdr_txdv
add wave -noupdate -radix hexadecimal /testbench/du/mii_ipcfg_e/eth_b/ip_b/ip4hdr_txd
add wave -noupdate /testbench/du/mii_ipcfg_e/eth_b/ip_txdv
add wave -noupdate -radix hexadecimal /testbench/du/mii_ipcfg_e/eth_b/ip_txd
add wave -noupdate /testbench/du/mii_ipcfg_e/eth_b/tx_b/dll_txdv
add wave -noupdate -radix hexadecimal /testbench/du/mii_ipcfg_e/eth_b/tx_b/dll_txd
add wave -noupdate /testbench/du/mii_ipcfg_e/mii_txdv
add wave -noupdate -radix hexadecimal -childformat {{/testbench/du/mii_ipcfg_e/mii_txd(0) -radix hexadecimal} {/testbench/du/mii_ipcfg_e/mii_txd(1) -radix hexadecimal} {/testbench/du/mii_ipcfg_e/mii_txd(2) -radix hexadecimal} {/testbench/du/mii_ipcfg_e/mii_txd(3) -radix hexadecimal}} -subitemconfig {/testbench/du/mii_ipcfg_e/mii_txd(0) {-height 16 -radix hexadecimal} /testbench/du/mii_ipcfg_e/mii_txd(1) {-height 16 -radix hexadecimal} /testbench/du/mii_ipcfg_e/mii_txd(2) {-height 16 -radix hexadecimal} /testbench/du/mii_ipcfg_e/mii_txd(3) {-height 16 -radix hexadecimal}} /testbench/du/mii_ipcfg_e/mii_txd
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1069 ns} 0}
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
WaveRestoreZoom {0 ns} {10500 ns}
