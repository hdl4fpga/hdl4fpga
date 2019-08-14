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

entity scopeio_ticks is
	port (
		clk      : in  std_logic;
		frm      : in  std_logic;
		irdy     : in  std_logic := '1';
		trdy     : out std_logic := '0';
		last     : in  std_logic_vector;
		base     : in  std_logic_vector;
		step     : in  std_logic_vector;
		updn     : in  std_logic := '0';

		tick_frm   : out std_logic;
		tick_irdy  : out std_logic;
		tick_trdy  : in  std_logic;
		tick_value : out std_logic_vector);
end;

architecture def of scopeio_ticks is
begin

	process(clk)
		variable frm1 : std_logic;
		variable wfrm : std_logic;
		variable accm : signed(base'range);
		variable cntr : unsigned(last'range);
	begin
		if rising_edge(clk) then
			if frm='0' then
				frm1 := '0';
				wfrm := '0';
				trdy <= '0';
				accm := (others => '-');
				cntr := (others => '-');
			elsif frm1='0' then
				frm1 := '1';
				wfrm := '1';
				trdy <= '0';
				accm := signed(base);
				cntr := (others => '0');
			else
				frm1 := '1';
				if irdy='1' then
					if wfrm='0' then 
						if cntr < unsigned(last) then
							wfrm := '1';
							trdy <= '0';
							if updn='0' then
								accm := accm + signed(step);
							else
								accm := accm - signed(step);
							end if;
							cntr := cntr + 1;
						else
							wfrm := '0';
							trdy <= '1';
						end if;
					elsif tick_trdy='1' then
						wfrm := '0';
						trdy <= '0';
					end if;
				end if;
			end if;
			tick_frm   <= wfrm;
			tick_irdy  <= wfrm;
			tick_value <= std_logic_vector(accm);
		end if;
	end process;
	
end;
