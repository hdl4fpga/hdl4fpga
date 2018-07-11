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

architecture scopeio_mmap of testbench is
	constant n : natural := 4;
	signal rst   : std_logic := '1';
	signal clk   : std_logic := '1';
	signal rrxd  : std_logic_vector(0 to n-1);
	signal rxd   : std_logic_vector(0 to n-1);
	signal rxdv  : std_logic;

	signal txdv  : std_logic;
	signal treq : std_logic;
	signal trdy : std_logic;

begin

	clk <= not clk after 5 ns;
	rst <= '1', '0' after 50 ns;

	process (clk)
		variable edge  : std_logic;
	begin
		if rising_edge(clk) then
			treq <= '1' ; --after 0 ns;
			if rst='1' then
				treq <= '0'; -- after 0 ns;
			elsif txdv='0'  then
			end if;
			edge := txdv;
		end if;
	end process;

	
	miidhcp_e : entity hdl4fpga.mii_rom
	generic map (
		mem_data => reverse(x"01000200010005ff",8))
	port map (
		mii_txc  => clk,
		mii_treq => treq,
		mii_trdy => trdy,
		mii_txdv => rxdv,
		mii_txd  => rxd);


	rrxd <= reverse(rxd);

	du : entity hdl4fpga.scopeio_mmap
	port map (
        in_clk  => clk,
		in_ena  => rxdv,
		in_data => rxd);
end;
