--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2010-2013                                                    --
--    Miguel Angel Sagreras                                                   --
--                                                                            --
-- This source file may be used and distributed without restriction provided  --
-- that this copyright statement is not removed from the file and that any    --
-- derivative work contains  the original copyright notice and the associated --
-- disclaimer.                                                                --
--                                                                            --
-- This source file is free software; you can redistribute it and/or modify   --
-- it under the terms of the GNU General Public License as published by the   --
-- Free Software Foundation, either version 3 of the License, or (at your     --
-- option) any later version.                                                 --
--                                                                            --
-- This source is distributed in the hope that it will be useful, but WITHOUT --
-- ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or      --
-- FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for   --
-- more details at http://www.gnu.org/licenses/.                              --
--                                                                            --

library hdl4fpga;
use hdl4fpga.std.all;

architecture miitx_udp of testbench is

	signal rst   : std_logic;
	signal clk   : std_logic := '0';

	signal phy_reset : std_logic;
	signal phy_col : std_logic;
	signal phy_crs : std_logic;
	signal phy_int : std_logic;		-- open drain
	signal phy_mdc : std_logic;
	signal phy_mdio : std_logic;

	signal phy_rxclk : std_logic;
	signal phy_rxctl_rxdv : std_logic;
	signal phy_rxd  : std_logic_vector(0 to 8-1);
	signal phy_rxer : std_logic;

	signal phy_txc_gtxclk : std_logic;
	signal phy_txclk : std_logic := '0';
	signal phy_txctl_txen : std_logic;
	signal phy_txd  : std_logic_vector(0 to 8-1);
	signal phy_txer : std_logic;

	component ml509 is
		port (
			bus_error : out std_logic_vector(2 downto 1);

--			cfg_addr_out : in std_logic_vector(2-1 downto 0);
--			cpld_io_1 : in std_logic;

			clk_27mhz_fpga : in std_logic := '-';
			clk_33mhz_fpga : in std_logic := '-';
			clk_fpga_n : in std_logic := '-';
			clk_fpga_p : in std_logic := '-';

			ddr2_clk_p : out std_logic_vector(2-1 downto 0) := (others => '-');
			ddr2_clk_n : out std_logic_vector(2-1 downto 0) := (others => '-');
			ddr2_cs  : out std_logic_vector( 2-1 downto 0);	
			ddr2_cke : out std_logic_vector( 2-1 downto 0);
			ddr2_ras : out std_logic;
			ddr2_cas : out std_logic;
			ddr2_we  : out std_logic;
			ddr2_a   : out std_logic_vector(14-1 downto 0);
			ddr2_ba  : out std_logic_vector( 3-1 downto 0);
			ddr2_dqs_p : inout std_logic_vector(8-1 downto 0);
			ddr2_dqs_n : inout std_logic_vector(8-1 downto 0);
			ddr2_d   : inout std_logic_vector(64-1 downto 0);
			ddr2_dm  : inout std_logic_vector( 8-1 downto 0);
			ddr2_odt : out std_logic_vector( 2-1 downto 0);
--			ddr2_scl  : out std_logic;
--			ddr2_sda  : in  std_logic;

			dvi_xclk_n : out std_logic;
			dvi_xclk_p : out std_logic;
			dvi_reset  : out std_logic;
--			dvi_gpio1  : inout std_logic;
			dvi_de : out std_logic;
			dvi_d  : out std_logic_vector(12-1 downto 0);
			dvi_v  : inout std_logic;
			dvi_h  : inout std_logic;

--			fan_alert : out std_logic;

			fpga_diff_clk_out_p : out std_logic;
			fpga_diff_clk_out_n : out std_logic;
--			fpga_rotary_inca : in std_logic;
--			fpga_rotary_incb : in std_logic;
--			fpga_rotary_push : in std_logic;
			fpga_serial_rx : std_logic_vector(1 to 2) := (others => '-');
			fpga_serial_tx : std_logic_vector(1 to 2) := (others => '-');

--			gpio_dip_sw : in std_logic_vector(8 downto 1);
			gpio_led : out std_logic_vector(8-1 downto 0);
			gpio_led_c  : out std_logic;
			gpio_led_e  : out std_logic;
			gpio_led_n  : out std_logic;
			gpio_led_s  : out std_logic;
			gpio_led_w  : out std_logic;
			gpio_sw_c  : in std_logic := '-';
			gpio_sw_e  : in std_logic := '-';
			gpio_sw_n  : in std_logic := '-';
			gpio_sw_s  : in std_logic := '-';
			gpio_sw_w  : in std_logic := '-';

			hdr1 : std_logic_vector(1 to 32) := (others => '-');
			hdr2_diff_p : std_logic_vector(0 to 4-1) := (others => '-');
			hdr2_diff_n : std_logic_vector(0 to 4-1) := (others => '-');
			hdr2_sm_p : std_logic_vector(4 to 16-1) := (others => '-');
			hdr2_sm_n : std_logic_vector(4 to 16-1) := (others => '-');

--			lcd_fpga_db : std_logic_vector(8-1 downto 4);

			phy_reset : out std_logic;
			phy_col : in std_logic := '-';
			phy_crs : in std_logic := '-';
			phy_int : in std_logic := '-';		-- open drain
			phy_mdc : out std_logic := '-';
			phy_mdio : inout std_logic := '-';

			phy_rxclk : in std_logic := '-';
			phy_rxctl_rxdv : in std_logic := '-';
			phy_rxd  : in std_logic_vector(0 to 8-1) := (others => '-');
			phy_rxer : in std_logic := '-';

			phy_txc_gtxclk : out std_logic := '-';
			phy_txclk : in std_logic := '-';
			phy_txctl_txen : out std_logic;
			phy_txd  : out std_logic_vector(0 to 8-1);
			phy_txer : out std_logic;

--			sram_bw : std_logic_vector(4-1 downto 0);
--			sram_d  : std_logic_vector(32-1 downto 16);
--			sram_dqp : std_logic_vector(4-1 downto 0);
--			sram_flash_a : std_logic_vector(22-1 downto 0);
--			sram_flash_d : std_logic_vector(16-1 downto 0);
--
--			sysace_mpa   : std_logic_vector(7-1 downto 0);
--			sysace_usb_d : std_logic_vector(16-1 downto 0);
--
--			trc_ts : std_logic_vector(6 downto 3);
			user_clk : in std_logic
--
--			vga_in_blue  : std_logic_vector(8-1 downto 0);
--			vga_in_green : std_logic_vector(8-1 downto 0);
--			vga_in_red   : std_logic_vector(8-1 downto 0)
			);
	end component;

begin

	clk <= not clk after 5 ns;
	rst <= '0', '1' after 190.1 ns;
	phy_txclk <= not phy_txclk after 4 ns;

	ml509_e : ml509
	port map (
		user_clk => clk,
		gpio_sw_c => rst,
		gpio_sw_e => '0',

		phy_reset => phy_reset,
		phy_col => phy_col,
		phy_crs => phy_crs,
		phy_int => phy_int,
		phy_mdc => phy_mdc,
		phy_mdio => phy_mdio,

		phy_rxclk => phy_rxclk,
		phy_rxctl_rxdv => phy_rxctl_rxdv,
		phy_rxd  => phy_rxd,
		phy_rxer => phy_rxer,

		phy_txc_gtxclk => phy_txc_gtxclk,
		phy_txclk => phy_txclk,
		phy_txctl_txen => phy_txctl_txen,
		phy_txd => phy_txd,
		phy_txer=> phy_txer);

end;

configuration ml509_structure of testbench is
	for miitx_udp 
		for all : ml509 
			use entity hdl4fpga.ml509(structure);
		end for;
	end for;
end;

configuration ml509_miitx_udp of testbench is
	for miitx_udp 
		for all : ml509 
			use entity hdl4fpga.ml509(miitx_udp);
		end for;
	end for;
end;
