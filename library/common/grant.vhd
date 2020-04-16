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
		rsrc_req : out std_logic;

		dev_req  : in  std_logic_vector;
		dev_gnt  : buffer std_logic_vector;
		dev_rdy  : out std_logic_vector);


end;

architecture def of grant is
	signal gnt : std_logic_vector(dev_gnt'range);
begin

	process (rsrc_clk)
	begin
		if rising_edge(rsrc_clk) then
			gnt <= dev_gnt;
		end if;
	end process;

	arbiter_e : entity hdl4fpga.arbiter
	port map (
		clk      => rsrc_clk,
		rsrc_req => dev_req,
		rsrc_gnt => dev_gnt);

	dev_rdy  <= dev_gnt and (dev_rdy'range => rsrc_rdy);
	rsrc_req <= setif((dev_gnt and dev_req) /= (dev_req'range => '0'));
end;
