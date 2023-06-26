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
use hdl4fpga.base.all;
use hdl4fpga.usbpkg.all;

entity montrqst is
	port (
		rst  : in  std_logic := '0';
		clk  : in  std_logic;
		cken : in  std_logic := '1';

		req  : in  bit;
		rdys : in  bit_vector;
		reqs : in  bit_vector;
		rdy  : buffer bit);

end;

architecture def of montrqst is
begin

	process (clk)
		variable z : bit;
	begin
		if rising_edge(clk) then
			if rst='1' then
				rdy <= req;
			elsif cken='1' then
				if (rdy xor req)='1' then
					z := '0';
					for i in rdys'range loop
						 z := z or (rdys(i) xor reqs(i));
					end loop;
				end if;
				if z='0' then
					rdy <= req;
				end if;
			end if;
		end if;
	end process;

end;