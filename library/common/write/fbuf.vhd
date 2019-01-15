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

architecture btod of testbench is

	signal rst : std_logic := '0';
	signal clk : std_logic := '0';

	signal bin_dv : std_logic;
	signal bin_di : std_logic_vector(0 to 4-1);
	signal bcd_do : std_logic_vector(0 to 4-1);
	signal bcd_di : std_logic_vector(0 to 4-1);
	signal bcd_cy : std_logic;
begin

	rst <= '1', '0' after 5 ns;
	clk <= not clk after 10 ns;

	process (clk)
		variable binary : unsigned(0 to 2*4-1);
	begin
		if rising_edge(clk) then
			if rst='1' then
				bin_dv <= '1';
				binary := x"ff";
			else
				bin_dv <= '0';
				binary := binary sll 4;
			end if;
			bin_di <= std_logic_vector(binary(bin_di'range));
		end if;
	end process;

	du : entity hdl4fpga.btod
	port map (
		clk    => clk,
		bin_dv => bin_dv,
		bin_di => bin_di,
		bcd_di => bcd_di,
		bcd_do => bcd_do,
		bcd_cy => bcd_cy);

end;
