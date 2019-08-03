CONSTRAINTS = ./constraints/ulx3s_v20.lpf

TOP_MODULE = ulx3s
TOP_MODULE_FILE = ../common/ulx3s.vhd

VHDL_FILES = \
  $(TOP_MODULE_FILE) \
  ../scopeio/scopeio_top.vhd \
  ../scopeio/usbserial_rxd.vhd \
  ../common/clk_verilog.vhd \
  ../common/clk_25M_100M_7M5_12M_60M.vhd \
  ../common/clk_200m_60m_48m_12m_7m5.vhd \
  ../common/clk_200_48_24_12_6.vhd \
  ../common/clk_25_200_40_66_6.vhd \
  ../common/hdl/vga.vhd \
  ../common/hdl/oled/oled_hex_decoder.vhd \
  ../common/hdl/oled/oled_init_pack.vhd \
  ../common/hdl/oled/oled_font_pack.vhd \
  ../common/hdl/oled/vga/oled_vga.vhd \
  ../common/hdl/oled/vga/oled_vga_init_pack.vhd \
  ../common/hdl/adc/max1112x_reader.vhd \
  ../common/hdl/adc/max1112x_init_pack.vhd \


VHDL_LIB_NAME = hdl4fpga
VHDL_LIB_FILES = \
  ../../library/common/align.vhd \
  ../../library/common/std.vhd \
  ../../library/common/bram.vhd \
  ../../library/common/dpram.vhd \
  ../../library/common/bram_true2p_2clk.vhd \
  ../../library/common/rom.vhd \
  ../../library/common/bcddiv2e.vhd \
  ../../library/common/vector.vhd \
  ../../library/common/dbdbbl.vhd \
  ../../library/common/ser2pll.vhd \
  ../../library/common/stof.vhd \
  ../../library/common/dtos.vhd \
  ../../library/common/btod.vhd \
  ../../library/common/btof.vhd \
  ../../library/common/pll2ser.vhd \
  ../../library/scope/scopeio.vhd \
  ../../library/scope/scopeiopkg.vhd \
  ../../library/scope/tcs/scopeio_trigger_capture_storage_entity.vhd \
  ../../library/scope/tcs/1shot/scopeio_trigger_capture_storage.vhd \
  ../../library/scope/scopeio_capture.vhd \
  ../../library/scope/scopeio_capture1shot.vhd \
  ../../library/scope/scopeio_storage.vhd \
  ../../library/scope/scopeio_resize.vhd \
  ../../library/scope/scopeio_video.vhd \
  ../../library/scope/scopeio_pointer.vhd \
  ../../library/scope/scopeio_ps2mouse2daisy.vhd \
  ../../library/scope/scopeio_usbmouse2daisy.vhd \
  ../../library/scope/scopeio_hostmouse2daisy.vhd \
  ../../library/ps2mouse/mousem.vhd \
  ../../library/usbmouse/usbh_host_hid.vhd \
  ../../library/usbmouse/usbh_setup_logitech_mouse_pack.vhd \
  ../../library/usbmouse/usbh_report_decoder_logitech_mouse.vhd \
  ../../library/usbmouse/usbh_sie_vhdl.vhd \
  ../../library/scope/scopeio_mouse2rgtr.vhd \
  ../../library/scope/scopeio_rgtr2daisy.vhd \
  ../../library/scope/scopeio_miiudp.vhd \
  ../../library/scope/scopeio_istream.vhd \
  ../../library/scope/scopeio_istreamdaisy.vhd \
  ../../library/scope/scopeio_sin.vhd \
  ../../library/scope/scopeio_rgtrfile.vhd \
  ../../library/scope/scopeio_rgtrtrigger.vhd \
  ../../library/scope/scopeio_rgtrgain.vhd \
  ../../library/scope/scopeio_rgtrpointer.vhd \
  ../../library/scope/scopeio_rgtrvtaxis.vhd \
  ../../library/scope/scopeio_rgtrpalette.vhd \
  ../../library/scope/scopeio_rgtrhzaxis.vhd \
  ../../library/scope/scopeio_amp.vhd \
  ../../library/scope/scopeio_downsampler.vhd \
  ../../library/scope/scopeio_grid.vhd \
  ../../library/scope/scopeio_palette.vhd \
  ../../library/scope/scopeio_segment.vhd \
  ../../library/scope/scopeio_tracer.vhd \
  ../../library/scope/scopeio_trigger.vhd \
  ../../library/scope/scopeio_axis.vhd \
  ../../library/scope/scopeio_ticks.vhd \
  ../../library/scope/scopeio_formatu.vhd \
  ../../library/uart/uart_rx.vhd \
  ../../library/uart/uart_rx_f32c.vhd \
  ../../library/mii/miirx_pre.vhd \
  ../../library/mii/mii_1chksum.vhd \
  ../../library/mii/mii_cat.vhd \
  ../../library/mii/mii_cmp.vhd \
  ../../library/mii/mii_crc32.vhd \
  ../../library/mii/mii_ipcfg.vhd \
  ../../library/mii/mii_pll2ser.vhd \
  ../../library/mii/mii_pllcmp.vhd \
  ../../library/mii/mii_ram.vhd \
  ../../library/mii/mii_rom.vhd \
  ../../library/mii/mii_romcmp.vhd \
  ../../library/mii/miitx_dll.vhd \
  ../../library/usbserial/usb_serial/usbtest.vhd \
  ../../library/usbserial/usb_serial/usb_serial.vhd \
  ../../library/usbserial/usb_serial/usb_transact.vhd \
  ../../library/usbserial/usb_serial/usb_packet.vhd \
  ../../library/usbserial/usb_serial/usb_init.vhd \
  ../../library/usbserial/usb_serial/usb_control.vhd \
  ../../library/usbserial/usb11_phy_vhdl/usb_phy.vhd \
  ../../library/usbserial/usb11_phy_vhdl/usb_rx_phy_48MHz.vhd \
  ../../library/usbserial/usb11_phy_vhdl/usb_tx_phy.vhd \
  ../../library/video/video.vhd \
  ../../library/video/videopkg.vhd \
  ../../library/video/cgafonts.vhd \
  ../../library/video/cga_rom.vhd \
  ../../library/video/vga2dvid.vhd \
  ../../library/video/tmds_encoder.vhd \

VERILOG_FILES = \
  $(VERILOG_CLOCK_FILE) \
  ../common/clk_200_48_24_12_6_v.v \
  ../../library/usbmouse/usbh_sie.v \
  ../../library/usbmouse/usbh_crc5.v \
  ../../library/usbmouse/usbh_crc16.v \

# for mouse support, in VHDL_LIB_FILES: 
# replace "scopeio.vhd" -> "scopeio_pointer.vhd"
#  ../../library/scope/scopeio_pointer.vhd \
# and add this source:
#  ../../library/scope/scopeio_mouse2rgtr.vhd \
