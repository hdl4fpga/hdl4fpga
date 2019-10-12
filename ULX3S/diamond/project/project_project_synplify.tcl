#-- Lattice Semiconductor Corporation Ltd.
#-- Synplify OEM project file

#device options
set_option -technology ECP5U
set_option -part LFE5U_12F
set_option -package BG381C
set_option -speed_grade -6

#compilation/mapping options
set_option -symbolic_fsm_compiler true
set_option -resource_sharing true

#use verilog 2001 standard option
set_option -vlog_std v2001

#map options
set_option -frequency auto
set_option -maxfan 1000
set_option -auto_constrain_io 0
set_option -disable_io_insertion false
set_option -retiming false; set_option -pipe true
set_option -force_gsr false
set_option -compiler_compatible 0
set_option -dup false

set_option -default_enum_encoding onehot

#simulation options


#timing analysis options



#automatic place and route (vendor) options
set_option -write_apr_constraint 1

#synplifyPro options
set_option -fix_gated_and_generated_clocks 1
set_option -update_models_cp 0
set_option -resolve_multiple_driver 0


#-- add_file options
set_option -include_path {C:/workspace/hdl4fpga/ULX3S/diamond}
add_file -vhdl -lib "work" {C:/workspace/hdl4fpga/ULX3S/common/ulx3s.vhd}
add_file -vhdl -lib "work" {C:/workspace/hdl4fpga/ULX3S/scopeio/scopeio_top.vhd}
add_file -vhdl -lib "work" {C:/workspace/hdl4fpga/ULX3S/scopeio/usbserial_rxd.vhd}
add_file -vhdl -lib "work" {C:/workspace/hdl4fpga/ULX3S/common/clk_verilog.vhd}
add_file -vhdl -lib "work" {C:/workspace/hdl4fpga/ULX3S/common/clk_25_200_40_66_6.vhd}
add_file -vhdl -lib "work" {C:/workspace/hdl4fpga/ULX3S/common/clk_200_48_24_12_6.vhd}
add_file -vhdl -lib "work" {C:/workspace/hdl4fpga/ULX3S/common/hdl/vga.vhd}
add_file -vhdl -lib "work" {C:/workspace/hdl4fpga/ULX3S/common/hdl/oled/oled_hex_decoder.vhd}
add_file -vhdl -lib "work" {C:/workspace/hdl4fpga/ULX3S/common/hdl/oled/oled_init_pack.vhd}
add_file -vhdl -lib "work" {C:/workspace/hdl4fpga/ULX3S/common/hdl/oled/oled_font_pack.vhd}
add_file -vhdl -lib "work" {C:/workspace/hdl4fpga/ULX3S/common/hdl/oled/vga/oled_vga.vhd}
add_file -vhdl -lib "work" {C:/workspace/hdl4fpga/ULX3S/common/hdl/oled/vga/oled_vga_init_pack.vhd}
add_file -vhdl -lib "work" {C:/workspace/hdl4fpga/ULX3S/common/hdl/adc/max1112x_reader.vhd}
add_file -vhdl -lib "work" {C:/workspace/hdl4fpga/ULX3S/common/hdl/adc/max1112x_init_pack.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/common/align.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/common/std.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/common/bram.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/common/dpram.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/common/bram_true2p_2clk.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/common/rom.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/common/bcddiv2e.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/common/vector.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/common/dbdbbl.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/common/stof.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/common/dtos.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/common/btod.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/common/btof.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/common/arbiter.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/scope/scopeio.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/scope/scopeiopkg.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/scope/scopeio_capture.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/scope/scopeio_capture1shot.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/scope/scopeio_storage.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/scope/scopeio_resize.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/scope/scopeio_video.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/scope/scopeio_textbox.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/scope/scopeio_pointer.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/scope/scopeio_ps2mouse2daisy.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/scope/scopeio_usbmouse2daisy.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/scope/scopeio_hostmouse2daisy.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/ps2mouse/mousem.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/scope/scopeio_mouse2rgtr.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/scope/scopeio_rgtr2daisy.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/scope/scopeio_miiudp.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/scope/scopeio_istream.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/scope/scopeio_istreamdaisy.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/scope/scopeio_sin.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/scope/scopeio_udpipdaisy.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/scope/scopeio_tds_1shot.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/scope/scopeio_rgtrtrigger.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/scope/scopeio_rgtrgain.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/scope/scopeio_rgtrpointer.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/scope/scopeio_rgtrvtaxis.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/scope/scopeio_rgtrpalette.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/scope/scopeio_rgtrhzaxis.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/scope/scopeio_amp.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/scope/scopeio_downsampler.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/scope/scopeio_grid.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/scope/scopeio_palette.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/scope/scopeio_segment.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/scope/scopeio_tracer.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/scope/scopeio_trigger.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/scope/scopeio_axis.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/scope/scopeio_btof.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/scope/scopeio_float2btof.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/scope/scopeio_layout.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/uart/uart_rx.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/uart/uart_rx_f32c.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/mii/miirx_pre.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/mii/mii_1chksum.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/mii/mii_cat.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/mii/mii_cmp.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/mii/mii_crc32.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/mii/mii_ipcfg.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/mii/mii_pll2ser.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/mii/mii_pllcmp.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/mii/mii_ram.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/mii/mii_rom.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/mii/mii_romcmp.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/mii/miitx_dll.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/usb/usbcdc/usb_serial.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/usb/usbcdc/usb_mii.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/usb/usbcdc/usb_cdc_descriptor_pack.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/usb/usbcdc/usb_transact.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/usb/usbcdc/usb_packet.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/usb/usbcdc/usb_init.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/usb/usbcdc/usb_control.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/usb/usbhost/usbh_host_hid.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/usb/usbhost/usbh_setup_pack.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/usb/usbhost/usbh_report_decoder_logitech_mouse.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/usb/usbhost/usbh_sie_vhdl.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/usb/usb11_phy_vhdl/usb_phy_transciver.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/usb/usb11_phy_vhdl/usb_phy.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/usb/usb11_phy_vhdl/usb_rx_phy_48MHz.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/usb/usb11_phy_vhdl/usb_tx_phy.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/usb/ulpi_wrapper/ulpi_wrapper_vhdl.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/video/video.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/video/videopkg.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/video/cgafonts.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/video/cga_rom.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/video/vga2dvid.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/video/tmds_encoder.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/video/cga_adapter.vhd}
add_file -verilog {C:/workspace/hdl4fpga/library/usb/usbhost/usbh_sie.v}
add_file -verilog {C:/workspace/hdl4fpga/library/usb/usbhost/usbh_crc5.v}
add_file -verilog {C:/workspace/hdl4fpga/library/usb/usbhost/usbh_crc16.v}
add_file -verilog {C:/workspace/hdl4fpga/library/usb/ulpi_wrapper/ulpi_wrapper.v}
add_file -vhdl -lib "work" {C:/workspace/hdl4fpga/library/video/cgafonts/psf1bcd4x4.vhd}
add_file -vhdl -lib "work" {C:/workspace/hdl4fpga/library/video/cgafonts/psf1cp850x8x8.vhd}
add_file -vhdl -lib "hdl4fpga" {C:/workspace/hdl4fpga/library/video/cgafonts/psf1cp850x8x16.vhd}
add_file -vhdl -lib "work" {C:/workspace/hdl4fpga/library/video/cgafonts/psf1cp850x8x16_00_to_F7.vhd}
add_file -vhdl -lib "work" {C:/workspace/hdl4fpga/library/video/cgafonts/psf1cp850x8x16_80_to_FF.vhd}
add_file -vhdl -lib "work" {C:/workspace/hdl4fpga/library/video/cgafonts/psf1digit8x8.vhd}
add_file -vhdl -lib "work" {C:/workspace/hdl4fpga/library/video/cgafonts/psf1mag32x16.vhd}

#-- top module name
set_option -top_module ulx3s

#-- set result format/file last
project -result_file {C:/workspace/hdl4fpga/ULX3S/diamond/project/project_project.edi}

#-- error message log file
project -log_file {project_project.srf}

#-- set any command lines input by customer


#-- run Synplify with 'arrange HDL file'
project -run hdl_info_gen -fileorder
project -run
