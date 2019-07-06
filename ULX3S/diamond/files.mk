CONSTRAINTS = ./constraints/ulx3s_v20.lpf

TOP_MODULE = ulx3s
TOP_MODULE_FILE = ../common/ulx3s.vhd

VHDL_FILES = \
  $(TOP_MODULE_FILE) \
  ../scopeio/scopeio.vhd \
  ../common/clk_verilog.vhd \
  ../common/clk_25M_100M_7M5_12M_60M.vhd \
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
  ../../library/common/pipe_le.vhd \
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
  ../../library/scope/scopeio_xxx.vhd \
  ../../library/scope/scopeiopkg.vhd \
  ../../library/scope/scopeio_capture1shot.vhd \
  ../../library/scope/scopeio_resize.vhd \
  ../../library/scope/scopeio_video.vhd \
  ../../library/scope/scopeio_pointer.vhd \
  ../../library/scope/scopeio_ps2mouse2daisy.vhd \
  ../../library/scope/scopeio_usbmouse2daisy.vhd \
  ../../library/ps2mouse/mousem.vhd \
  ../../library/usbmouse/usbhid_host.vhd \
  ../../library/usbmouse/usb_req_gen_func_pack.vhd \
  ../../library/usbmouse/usb_enum_logitech_mouse_pack.vhd \
  ../../library/scope/scopeio_mouse2rgtr.vhd \
  ../../library/scope/scopeio_rgtr2daisy.vhd \
  ../../library/scope/scopeio_miiudp.vhd \
  ../../library/scope/scopeio_istream.vhd \
  ../../library/scope/scopeio_istreamdaisy.vhd \
  ../../library/scope/scopeio_sin.vhd \
  ../../library/scope/scopeio_rgtr.vhd \
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
  ../../library/video/video.vhd \
  ../../library/video/videopkg.vhd \
  ../../library/video/cgafonts.vhd \
  ../../library/video/cga_rom.vhd \
  ../../library/video/vga2dvid.vhd \
  ../../library/video/tmds_encoder.vhd \

# for new code, replace scopeio.vhd -> scopeio_xxx.vhd
#  ../../library/scope/scopeio.vhd \
#  ../../library/scope/scopeio_xxx.vhd \

VERILOG_FILES = \
  $(VERILOG_CLOCK_FILE)

# for mouse support, in VHDL_LIB_FILES: 
# replace "scopeio.vhd" -> "scopeio_pointer.vhd"
#  ../../library/scope/scopeio_pointer.vhd \
# and add this source:
#  ../../library/scope/scopeio_mouse2rgtr.vhd \
