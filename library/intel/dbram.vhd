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

entity dbram is
	generic (
		n : natural);
	port (
		clk : in  std_logic;
		we  : in  std_logic;
		wa  : in  std_logic_vector(4-1 downto 0);
		di  : in  std_logic_vector(n-1 downto 0);
		ra  : in  std_logic_vector(4-1 downto 0);
		do  : out  std_logic_vector(n-1 downto 0));
end;

library hdl4fpga;

architecture intel of dbram is
begin
	dram_p : process (ra, clk)
		type ram16x4 is array(0 to 2**wa'length-1) of std_logic_vector(di'range);
		variable ram : ram16x4;
	begin
		if rising_edge(clk) then
			if we='1' then
				ram(to_integer(unsigned(wa))) := di;
			end if;
		end if;
		do <= ram(to_integer(unsigned(ra)));
	end process;

	-- ram_e : entity hdl4fpga.dpram 
	-- generic map (
		-- synchronous_rdaddr => false,
		-- synchronous_rddata => false)
	-- port map (
		-- rd_clk  => clk,
		-- rd_addr => ra,
		-- rd_data => do,
-- 
		-- wr_clk  => clk,
		-- wr_ena  => we,
		-- wr_addr => wa,
		-- wr_data => di);
end;