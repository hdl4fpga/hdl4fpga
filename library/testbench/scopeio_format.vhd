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

architecture scopeio_format of testbench is
	signal rst     : std_logic := '1';
	signal clk     : std_logic := '0';
	signal load    : std_logic := '1';
	signal mark    : std_logic_vector(16-1 downto 0);
	signal bcd_dv  : std_logic;
	signal bcd_dat : std_logic_vector(0 to 4*8-1);

begin

	clk <= not clk  after  5 ns;

	du: entity hdl4fpga.scopeio_format
	port map (
		clk     => clk,
		binary_ld => load,
		binary  => mark,
		point   => b"111",
		bcd_dv  => bcd_dv,
		bcd_dat => bcd_dat);

	load <= bcd_dv or rst;
	process (clk, bcd_dv)
		variable cntr : unsigned(mark'range) := (others => '0');
	begin
		if rising_edge(clk) then
			rst <= '0';
			if bcd_dv='1' then
				cntr := cntr + 40;
			end if;
			mark <= std_logic_vector(cntr);
		end if;
	end process;

end;
