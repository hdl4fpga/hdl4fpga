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

entity scopeio_grant is
	port (
		clk      : in  std_logic;
		unit_rdy : in  std_logic;
		unit_req : out std_logic;
		dev_req  : in  std_logic_vector;
		dev_gnt  : out std_logic_vector;
		dev_rdy  : out std_logic_vector);
end;


architecture beh of scopeio_grant is
	signal gnt : std_logic_vector(0 to unsigned_num_bits(dev_req'length)-1);
begin

	process(clk)
	begin
		if rising_edge(clk) then
			for i in dev_req'range loop
				if unit_rdy='1' then
					gnt <= (others => '0');
				elsif not gnt/=(gnt'range => '0') then
					if dev_req(i)='1' then
						gnt <= std_logic_vector(to_unsigned(i, gnt'length));
						exit;
					end if;
				end if;
			end loop;
		end if;
	end process;

	unit_req <= word2byte("0" & dev_req, gnt, 1)(0) and not unit_rdy;
	dev_gnt  <= demux(gnt)(1 to dev_rdy'length);
	dev_rdy  <= demux(gnt, unit_rdy)(1 to dev_rdy'length);

end;
