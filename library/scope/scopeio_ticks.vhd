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
		trdy     : out std_logic := '1';
		base     : in  std_logic_vector;
		step     : in  std_logic_vector;
		updn     : in  std_logic := '0';

		wu_frm   : out std_logic;
		wu_irdy  : out std_logic := '1';
		wu_trdy  : in  std_logic;
		wu_value : out std_logic_vector);
end;

architecture def of scopeio_ticks is
begin

	process(clk)
		variable frm1 : std_logic;
		variable wfrm : std_logic;
		variable accm : unsigned((base'range);
	begin
		if rising_edge(clk) then
			if frm1='0' then
				accm := unsigned(base);
				wfrm := frm;
			elsif irdy='1' then
				if wfrm='0' then 
					if updn='0' then
						accm := accm + unsigned(step);
					else
						accm := accm - unsigned(step);
					end if;
					wfrm := frm;
				elsif wu_trdy='1' then
					wfrm := '0';
				else
					wfrm := frm;
				end if;
			else
				wfrm := frm;
			end if;
			wu_frm   <= wfrm;
			wu_value <= std_logic_vector(accm);
			frm1     := frm;
		end if;
	end process;
	
end;
