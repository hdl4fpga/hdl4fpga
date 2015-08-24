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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;

architecture miitx_udp of nuhs3dsp is

	signal rst  : std_logic;
	signal txen : std_logic;
	signal dcm_lck : std_logic;
	signal mii_req : std_logic;

	signal sys_addr : std_logic_vector(0 to 8-1);
	signal sys_data : std_logic_vector(0 to 32-1);
begin

	rst <= sw1;
	mii_rst <= hd_t_clock;

	process (mii_txc)
		variable edge : std_logic;
		variable sent : std_logic;
	begin
		if rising_edge(mii_txc) then
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
--		rd_clk => mii_txc,
--		rd_address => sys_addr,
--		rd_data => sys_data);
	sys_data <= (others => '0');

	mii_dfs_e : entity hdl4fpga.dfs
	generic map (
		dcm_per => 50.0,
		dfs_mul => 5,
		dfs_div => 4)
	port map (
		dcm_rst => '0',
		dcm_clk => xtal,
		dfs_clk => mii_refclk,
		dcm_lck => dcm_lck);

	miitx_udp_e : entity hdl4fpga.miitx_udp
	port map (
		sys_addr => sys_addr,
		sys_data => sys_data,
		mii_treq  => mii_req,
		mii_txc  => mii_txc,
		mii_txen => txen,
		mii_txd  => mii_txd);
	mii_txen <= txen;

	-- Video DAC --
	---------------

	hsync <= 'Z';
	vsync <= 'Z';
	clk_videodac <= 'Z';
	blank <= 'Z';
	sync  <= 'Z';
	psave <= 'Z';
	red   <= (others => 'Z');
	green <= (others => 'Z');
	blue  <= (others => 'Z');

	-- ADC --
	---------

	adc_clkab <= 'Z';

	-- RS232 Transceiver --
	-----------------------

	rs232_rts <= 'Z';
	rs232_td  <= 'Z';
	rs232_dtr <= 'Z';

	-- DDR RAM --
	-------------

	ddr_ckp <= 'Z';
	ddr_ckn <= 'Z';
	ddr_lp_dqs <= 'Z'; 
	ddr_cke <= 'Z';  
	ddr_cs  <= 'Z';  
	ddr_ras <= 'Z';
	ddr_cas <= 'Z';
	ddr_cas <= 'Z';
	ddr_we  <= 'Z';
	ddr_a   <= (others => 'Z');
	ddr_ba  <= (others => 'Z');
	ddr_dm  <= (others => 'Z');
	ddr_dqs <= (others => 'Z');
	ddr_dq  <= (others => 'Z');

	-- LCD --
	---------

	lcd_e  <= 'Z';
	lcd_rs <= 'Z';
	lcd_rw <= 'Z';
	lcd_data <= (others => 'Z');
	lcd_backlight <= 'Z';

	led8 <= hd_t_clock;
	led7 <= dcm_lck;

	led18 <= mii_txc;
	led16 <= '0';
	led15 <= '0';
	led13 <= mii_crs;
	led11 <= '0';
	led9  <= mii_col;

	mii_mdc  <= 'Z';
	mii_mdio <= 'Z';

end;
