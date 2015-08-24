--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2015                                                    --
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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

library hdl4fpga;

architecture miitx_udp of ml509 is

	signal rst  : std_logic;
	signal txen : std_logic;
	signal mii_txd : std_logic_vector(phy_txd'range);
	signal dcm_lckd : std_logic;
	signal mii_req  : std_logic;

	signal sys_addr : std_logic_vector(0 to 8-1);
	signal sys_data : std_logic_vector(0 to 32-1);
	signal gtx_clk : std_logic;
begin

	rst <= not gpio_sw_c;

	process (gtx_clk)
		variable edge : std_logic;
		variable sent : std_logic;
	begin
		if rising_edge(gtx_clk) then
			if rst='1' then
				mii_req <= '0';
				sent := '0';
				edge := '0';
			elsif sent='0' then
				mii_req <= '1';
				if txen='0' then
					if edge='1' then
						mii_req <= '0';
						sent := '1';
					end if;
				end if;
			end if;
			edge := txen;
		end if;
	end process;


--	bram_e : entity hdl4fpga.dpram
--	generic map (
--		data_size => sys_data'length,
--		address_size => sys_addr'length)
--	port map (
--		rd_clk => gtx_clk,
--		rd_address => sys_addr,
--		rd_data => sys_data);
	sys_data  <= (others => '0');

	mii_dfs_e : entity hdl4fpga.dfs
	generic map (
		dcm_per => 10.0,
		dfs_mul => 5,
		dfs_div => 4)
	port map (
		dcm_rst => gpio_sw_e,
		dcm_clk => user_clk,
		dfs_clk => gtx_clk,
		dcm_lck => dcm_lckd);

	miitx_udp_e : entity hdl4fpga.miitx_udp
	port map (
		sys_addr => sys_addr,
		sys_data => sys_data,
		mii_treq => mii_req,
		mii_txc  => gtx_clk,
		mii_txen => txen,
		mii_txd  => mii_txd);

	phy_reset <= dcm_lckd;
	phy_txer <= '0';
	mii_iob_e : entity hdl4fpga.mii_iob
	generic map (
		xd_len => phy_txd'length)
	port map (
		mii_rxc  => phy_rxclk,
		iob_rxdv => phy_rxctl_rxdv,
		iob_rxd  => phy_rxd,
		mii_rxdv => open,
		mii_rxd  => open,

		mii_txc  => gtx_clk,
		mii_txen => txen,
		mii_txd  => mii_txd,
		iob_txen => phy_txctl_txen,
		iob_txd  => phy_txd);

	gtx_clk_i : oddr
	port map (
		r => '0',
		s => '0',
		c => gtx_clk,
		ce => '1',
		d1 => '0',
		d2 => '1',
		q => phy_txc_gtxclk);


	dvi_gpio1 <= '1';
	bus_error <= (others => 'Z');
	gpio_led <= (others => '0');
	gpio_led_c <= dcm_lckd;
	gpio_led_e <= '0';
	gpio_led_n <= '0';
	gpio_led_s <= '0';
	gpio_led_w <= '0';
	fpga_diff_clk_out_p <= 'Z';
	fpga_diff_clk_out_n <= 'Z';
	ddr2_cs <= (others => '1');
  	ddr2_cke <= (others => '0');
   	ddr2_odt <= (others => 'Z');
	ddr2_dm <= (others => 'Z');
	ddr2_d <= (others => 'Z');
	ddr2_a <= (others => 'Z');
	ddr2_ba <= (others => 'Z');
	ddr2_cas <= 'Z';
	ddr2_ras <= 'Z';
	ddr2_we <= 'Z';
	ddr2_dqs_p <= (others => 'Z');
	ddr2_dqs_n <= (others => 'Z');
	ddr2_clk_n <= (others => 'Z');
	ddr2_clk_p <= (others => 'Z');

	dvi_reset <= '0';
	phy_mdc <= '0';
	dvi_xclk_p <= 'Z';
	dvi_xclk_n <= 'Z';
	dvi_v <= 'Z';
	dvi_h <= 'Z';
	dvi_de <= 'Z';
	dvi_d <= (others => 'Z');

end;
