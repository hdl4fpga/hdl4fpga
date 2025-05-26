#!/bin/bash

for file in \
"../../../library/basic/hdo.vhd" \
"../../../library/basic/base.vhd" \
\
"../../../library/basic/arbiter.vhd" \
\
"../../../library/basic/dpram.vhd" \
"../../../library/basic/fifo.vhd" \
\
"../../../library/basic/rom.vhd" \
\
"../../../library/basic/barrel.vhd" \
\
"../../../library/basic/cntrcs.vhd" \
"../../../library/basic/timer.vhd" \
\
"../../../library/sdram/sdrampkg.vhd" \
"../../../library/sdram/sdram_mpu.vhd" \
"../../../library/sdram/sdram_pgm.vhd" \
"../../../library/sdram/sdram_sch.vhd" \
"../../../library/sdram/sdram_init.vhd" \
"../../../library/sdram/sdram_ctlr.vhd" \
\
"../../../library/sdram/dmacntr.vhd" \
"../../../library/sdram/dmatrans.vhd" \
"../../../library/sdram/dmactlr.vhd" \
; do 
	if ghdl -a --std=02 --work=hdl4fpga $file ; then
		echo $file
	else
		exit
	fi
done

for file in \
"../../../library/video/fonts/bcdfonts.vhd" \
"../../../library/video/fonts/cp850x8x16x0to127.vhd" \
"../../../library/video/fonts/cp850x8x16x128to255.vhd" \
"../../../library/video/fonts/cp850x8x8x0to127.vhd" \
"../../../library/video/fonts/cp850x8x8x128to255.vhd" \
"../../../library/video/cgafonts.vhd" \
\
"../../../library/basic/latency.vhd" \
"../../../library/video/cga_rom.vhd" \
\
"../../../library/sdram/phy_iofifo.vhd" \
"../../../library/basic/serlzr.vhd" \
\
"../../../library/video/tmds_encoder.vhd" \
"../../../library/video/videopkg.vhd" \
"../../../library/video/video.vhd" \
"../../../library/basic/serdes.vhd" \
"../../../library/video/graphics.vhd" \
"../../../library/video/dvi.vhd" \
"../../../library/video/cga_adapter.vhd" \
"../../../library/video/ser_display.vhd" \
; do 
	if ghdl -a --std=02 --work=hdl4fpga $file ; then
		echo $file
	else
		exit
	fi
done


for file in \
"../../../library/basic/crc.vhd" \
\
"../../../library/mii/ethpkg.vhd" \
"../../../library/mii/mii_rxpre.vhd" \
"../../../library/mii/dll_rx.vhd" \
"../../../library/mii/eth_rx.vhd" \
\
"../../../library/sio/sio_mux.vhd" \
"../../../library/mii/mii_buffer.vhd" \
"../../../library/mii/eth_tx.vhd" \
\
"../../../library/mii/ipoepkg.vhd" \
"../../../library/sio/sio_ram.vhd" \
"../../../library/mii/arp_tx.vhd" \
"../../../library/mii/arp_rx.vhd" \
"../../../library/mii/arpd.vhd" \
\
"../../../library/basic/adder.vhd" \
"../../../library/mii/ipv4_adjlen.vhd" \
"../../../library/mii/udp_tx.vhd" \
"../../../library/mii/udp_rx.vhd" \
"../../../library/mii/dhcp_dscb.vhd" \
"../../../library/mii/dhcp_offer.vhd" \
"../../../library/sio/sio_muxcmp.vhd" \
"../../../library/mii/dhcpcd.vhd" \
"../../../library/mii/mii_1cksm.vhd" \
"../../../library/mii/udp.vhd" \
"../../../library/sio/sio_cmp.vhd" \
"../../../library/mii/ipv4_tx.vhd" \
"../../../library/mii/ipv4_rx.vhd" \
"../../../library/basic/txn_buffer.vhd" \
"../../../library/mii/icmprqst_rx.vhd" \
"../../../library/mii/icmprply_tx.vhd" \
"../../../library/mii/icmpd.vhd" \
"../../../library/mii/ipv4.vhd" \
"../../../library/mii/mii_ipoe.vhd" \
"../../../library/sio/sio_sin.vhd" \
"../../../library/sio/sio_rgtr.vhd" \
"../../../library/sio/sio_flow.vhd" \
"../../../library/sio/sio_udp.vhd" \
"../../../library/sio/sio_dayudp.vhd" \
; do 
	if ghdl -a --std=02 --work=hdl4fpga $file ; then
		echo $file
	else
		exit
	fi
done

for file in \
"../../../library/usb/usbpkg.vhd" \
"../../../library/usb/usbphy_rx.vhd" \
"../../../library/usb/usbphy_tx.vhd" \
"../../../library/usb/usbphy.vhd" \
"../../../library/usb/usbcrc.vhd" \
"../../../library/usb/usbphycrc.vhd" \
"../../../library/usb/usbpkt_rx.vhd" \
"../../../library/usb/usbpkt_tx.vhd" \
"../../../library/usb/usbdevflow.vhd" \
"../../../library/usb/usbdevrqst.vhd" \
"../../../library/usb/usbdev.vhd" \
"../../../library/usb/usbfltr_sof.vhd" \
; do 
	if ghdl -a --std=02 --work=hdl4fpga $file ; then
		echo $file
	else
		exit
	fi
done

for file in \
"../../../library/hdlc/hdlcsync_rx.vhd" \
"../../../library/hdlc/hdlcfcs_rx.vhd" \
"../../../library/hdlc/hdlcdll_rx.vhd" \
"../../../library/hdlc/hdlcsync_tx.vhd" \
"../../../library/hdlc/hdlcdll_tx.vhd" \
; do 
	if ghdl -a --std=02 --work=hdl4fpga $file ; then
		echo $file
	else
		exit
	fi
done

for file in \
"../../../library/sio/sio_hdlc.vhd" \
"../../../library/sio/sio_dayhdlc.vhd" \
"../../../library/uart/uart_rx.vhd" \
"../../../library/uart/uart_tx.vhd" \
"../../../library/apps/app_profiles.vhd" \
"../../../library/apps/ecp5_profiles.vhd" \
"../../../library/apps/link_hdlc.vhd" \
; do 
	if ghdl -a --std=02 --work=hdl4fpga $file ; then
		echo $file
	else
		exit
	fi
done

for file in \
"../../../library/latticesemi/ecp5/ecp5_igbx.vhd" \
"../../../library/latticesemi/ecp5/ecp5_ogbx.vhd" \
"../../../library/xilinx/adjpha.vhd" \
"../../../library/latticesemi/ecp5/adjbrst.vhd" \
"../../../library/latticesemi/ecp5/ecp5_sdrdqphy.vhd" \
"../../../library/latticesemi/ecp5/ecp5_sdrbaphy.vhd" \
"../../../library/latticesemi/ecp5/ecp5_sdrphy.vhd" \
; do 
	if ghdl -a --std=02 --work=hdl4fpga $file ; then
		echo $file
	else
		exit
	fi
done

for file in \
"../../../library/basic/desser.vhd" \
"../../../library/sio/so_data.vhd" \
"../../../library/sio/sio_dmahdsk.vhd" \
"../../../library/apps/app_graphics.vhd" \
; do 
	if ghdl -a --std=02 --work=hdl4fpga $file ; then
		echo $file
	else
		exit
	fi
done

for file in \
"../../../library/apps/ecp5_sdrampll.vhd" \
"../../../library/apps/ecp5_videopll.vhd" \
"../../../library/apps/link_mii.vhd"  \
"../../../library/sio/sio_dayusb.vhd" \
"../../../library/apps/ser_debug.vhd" \
; do 
	if ghdl -a --std=02 --work=hdl4fpga $file ; then
		echo $file
	else
		exit
	fi
done

for file in \
"../common/ulx3s.vhd" \
"../apps/graphics.vhd" \
; do 
	if ghdl -a --std=02 --work=work $file ; then
		echo $file
	else
		exit
	fi
done

exit

