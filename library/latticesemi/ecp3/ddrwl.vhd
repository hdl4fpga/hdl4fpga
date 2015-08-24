--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2010-2013                                                    --
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

entity ddrwl is
	port (
		clk : in  std_logic;
		req : in  std_logic;
		rdy : out std_logic;
		nxt : out std_logic;
		dg  : out std_logic_vector);
end;

library hdl4fpga;

architecture beh of ddrwl is
	signal aph_dg  : unsigned(0 to dg'length);
begin

	process (clk)
		variable cntr : unsigned(0 to 4-1);
	begin
		if rising_edge(clk) then
			if req='0' then
				aph_dg <= (0 => '1', others => '0');
				cntr   := (others => '0');
				nxt <= '0';
			elsif aph_dg(aph_dg'right)='0' then
				if cntr(0)='1' then
					aph_dg <= aph_dg srl 1;
					cntr := (others => '0');
				else
					cntr := cntr + 1;
				end if;
			end if;
			nxt <= cntr(0) and not aph_dg(aph_dg'right);
		end if;
	end process;

	dg  <= std_logic_vector(aph_dg(0 to dg'length-1));
	rdy <= aph_dg(aph_dg'right);

end;
