#!/bin/bash
if [ !  -e hdl4fpga ] ; then
    mkdir hdl4fpga
fi

for file in \
"../basic/hdo.vhd" \
"../basic/base.vhd" \
\
"../basic/arbiter.vhd" \
\
"../basic/dpram.vhd" \
"../basic/fifo.vhd" \
\
"../basic/rom.vhd" \
\
"../basic/barrel.vhd" \
\
"../basic/cntrcs.vhd" \
"../basic/timer.vhd" \
\
"../sdram/sdrampkg.vhd" \
"../sdram/sdram_mpu.vhd" \
"../sdram/sdram_pgm.vhd" \
"../sdram/sdram_sch.vhd" \
"../sdram/sdram_init.vhd" \
"../sdram/sdram_ctlr.vhd" \
\
"../sdram/dmacntr.vhd" \
"../sdram/dmatrans.vhd" \
"../sdram/dmactlr.vhd" \
; do 
	if ghdl -a --std=02 --workdir=hdl4fpga --work=hdl4fpga $file ; then
		echo $file
	else
		exit
	fi
done

for file in \
"../video/fonts/bcdfonts.vhd" \
"../video/fonts/cp850x8x16x0to127.vhd" \
"../video/fonts/cp850x8x16x128to255.vhd" \
"../video/fonts/cp850x8x8x0to127.vhd" \
"../video/fonts/cp850x8x8x128to255.vhd" \
"../video/cgafonts.vhd" \
\
"../basic/latency.vhd" \
"../video/cga_rom.vhd" \
\
"../sdram/phy_iofifo.vhd" \
"../basic/serlzr.vhd" \
\
"../video/tmds_encoder.vhd" \
"../video/videopkg.vhd" \
"../video/video.vhd" \
"../basic/serdes.vhd" \
"../video/graphics.vhd" \
"../video/dvi.vhd" \
"../video/cga_adapter.vhd" \
"../video/ser_display.vhd" \
; do 
	if ghdl -a --std=02 --workdir=hdl4fpga --work=hdl4fpga $file ; then
		echo $file
	else
		exit
	fi
done


for file in \
"../basic/crc.vhd" \
\
"../mii/ethpkg.vhd" \
"../mii/mii_rxpre.vhd" \
"../mii/dll_rx.vhd" \
"../mii/eth_rx.vhd" \
\
"../sio/sio_mux.vhd" \
"../mii/mii_buffer.vhd" \
"../mii/eth_tx.vhd" \
\
"../mii/ipoepkg.vhd" \
"../sio/sio_ram.vhd" \
"../mii/arp_tx.vhd" \
"../mii/arp_rx.vhd" \
"../mii/arpd.vhd" \
\
"../basic/adder.vhd" \
"../mii/ipv4_adjlen.vhd" \
"../mii/udp_tx.vhd" \
"../mii/udp_rx.vhd" \
"../mii/dhcp_dscb.vhd" \
"../mii/dhcp_offer.vhd" \
"../sio/sio_muxcmp.vhd" \
"../mii/dhcpcd.vhd" \
"../mii/mii_1cksm.vhd" \
"../mii/udp.vhd" \
"../sio/sio_cmp.vhd" \
"../mii/ipv4_tx.vhd" \
"../mii/ipv4_rx.vhd" \
"../basic/txn_buffer.vhd" \
"../mii/icmprqst_rx.vhd" \
"../mii/icmprply_tx.vhd" \
"../mii/icmpd.vhd" \
"../mii/ipv4.vhd" \
"../mii/mii_ipoe.vhd" \
"../sio/sio_sin.vhd" \
"../sio/sio_rgtr.vhd" \
"../sio/sio_flow.vhd" \
"../sio/sio_udp.vhd" \
"../sio/sio_dayudp.vhd" \
; do 
	if ghdl -a --std=02 --workdir=hdl4fpga --work=hdl4fpga $file ; then
		echo $file
	else
		exit
	fi
done

for file in \
"../usb/usbpkg.vhd" \
"../usb/usbphy_rx.vhd" \
"../usb/usbphy_tx.vhd" \
"../usb/usbphy.vhd" \
"../usb/usbcrc.vhd" \
"../usb/usbphycrc.vhd" \
"../usb/usbpkt_rx.vhd" \
"../usb/usbpkt_tx.vhd" \
"../usb/usbdevflow.vhd" \
"../usb/usbdevrqst.vhd" \
"../usb/usbdev.vhd" \
"../usb/usbfltr_sof.vhd" \
; do 
	if ghdl -a --std=02 --workdir=hdl4fpga --work=hdl4fpga $file ; then
		echo $file
	else
		exit
	fi
done

for file in \
"../hdlc/hdlcsync_rx.vhd" \
"../hdlc/hdlcfcs_rx.vhd" \
"../hdlc/hdlcdll_rx.vhd" \
"../hdlc/hdlcsync_tx.vhd" \
"../hdlc/hdlcdll_tx.vhd" \
; do 
	if ghdl -a --std=02 --workdir=hdl4fpga --work=hdl4fpga $file ; then
		echo $file
	else
		exit
	fi
done

for file in \
"../sio/sio_hdlc.vhd" \
"../sio/sio_dayhdlc.vhd" \
"../uart/uart_rx.vhd" \
"../uart/uart_tx.vhd" \
"../apps/app_profiles.vhd" \
; do 
	if ghdl -a --std=02 --workdir=hdl4fpga --work=hdl4fpga $file ; then
		echo $file
	else
		exit
	fi
done

for file in \
"../apps/ecp5_profiles.vhd" \
"../apps/link_hdlc.vhd" \
; do 
	if ghdl -a --std=02 -P./ecp5u --workdir=hdl4fpga --work=hdl4fpga $file ; then
		echo $file
	else
		exit
	fi
done

for file in \
"../latticesemi/ecp5/ecp5_igbx.vhd" \
"../latticesemi/ecp5/ecp5_ogbx.vhd" \
"../xilinx/adjpha.vhd" \
"../latticesemi/ecp5/adjbrst.vhd" \
"../latticesemi/ecp5/ecp5_sdrdqphy.vhd" \
"../latticesemi/ecp5/ecp5_sdrbaphy.vhd" \
"../latticesemi/ecp5/ecp5_sdrphy.vhd" \
; do 
	if ghdl -a --std=02 -P./ecp5u --workdir=hdl4fpga --work=hdl4fpga $file ; then
		echo $file
	else
		exit
	fi
done

for file in \
"../basic/desser.vhd" \
"../sio/so_data.vhd" \
"../sio/sio_dmahdsk.vhd" \
"../apps/app_graphics.vhd" \
; do 
	if ghdl -a --std=02 --workdir=hdl4fpga --work=hdl4fpga $file ; then
		echo $file
	else
		exit
	fi
done

for file in \
"../apps/ecp5_sdrampll.vhd" \
"../apps/ecp5_videopll.vhd" \
"../apps/link_mii.vhd"  \
"../sio/sio_dayusb.vhd" \
"../apps/ser_debug.vhd" \
; do 
	if ghdl -a --std=02 -P./ecp5u --workdir=hdl4fpga --work=hdl4fpga $file ; then
		echo $file
	else
		exit
	fi
done
