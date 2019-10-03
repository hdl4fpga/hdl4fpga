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

library hdl4fpga;
use  hdl4fpga.std.all;
use  hdl4fpga.scopeiopkg.all;

architecture arbiter of testbench is

	signal rst : std_logic;
	signal clk : std_logic := '0';
	signal req : std_logic_vector(0 to 1);
	signal bus_req : std_logic_vector(0 to 1);
	signal bus_gnt : std_logic_vector(0 to 1);

	constant pp : string := i18n_label(en, vertical);
begin

	rst <= '1', '0' after 20 ns;
	clk <= not clk  after 10 ns;

	process (rst, clk)
		variable dv : std_logic;
	begin
		if rst='1' then
			req <= "00";
			dv := '1';
		elsif rising_edge(clk) then
			if dv='1' then 
				req <= std_logic_vector(unsigned(req) + 1); 
			end if;
			dv := not dv;
		end if;
	end process;
				bus_req <= req;

	arbiter_e : entity hdl4fpga.arbiter
	port map (
		clk => clk,
		bus_req => bus_req,
		bus_gnt => bus_gnt);
end;

