onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/du_e/ipoe_g/ipoe_b/du_e/mii_clk
add wave -noupdate /testbench/du_e/ipoe_g/ipoe_b/du_e/ipv4_e/udp_e/dhcpcd_e/dhcpcdtx_frm
add wave -noupdate /testbench/du_e/ipoe_g/ipoe_b/du_e/ipv4_e/udp_e/dhcpcd_e/dlltx_full
add wave -noupdate /testbench/du_e/ipoe_g/ipoe_b/du_e/ipv4_e/udp_e/dhcpcd_e/dhcpdscb_e/dhcpdscb_irdy
add wave -noupdate /testbench/du_e/ipoe_g/ipoe_b/du_e/ipv4_e/udp_e/dhcpcd_e/dhcpdscb_e/dhcpdscb_trdy
add wave -noupdate /testbench/du_e/ipoe_g/ipoe_b/du_e/ipv4_e/udp_e/dhcpcd_e/dhcpdscb_e/dhcpdscb_end
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_g/ipoe_b/du_e/ipv4_e/udp_e/dhcpcd_e/dhcpdscb_e/dhcpdscb_data
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_g/ipoe_b/du_e/ipv4_e/udp_e/dhcpcd_e/dhcpdscb_e/dhcppkt_data
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_g/ipoe_b/du_e/ipv4_e/udp_e/dhcpcd_e/dhcpdscb_e/dhcppkt_e/mux_data
add wave -noupdate /testbench/du_e/ipoe_g/ipoe_b/du_e/ipv4_e/udp_e/dhcpcd_e/dhcpdscb_e/dhcppkt_e/sio_frm
add wave -noupdate /testbench/du_e/ipoe_g/ipoe_b/du_e/ipv4_e/udp_e/dhcpcd_e/dhcpdscb_e/dhcppkt_e/sio_irdy
add wave -noupdate /testbench/du_e/ipoe_g/ipoe_b/du_e/ipv4_e/udp_e/dhcpcd_e/dhcpdscb_e/dhcppkt_e/sio_trdy
add wave -noupdate /testbench/du_e/ipoe_g/ipoe_b/du_e/ipv4_e/udp_e/dhcpcd_e/dhcpdscb_e/dhcppkt_e/so_last
add wave -noupdate /testbench/du_e/ipoe_g/ipoe_b/du_e/ipv4_e/udp_e/dhcpcd_e/dhcpdscb_e/dhcppkt_e/so_end
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_g/ipoe_b/du_e/ipv4_e/udp_e/dhcpcd_e/dhcpdscb_e/dhcppkt_e/so_data
add wave -noupdate -radix hexadecimal -childformat {{/testbench/du_e/ipoe_g/ipoe_b/du_e/ipv4_e/udp_e/dhcpcd_e/dhcpdscb_e/dhcppkt_e/mux_sel(1) -radix hexadecimal} {/testbench/du_e/ipoe_g/ipoe_b/du_e/ipv4_e/udp_e/dhcpcd_e/dhcpdscb_e/dhcppkt_e/mux_sel(2) -radix hexadecimal} {/testbench/du_e/ipoe_g/ipoe_b/du_e/ipv4_e/udp_e/dhcpcd_e/dhcpdscb_e/dhcppkt_e/mux_sel(3) -radix hexadecimal} {/testbench/du_e/ipoe_g/ipoe_b/du_e/ipv4_e/udp_e/dhcpcd_e/dhcpdscb_e/dhcppkt_e/mux_sel(4) -radix hexadecimal} {/testbench/du_e/ipoe_g/ipoe_b/du_e/ipv4_e/udp_e/dhcpcd_e/dhcpdscb_e/dhcppkt_e/mux_sel(5) -radix hexadecimal} {/testbench/du_e/ipoe_g/ipoe_b/du_e/ipv4_e/udp_e/dhcpcd_e/dhcpdscb_e/dhcppkt_e/mux_sel(6) -radix hexadecimal}} -subitemconfig {/testbench/du_e/ipoe_g/ipoe_b/du_e/ipv4_e/udp_e/dhcpcd_e/dhcpdscb_e/dhcppkt_e/mux_sel(1) {-radix hexadecimal} /testbench/du_e/ipoe_g/ipoe_b/du_e/ipv4_e/udp_e/dhcpcd_e/dhcpdscb_e/dhcppkt_e/mux_sel(2) {-radix hexadecimal} /testbench/du_e/ipoe_g/ipoe_b/du_e/ipv4_e/udp_e/dhcpcd_e/dhcpdscb_e/dhcppkt_e/mux_sel(3) {-radix hexadecimal} /testbench/du_e/ipoe_g/ipoe_b/du_e/ipv4_e/udp_e/dhcpcd_e/dhcpdscb_e/dhcppkt_e/mux_sel(4) {-radix hexadecimal} /testbench/du_e/ipoe_g/ipoe_b/du_e/ipv4_e/udp_e/dhcpcd_e/dhcpdscb_e/dhcppkt_e/mux_sel(5) {-radix hexadecimal} /testbench/du_e/ipoe_g/ipoe_b/du_e/ipv4_e/udp_e/dhcpcd_e/dhcpdscb_e/dhcppkt_e/mux_sel(6) {-radix hexadecimal}} /testbench/du_e/ipoe_g/ipoe_b/du_e/ipv4_e/udp_e/dhcpcd_e/dhcpdscb_e/dhcppkt_e/mux_sel
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {4961381220 fs} 0}
quietly wave cursor active 1
configure wave -namecolwidth 727
configure wave -valuecolwidth 156
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
WaveRestoreZoom {4010 ns} {8210 ns}
