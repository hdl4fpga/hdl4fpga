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
use hdl4fpga.std.all;

entity grant is
	port (
		rsrc_clk : in  std_logic;
		rsrc_rdy : in  std_logic;
		rsrc_req : buffer std_logic;

		dev_req  : in  std_logic_vector;
		dev_gnt  : buffer std_logic_vector;
		dev_rdy  : buffer std_logic_vector);
end;

architecture def of grant is
	signal dev_idle : std_logic;
	signal arb_req  : std_logic_vector(dev_req'range);
begin

	arb_req <= dev_req xor to_stdlogicvector(to_bitvector(dev_rdy)); 
	arbiter_e : entity hdl4fpga.arbiter
	port map (
		clk  => rsrc_clk,
		req  => arb_req,
		idle => dev_idle,
		gnt  => dev_gnt);

	process (rsrc_clk)
		variable idle : std_logic;
	begin
		if rising_edge(rsrc_clk) then
			if (to_stdulogic(to_bit(rsrc_req)) xor to_stdulogic(to_bit(rsrc_rdy)))='0' then
				for i in dev_gnt'range loop
					if dev_gnt(i)='1' then
						if idle='1' then
							rsrc_req <= not to_stdulogic(to_bit(rsrc_rdy));
						else
							dev_rdy(i) <= to_stdulogic(to_bit(dev_req(i)));
						end if;
						idle := not idle;
					elsif dev_idle='1' then
						idle := '1';
					end if;
				end loop;
			end if;
		end if;
	end process;

end;
