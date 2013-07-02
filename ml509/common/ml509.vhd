library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ml505 is
	port(
		bus_error : std_logic_vector( downto 0)
		cfg_addr_out : std_logic_vector( downto 0)
		cpld_io : std_logic_vector( downto 0)
		ddr2_a : std_logic_vector( downto 0)
		ddr2_ba : std_logic_vector( downto 0)
		ddr2_cke : std_logic_vector( downto 0)
		ddr2_d : std_logic_vector( downto 0)
		ddr2_dm : std_logic_vector( downto 0)
		ddr2_odt : std_logic_vector( downto 0)
		dvi_d : std_logic_vector( downto 0)
		dvi_gpio : std_logic_vector( downto 0)
		fpga_m : std_logic_vector( downto 0)
		fpga_vrn_b : std_logic_vector( downto 0)
		fpga_vrp_b : std_logic_vector( downto 0)
		gpio_dip_sw : std_logic_vector( downto 0)
		gpio_led : std_logic_vector( downto 0)
		hdr1 : std_logic_vector( downto 0)
		lcd_fpga_db : std_logic_vector( downto 0)
		phy_rxd : std_logic_vector( downto 0)
		phy_txd : std_logic_vector( downto 0)
		reserved : std_logic_vector( downto 0)
		sram_bw : std_logic_vector( downto 0)
		sram_d : std_logic_vector( downto 0)
		sram_dqp : std_logic_vector( downto 0)
		sram_flash_a : std_logic_vector( downto 0)
		sram_flash_d : std_logic_vector( downto 0)
		sysace_mpa : std_logic_vector( downto 0)
		sysace_mpa01_usb_a : std_logic_vector( downto 0)
		sysace_mpa02_usb_a : std_logic_vector( downto 0)
		sysace_usb_d : std_logic_vector( downto 0)
		trc_ts : std_logic_vector( downto 0)
		vga_in_blue : std_logic_vector( downto 0)
		vga_in_green : std_logic_vector( downto 0)
		attribute loc of bus_error signal is T10 F6
		attribute loc of cfg_addr_out signal is AE13 AE12
		attribute loc of cpld_io signal is W10
		attribute loc of ddr2_a signal is H29 T31 R29 J31 R28 M31 P30 P31 L31 K31 P29 N29 M30 L30
		attribute loc of ddr2_ba signal is R31 J30 G31
		attribute loc of ddr2_cke signal is U30 T28
		attribute loc of ddr2_d signal is L24 L25 M25 J27 L26 J24 M26 G25 G26 H24 K28 K27 H25 F25 L28 M28 N28 P27 N25 T24 P26 N24 P25 R24 V24 W26 W25 V28 W24 Y26 Y27 V29 W27 V27 W29 AC30 V30 W31 AB30 AC29 AA25 AB27 AA24 AB26 AA26 AC27 AB25 AC28 AB28 AG28 AJ26 AG25 AA28 AH28 AF28 AH27 AE29 AD29 AF29 AJ30 AD30 AF31 AK31 AF30
		attribute loc of ddr2_dm signal is J25 F26 P24 V25 Y31 Y24 AE28 AJ31
		attribute loc of ddr2_odt signal is F30 F31
		attribute loc of dvi_d signal is AN14 AP14 AB10 AA10 AN13 AM13 AA8 AA9 AP12 AN12 AC8 AB8
		attribute loc of dvi_gpio signal is N30
		attribute loc of fpga_m signal is AD22 AC22 AD21
		attribute loc of fpga_vrn_b signal is AF8 AJ25 L10 N27 AD31 AG33 N33
		attribute loc of fpga_vrp_b signal is AE9 AH25 L11 M27 AE31 AH33 M33
		attribute loc of gpio_dip_sw signal is AC24 AC25 AE26 AE27 AF26 AF25 AG27 U25
		attribute loc of gpio_led signal is AE24 AD24 AD25 G16 AD26 G15 L18 H18
		attribute loc of hdr1 signal is AN33 AN34 AM32 AJ34 AM33 AL33 AL34 AK32 AJ32 AK33 AK34 AH32 AG32 AE32 AH34 W32 Y32 Y34 AD32 AA34 N34 P34 M32 L33 J34 J32 H32 G32 G33 H34 F34 H33
		attribute loc of lcd_fpga_db signal is T11 G6 G7 T9
		attribute loc of phy_rxd signal is F33 D34 C34 D32 C32 C33 B33 A33
		attribute loc of phy_txd signal is AG11 AG10 AH8 AG8 AH10 AH9 AE11 AF11
		attribute loc of reserved signal is AC23 AB23
		attribute loc of sram_bw signal is K11 J11 D11 D10
		attribute loc of sram_d signal is J9 K8 K9 B13 C13 G11 G12 M8 L8 F11 E11 M10 L9 E12 E13 N10
		attribute loc of sram_dqp signal is H9 H10 C12 D12
		attribute loc of sram_flash_a signal is AE22 AE23 L21 L20 L15 L16 J22 K21 K16 J15 G22 H22 L14 K14 K23 K22 J12 H12 G23 H23 K13 K12
		attribute loc of sram_flash_d signal is AG22 AH22 AH12 AG13 AH20 AH19 AH14 AH13 AF15 AE16 AE21 AD20 AF16 AE17 AE19 AD19
		attribute loc of sysace_mpa signal is L6 M6 R6 P5
		attribute loc of sysace_mpa01_usb_a signal is N7
		attribute loc of sysace_mpa02_usb_a signal is N5
		attribute loc of sysace_usb_d signal is J6 K7 T6 J5 K6 L4 L5 R8 P6 P7 U7 R7 H7 J7 T8 P9
		attribute loc of trc_ts signal is AD10 AD11 AK11 AJ11
		attribute loc of vga_in_blue signal is AD7 AC7 AB5 AA5 AB7 AB6 AC5 AC4
		attribute loc of vga_in_green signal is AE6 AD6 Y7 AA6 AD5 AD4 Y9 Y8
