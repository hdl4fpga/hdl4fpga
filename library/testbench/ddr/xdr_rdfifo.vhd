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

use std.textio.all;
library hdl4fpga;

architecture xdr_rdfifo of testbench is
	signal sys_clk : std_logic := '1';
	signal sys_clk2 : std_logic := '1';
	signal sys_rea : std_logic;
	signal sys_rdy : std_logic;
	signal xdr_dqsi : std_logic := '1';
	signal xdr_dqi : std_logic_vector(8-1 downto 0);
	signal xdr_win_dq : std_logic;
	signal xdr_win_dqs : std_logic;
	signal sys_do  : std_logic_vector(2*xdr_dqi'length-1 downto 0);
begin
	sys_clk <= not sys_clk after 2 ns;
	sys_clk2 <= not sys_clk2 after (sys_do'length/xdr_dqi'length) * 1 ns;
	xdr_dqsi <= sys_clk after 50 ps;
	sys_rea <= '0', '1' after 80 ns;
	xdr_win_dq <= '0', '1' after 129 ns, '0' after 463 ns;
	xdr_win_dqs <= '0', '1' after 81 ns, '0' after 463 ns;

	process (xdr_dqsi)
		type byte_vector is array (natural range <>) of std_logic_vector(xdr_dqi'range);
		constant dqi : byte_vector(0 to 16-1) := ( x"ab", x"34", x"75", x"89", x"e6", x"bc", x"fd", x"21",
		x"bb", x"33", x"77", x"99", x"ee", x"bb", x"dd", x"a1");
		variable i : natural range 0 to dqi'length-1;
	begin
		xdr_dqi <= dqi(i);
		i := (i+1) mod dqi'length;
	end process;

	xdr_rdfifo_e : entity hdl4fpga.xdr_rdfifo
	generic map (
		data_delay  => 1,
		data_edges  => 2,
		data_phases => 2,
		line_size   => xdr_dqi'length,
		word_size   => xdr_dqi'length,
		byte_size   => xdr_dqi'length)
	port map (
		sys_clk => sys_clk2,
		sys_rdy(0) => sys_rdy,
		sys_rea => sys_rea,
		sys_do  => sys_do,

		xdr_win_dq(0) => xdr_win_dq,
		xdr_win_dqs(0) => xdr_win_dqs,
		xdr_dqsi(0) => xdr_dqsi,
		xdr_dqi  => xdr_dqi);
end;
