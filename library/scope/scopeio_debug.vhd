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
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

library hdl4fpga;
use hdl4fpga.base.all;

entity scopeio_debug is
	generic (
		mac       : in std_logic_vector(0 to 6*8-1) := x"00_40_00_01_02_03");
	port (
		mii_rxc   : in  std_logic;
		mii_rxd   : in  std_logic_vector;
		mii_rxdv  : in  std_logic;

		mii_req   : in  std_logic;
		mii_txc   : in  std_logic;
		mii_txd   : out std_logic_vector;
		mii_txdv  : out std_logic;

		video_clk : in  std_logic;
		video_dot : out std_logic;
		video_hs  : out std_logic;
		video_vs  : out std_logic);
	end;

architecture struct of scopeio_debug is

	signal d_rxc  : std_logic;
	signal d_rxdv : std_logic;
	signal d_rxd  : std_logic_vector(mii_txd'range);
	signal udpports_vld : std_logic_vector(0 to 0);
	signal udpdata_vld : std_logic;
	signal udp_rxd  : std_logic_vector(mii_rxd'range);
	signal udp_rxdv : std_logic_vector(udpports_vld'range);

	constant id_cgaaddr : natural := 0;
	constant id_cgadata : natural := 1;

	constant rgtr_map : natural_vector(0 to 2-1) := (
		id_cgaaddr => 14,
		id_cgadata => 8);
	signal rgtr_data : std_logic_vector(16-1 downto 0);
	signal rgtr_dv   : std_logic;
	signal rgtr_id   : std_logic_vector(8-1 downto 0);
	signal cga_addr  : std_logic_vector(14-1 downto 0);
	signal cga_data  : std_logic_vector(8-1 downto 0);
	signal bcd_str   : std_logic_vector(28-1 downto 0);
	signal fix       : std_logic_vector(8-1 downto 0);
	signal mgntd     : std_logic_vector(4-1 downto 2);
	signal mult      : std_logic_vector(2-1 downto 0);

begin

	mii_ipcfg_e : entity hdl4fpga.mii_ipcfg
	generic map (
		mac       => x"00_40_00_01_02_03")
	port map (
		mii_req   => mii_req,

		mii_rxc   => mii_rxc,
		mii_rxdv  => mii_rxdv,
		mii_rxd   => mii_rxd,
		udpdports_val  => std_logic_vector(to_unsigned(57001,16)),
		udpdports_vld => udpports_vld,
		udpddata_vld => udpdata_vld,

		mii_txc   => mii_txc,
		mii_txdv  => mii_txdv,
		mii_txd   => mii_txd);

	clip_crc_b : block
		constant lat : natural := 32/mii_rxd'length;

		signal dv : std_logic;
	begin

		lat_vld_e : entity hdl4fpga.align
		generic map (
			n => 1,
			d => (0 => lat))
		port map (
			clk   => mii_rxc,
			di(0) => udpdata_vld,
			do(0) => dv);

		process (mii_rxc)
		begin
			if rising_edge(mii_rxc) then
				for i in udpports_vld'range loop
					udp_rxdv(i) <= dv and udpports_vld(i);
				end loop;
			end if;
		end process;

		lat_rxd_e : entity hdl4fpga.align
		generic map (
			n => mii_rxd'length,
			d => (mii_rxd'range => lat+1))
		port map (
			clk => mii_rxc,
			di  => mii_rxd,
			do  => udp_rxd);
	end block;

	scopeio_sin_e : entity hdl4fpga.scopeio_sin
	port map (
		sin_clk   => mii_rxc,
		sin_dv    => udp_rxdv(0),
		sin_data  => udp_rxd,
		rgtr_id   => rgtr_id,
		rgtr_dv   => rgtr_dv,
		rgtr_data => rgtr_data);

	process(mii_rxc)
	begin
		if rising_edge(mii_rxc) then
			if rgtr_dv='1' then
				case rgtr_id is
				when x"00" =>
					fix <= rgtr_data(fix'range);
				when x"01" =>
					mgntd <= rgtr_data(mgntd'range);
					mult  <= rgtr_data(mult'range);
				when others =>
				end case;
			end if;
		end if;
	end process;

	process(mii_rxc)

		function bcdtoascii (
			constant bcd_code : std_logic_vector(0 to 4-1))
			return ascii is
			variable retval : ascii;
		begin
			if to_integer(unsigned(bcd_code)) < 10 then
				retval := x"3" & bcd_code;
			elsif bcd_code=b"1010" then
				retval := x"20";    -- blank
			elsif bcd_code=b"1011" then
				retval := x"2e";    -- ".";
			elsif bcd_code=b"1100" then
				retval := x"2b";    -- "+";
			elsif bcd_code=b"1101" then
				retval := x"2d";    -- "-";
			else
				retval := (others => '-');
			end if;
			return retval;
		end;

		variable addr : unsigned(cga_addr'range);
		variable data : unsigned(bcd_str'length-1 downto 0);
		variable cntr : signed(0 to 4-1);

	begin

		if rising_edge(mii_rxc) then
			if cntr(0)='1' then
				addr := (others => '0');
				data := x"0123456";
				data := unsigned(bcd_str);
				cntr := not to_signed(-7, cntr'length);
			else
				addr := addr + 1;
				data := data rol 4;
				cntr := cntr - 1;
			end if;
			cga_data <= bcdtoascii(std_logic_vector(data(4-1 downto 0)));
			cga_addr <= std_logic_vector(addr);
		end if;

	end process;

	cga_display_e : entity hdl4fpga.cga_display
	port map (
		cga_clk   => mii_rxc,
		cga_addr  => cga_addr,
		cga_data  => cga_data,

		video_clk => video_clk,
		video_dot => video_dot,
		video_hs  => video_hs,
		video_vs  => video_vs);

end;
