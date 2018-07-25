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

architecture btod of testbench is
	constant n : natural := 12;
	constant m : natural := 16;

	signal rst : std_logic := '0';
	signal clk : std_logic := '0';
	signal bin_dv : std_logic;
	signal bin_di : std_logic_vector(8-1 downto 0); 

	signal bcd_dv : std_logic;
	signal bcd_di : std_logic_vector(24-1 downto 0);
	signal bcd_en : std_logic;
	signal bcd_do : std_logic_vector(bcd_di'range);

begin
	rst <= '1', '0' after 5 ns;
	clk <= not clk after 10 ns;

	process (rst, clk)
		variable ena : std_logic;
	begin
		if rst='1' then
			bin_dv <= '0';
			ena    := '0';
		elsif rising_edge(clk) then
			if bin_dv='1' then
				bin_dv <= '0';
			elsif ena='0' then
				bin_dv <= '1';
				ena    := '1';
			end if;
		end if;
	end process;

	bcd_dv <= bin_dv;
	bin_di <= x"ff";
	bcd_di <= x"000_000";
	
	du : entity hdl4fpga.btod
	port map (
		clk    => clk,

		bin_dv => bin_dv,
		bin_di => bin_di,

		bcd_dv => bcd_dv,
		bcd_di => bcd_di,
		bcd_en => bcd_en,
		bcd_do => bcd_do);

end;
