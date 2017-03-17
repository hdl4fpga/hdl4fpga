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
use hdl4fpga.std.all;

entity scopeio_miirx is
	port (
		mii_rxc  : in  std_logic;
		mii_rxdv : in  std_logic;
		mii_rxd  : in  std_logic_vector;
		mii_rrdy : out std_logic;

		pll_rdy  : out std_logic;
		pll_data : out std_logic_vector;
		ser_ena  : out std_logic;
		ser_data : out std_logic_vector);

end;

architecture mix of scopeio_miirx is
	signal mac_rdy  : std_logic;
	signal mac_rxd  : std_logic_vector(mii_rxd'range);
	signal mac_rxdv : std_logic;
	signal mac_vld  : std_logic;

	signal pre_rdy  : std_logic;
	signal prdy     : std_logic;
begin

	miirxpre_e : entity hdl4fpga.miirx_pre
	port map (
		mii_rxc  => mii_rxc,
		mii_rxd  => mii_rxd,
		mii_rxdv => mii_rxdv,
		mii_rdy  => pre_rdy);

	miirxmac_e  : entity hdl4fpga.mii_mem
	generic map (
		mem_data => x"00_00_00_01_02_03")
	port map (
		mii_txc  => mii_rxc,
		mii_treq => pre_rdy,
		mii_trdy => mac_rdy,
		mii_txen => mac_rxdv,
		mii_txd  => mac_rxd);

	process (mii_rxc)
	begin
		if rising_edge(mii_rxc) then
			if pre_rdy='0' then
				mac_vld <= '1';
			elsif mac_rdy='0' then
				mac_vld <= mac_vld and setif(mac_rxd=mii_rxd);
			end if;
		end if;
	end process;

	pll_p : process(mii_rxc)
		variable data : unsigned(0 to pll_data'length-1);
		variable cntr : unsigned(0 to unsigned_num_bits(pll_data'length/mii_rxd'length-1));
	begin
		if rising_edge(mii_rxc) then
			if mac_rdy='0' then
				cntr := to_unsigned(pll_data'length/mii_rxd'length-1,cntr'length);
			elsif cntr(0)='0' then
				data := data srl mii_rxd'length;
				data(mii_rxd'range) := unsigned(mii_rxd);
				cntr := cntr - 1;
			end if;
			pll_data <= reverse(std_logic_vector(data));
			prdy     <= cntr(0) and mac_vld and mii_rxdv;
		end if;
	end process;
	pll_rdy <= prdy;

	ser_p : process(mii_rxc)
		variable data : unsigned(0 to ser_data'length-1);
		variable cntr : signed(0 to unsigned_num_bits(ser_data'length/mii_rxd'length-1));
	begin
		if rising_edge(mii_rxc) then
			if prdy='0' then
				cntr := to_signed(ser_data'length/mii_rxd'length-1,cntr'length);
			elsif cntr(0)='1' then
				cntr := to_signed(ser_data'length/mii_rxd'length-2,cntr'length);
			else
				cntr := cntr - 1;
			end if;
			data := data srl mii_rxd'length;
			data(mii_rxd'range) := unsigned(mii_rxd);
			ser_data <= reverse(std_logic_vector(data));
			ser_ena  <= cntr(0) and prdy and mii_rxdv;
		end if;
	end process;
	mii_rrdy <= not mii_rxdv;

end;
