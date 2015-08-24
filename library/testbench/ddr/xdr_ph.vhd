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
use ieee.std_logic_textio.all;

use std.textio.all;
library hdl4fpga;

architecture xdr_ph of testbench is
	constant data_phases : natural := 1;
	constant data_edges  : natural := 1;
	constant period : time := 4 ns;
	constant word_size : natural := 4;
	constant byte_size : natural := 1;

	signal clk : std_logic := '0';
	signal sys_clks : std_logic_vector(0 to data_phases/data_edges-1);
	signal di : std_logic_vector(0 to word_size/byte_size-1) := (others => '0');
	signal j : natural;
begin
	clk <= not clk after period;

	process (clk)
	begin
		for i in sys_clks'range loop
			sys_clks(i) <= clk after (i * period) / sys_clks'length;
		end loop;
		if rising_edge(clk) then
		j <= (j + 1) mod 7;
		if j = 6 then
            di <= not di after 1 ps;
        end if;
        if j = 2 then
            di <= not di after 1 ps;
        end if;
    end if;
	end process;

	du : entity hdl4fpga.xdr_ph
	generic map (
		data_phases => data_phases,
		data_edges => data_edges,
		word_size => word_size,
		byte_size => byte_size,
		delay_size => 15)
	port map (
		sys_clks => sys_clks,
		sys_di => di);
end;
