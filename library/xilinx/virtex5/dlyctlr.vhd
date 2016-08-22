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

use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity dlyctlr is
	port (
		clk     : in  std_logic;
		req     : in  std_logic;
		rdy     : out std_logic;
		dly     : in  std_logic_vector;
		iod_rst : out std_logic;
		iod_ce  : out std_logic);

end;

architecture beh of dlyctlr is
	signal aux : unsigned(0 to dly'length);
begin
  
	process (clk)
	begin
		if rising_edge(clk) then
			if req='0' then
				aux <= resize(unsigned(dly), aux'length);
			elsif aux(0)='0' then
				aux <= aux - 1;
			end if;
		end if;
	end process;

	process (clk)
	begin
		if rising_edge(clk) then
			if req='0' then
				iod_rst <= '1';
				iod_ce  <= '1';
			elsif aux(0)='0' then
				iod_rst <= '0';
				iod_ce  <= '1';
			else
				iod_rst <= '0';
				iod_ce  <= '0';
			end if;
		end if;
	end process;

end;
