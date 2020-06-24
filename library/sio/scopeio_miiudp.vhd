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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity scopeio_miiudp is
	generic (
		preamble_disable : boolean := false;
		crc_disable : boolean := false;
		mac      : in std_logic_vector(0 to 6*8-1) := x"00_40_00_01_02_03");
	port (
		mii_rxc  : in  std_logic;
		mii_rxd  : in  std_logic_vector;
		mii_rxdv : in  std_logic;
		myipcfg_vld   : buffer std_logic;
		mymac_vld   : out std_logic;

		mii_req   : in  std_logic;
		mii_txc   : in  std_logic;
		mii_txd   : out std_logic_vector;
		mii_txdv  : out std_logic;

		so_clk   : out std_logic;
		so_dv    : out std_logic;
		so_data  : out std_logic_vector);
	end;

architecture struct of scopeio_miiudp is

	signal udpdports_vld : std_logic_vector(0 to 0);
	signal udpddata_vld  : std_logic;
begin


	mii_ipcfg_e : entity hdl4fpga.mii_ipcfg
	generic map (
		preamble_disable => preamble_disable,
		mac       => x"00_40_00_01_02_03")
	port map (
		mii_req   => mii_req,

		mii_rxc   => mii_rxc,
		mii_rxdv  => mii_rxdv,
		mii_rxd   => mii_rxd,
		myipcfg_vld => myipcfg_vld,
		mymac_vld => mymac_vld,
		udpdports_val => std_logic_vector(to_unsigned(57001,16)),
		udpdports_vld => udpdports_vld,
		udpddata_vld  => udpddata_vld,

		mii_txc   => mii_txc,
		mii_txdv  => mii_txdv,
		mii_txd   => mii_txd);

	clip_crc_b : block
		constant lat    : natural := 32/mii_rxd'length;

		signal dv : std_logic;
		signal data : std_logic_vector(mii_rxd'range);
	begin

		dvlat_e : entity hdl4fpga.align
		generic map (
			n => 1,
			d => (0 => lat))
		port map (
			clk   => mii_rxc,
			di(0) => udpddata_vld,
			do(0) => dv);

		process (mii_rxc)
		begin
			if rising_edge(mii_rxc) then
				if not crc_disable then
					so_dv <= udpdports_vld(0) and dv;
				else	
					so_dv <= udpdports_vld(0) and udpddata_vld;
				end if;
			end if;
		end process;

		datalat_e : entity hdl4fpga.align
		generic map (
			n => mii_rxd'length,
			d => (1 to mii_rxd'length => lat))
		port map (
			clk => mii_rxc,
			di  => mii_rxd,
			do  => data);

		process (mii_rxc)
		begin
			if rising_edge(mii_rxc) then
				if not crc_disable then
					so_data <= data;
				else	
					so_data <= mii_rxd;
				end if;
			end if;
		end process;

	end block;

	so_clk  <= mii_rxc;

end;
