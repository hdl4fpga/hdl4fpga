--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2015                                                         --
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

use std.textio.all;

library ieee;
use ieee.std_logic_textio.all;

architecture miitx_udp of testbench is
	component nuhs3dsp is
		port (
			xtal : in std_logic;
			sw1 : in std_logic;
			hd_t_data  : inout std_logic := '1';
			hd_t_clock : in std_logic := '0';

			--------------
			-- switches --

			dip : in std_logic_vector(0 to 7) := (others => 'Z');

			led18 : out std_logic := 'Z';
			led16 : out std_logic := 'Z';
			led15 : out std_logic := 'Z';
			led13 : out std_logic := 'Z';
			led11 : out std_logic := 'Z';
			led9  : out std_logic := 'Z';
			led8  : out std_logic := 'Z';
			led7  : out std_logic := 'Z';

			---------------
			-- Video DAC --
			
			hsync : out std_logic := '0';
			vsync : out std_logic := '0';
			clk_videodac : out std_logic := 'Z';
			blank : out std_logic := 'Z';
			sync  : out std_logic := 'Z';
			psave : out std_logic := 'Z';
			red   : out std_logic_vector(8-1 downto 0) := (others => 'Z');
			green : out std_logic_vector(8-1 downto 0) := (others => 'Z');
			blue  : out std_logic_vector(8-1 downto 0) := (others => 'Z');

			---------
			-- ADC --

			adc_clkab : out std_logic := 'Z';
			adc_clkout : in std_logic := 'Z';
			adc_da : in std_logic_vector(14-1 downto 0) := (others => 'Z');
			adc_db : in std_logic_vector(14-1 downto 0) := (others => 'Z');

			-----------------------
			-- RS232 Transceiver --

			rs232_dcd : in std_logic := 'Z';
			rs232_dsr : in std_logic := 'Z';
			rs232_rd  : in std_logic := 'Z';
			rs232_rts : out std_logic := 'Z';
			rs232_td  : out std_logic := 'Z';
			rs232_cts : in std_logic := 'Z';
			rs232_dtr : out std_logic := 'Z';
			rs232_ri  : in std_logic := 'Z';

			--------------------------
			-- Ethernet Transceiver --

			mii_rst  : out std_logic := 'Z';
			mii_refclk : out std_logic := 'Z';
			mii_mdc  : out std_logic := 'Z';
			mii_mdio : inout std_logic := 'Z';

			mii_txc  : in  std_logic := 'Z';
			mii_txen : out std_logic := 'Z';
			mii_txd  : out std_logic_vector(4-1 downto 0);

			mii_rxc  : in std_logic := 'Z';
			mii_rxdv : in std_logic := 'Z';
			mii_rxd  : in std_logic_vector(4-1 downto 0) := (others => 'Z');
			mii_rxer : in std_logic := 'Z';

			mii_crs  : in std_logic := 'Z';
			mii_col  : in std_logic := 'Z';
			mii_intrp : in std_logic := 'Z';

			-------------
			-- DDR RAM --

			ddr_ckp : out std_logic := 'Z';
			ddr_ckn : out std_logic := 'Z';
			ddr_lp_ckp : in std_logic := 'Z';
			ddr_lp_ckn : in std_logic := 'Z';
			ddr_st_lp_dqs : in std_logic := 'Z';
			ddr_lp_dqs : out std_logic := 'Z';
			ddr_cke : out std_logic := 'Z';
			ddr_cs  : out std_logic := 'Z';
			ddr_ras : out std_logic := 'Z';
			ddr_cas : out std_logic := 'Z';
			ddr_we  : out std_logic := 'Z';
			ddr_ba  : out std_logic_vector(2-1  downto 0) := (2-1  downto 0 => 'Z');
			ddr_a   : out std_logic_vector(13-1 downto 0) := (13-1 downto 0 => 'Z');
			ddr_dm  : inout std_logic_vector(0 to 2-1) := (0 to 2-1 => 'Z');
			ddr_dqs : inout std_logic_vector(0 to 2-1) := (0 to 2-1 => 'Z');
			ddr_dq  : inout std_logic_vector(16-1 downto 0) := (16-1 downto 0 => 'Z'));
	end component;

	signal rst : std_logic;
	signal clk : std_logic := '0';

	signal mii_rst : std_logic;
	signal mii_refclk : std_logic;
	signal mii_crs  : std_logic := '0';
	signal mii_col  : std_logic := '0';
	signal mii_txc  : std_logic := '0';
	signal mii_txen : std_logic;
	signal mii_txd  : std_logic_vector(4-1 downto 0);
		
begin

	rst <= '1', '0' after 1 us;
	clk <= not clk after 25 ns;
	mii_txc <= mii_refclk;

	nuhs3dsp_e : nuhs3dsp
	port map (
		xtal => clk,
		sw1  => rst,

		mii_rst    => mii_rst,
		mii_refclk => mii_refclk,

		mii_txc  => mii_txc,
		mii_txen => mii_txen,
		mii_txd  => mii_txd,

		mii_crs  => mii_crs,
		mii_col  => mii_col);

	process (mii_txc)
		variable msg : line;
	begin
		if rising_edge(mii_txc) then
			if mii_txen='1' then
				write (msg, mii_txd);
				writeline (output, msg);
			end if;
		end if;
	end process;

end;

library hdl4fpga;

configuration nuhs3dsp_structure of testbench is
	for miitx_udp 
		for all : nuhs3dsp 
			use entity hdl4fpga.nuhs3dsp(structure);
		end for;
	end for;
end;

library hdl4fpga;

library hdl4fpga;

configuration nuhs3dsp_miitx_udp of testbench is
	for miitx_udp 
		for all : nuhs3dsp 
			use entity hdl4fpga.nuhs3dsp(miitx_udp);
		end for;
	end for;
end;
