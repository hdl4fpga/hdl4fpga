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

library hdl4fpga;
use hdl4fpga.base.all;

entity latency is
	generic (
		style : string := "srl";
		n : natural := 1;
		d : natural_vector;
		i : std_logic_vector := (0 to 0 => '-'));
	port (
		clk : in  std_logic;
		ini : in  std_logic := '0';
		ena : in  std_logic := '1';
		di  : in  std_logic_vector(0 to n-1);
		do  : out std_logic_vector(0 to n-1));
end;

architecture def of latency is
	constant dly : natural_vector(0 to d'length-1) := d;
	constant val : std_logic_vector(0 to i'length) := i & '-';
begin
	assert style="register" or style="srl"
	report "Invalid style"
	severity FAILURE;

	delay: for j in 0 to n-1 generate
		signal q : std_logic_vector(0 to dly(j)) := (others => val(setif(j < i'length, j, i'length)));
		attribute shreg_extract : string;
		attribute shreg_extract of q : signal is setif(style="register", "no", "yes");
	begin
		q(q'right) <= di(j);
		process (clk)
		begin
			if rising_edge(clk) then
				if dly(j) > 0 then
					if ini='1' then
						if j < val'length-1 then
							q(0 to q'right-1) <= (others => val(j));
						end if;
					elsif ena='1' then
						q(0 to q'right-1) <= q(1 to q'right);
					end if;
				end if;
			end if;
		end process;
		do(j) <= q(0);
	end generate;
end;
