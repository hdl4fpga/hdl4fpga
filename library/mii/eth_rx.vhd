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

library hdl4fpga;
use hdl4fpga.std.all;

entity eth_rx is
	generic (
		mac       : in std_logic_vector(0 to 6*8-1) := x"00_40_00_01_02_03");
	port (
		mii_rxc   : in  std_logic;
		mii_rxd   : in  std_logic_vector;
		mii_rxdv  : in  std_logic;
		mii_pre   : buffer std_logic;
		eth_bcst  : buffer std_logic;
		eth_macd  : buffer std_logic);

end;

architecture def of eth_rx is

	function to_miisize(
		constant size : natural) 
		return natural is
	begin
		return (size+mii_rxd'length-1)/mii_rxd'length;
	end;

	function wor (
		constant arg : std_logic_vector)
		return std_logic is
	begin
		for i in arg'range loop
			if arg(i)='1' then
				return '1';
			end if;
		end loop;
		return '0';
	end;

	constant ipproto   : std_logic_vector := x"0800";
	constant arpproto  : std_logic_vector := x"0806";

	constant miiptr_size : natural := unsigned_num_bits(to_miisize(64*8));
	signal mii_ptr       : unsigned(0 to miiptr_size-1); -- := (others => '0');

	constant macd  : natural := 0;
	constant macs  : natural := 1;
	constant ethty : natural := 2;
	constant eth_pfx : natural_vector := (
		macd  => 6*8,
		macs  => 6*8,
		ethty => 2*8);

	function mii_decode (
		constant ptr   : std_logic_vector;
		constant frame : natural_vector)
		return std_logic_vector is
		variable retval : std_logic_vector(frame'range);
		variable low  : natural;
		variable high : natural;
	begin
		retval := (others => '0');
		low    := 0;
		for i in frame'range loop
			high := low + frame(i);
			if low <= i and i < high then
				retval(i) := '1';
				exit;
			end if;
			low := high;
		end loop;
		return retval;
	end;

begin

	mii_pre_e : entity hdl4fpga.miirx_pre 
	port map (
		mii_rxc  => mii_rxc,
		mii_rxd  => mii_rxd,
		mii_rxdv => mii_rxdv,
		mii_rdy  => mii_pre);

	process (mii_rxc)
	begin
		if rising_edge(mii_rxc) then
			if mii_pre='0' then
				mii_ptr <= (others => '0');
			elsif mii_ptr(0)='0' then
				mii_ptr <= mii_ptr + 1;
			end if;
		end if;
	end process;

	mymac_e : entity hdl4fpga.mii_romcmp
	generic map (
		mem_data => reverse(mac,8))
	port map (
		mii_rxc  => mii_rxc,
		mii_rxd  => mii_rxd,
		mii_treq => mii_pre,
		mii_pktv => eth_macd);

	mii_bcst_e : entity hdl4fpga.mii_romcmp
	generic map (
		mem_data => reverse(x"ff_ff_ff_ff_ff_ff", 8))
	port map (
		mii_rxc  => mii_rxc,
		mii_rxd  => mii_rxd,
		mii_treq => mii_pre,
		mii_pktv => eth_bcst);


end;

