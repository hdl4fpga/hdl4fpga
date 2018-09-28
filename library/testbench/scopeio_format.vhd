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

architecture scopeio_format of testbench is
	signal rst     : std_logic := '1';
	signal clk     : std_logic := '0';

	signal fill_ena : std_logic := '1';
	signal point    : std_logic_vector(0 to 2) := "111";

	signal value    : std_logic_vector(16-1 downto 0);
	signal bcd_dv   : std_logic;
	signal bcd_dat  : std_logic_vector(0 to 4*8-1);
	signal binary_ena : std_logic;
	signal binary_dv : std_logic;
	signal t        : std_logic;

begin

	clk <= not clk  after  5 ns;
	rst <= '1', '0' after 26 ns;

	process (clk)
	begin
		if rising_edge(clk) then
			if rst='0' then
				binary_ena <= '1';
				if binary_dv='1' then
					t <= not t;
				end if;
			else
				t <= '0';
				binary_ena <= '0';
			end if;
		end if;
	end process;

	value <= b"0000_1111_1111_1111" when t='0' else b"0001_0000_0101_1111";
	du: entity hdl4fpga.scopeio_format
	port map (
		clk        => clk,
		binary_ena => binary_ena,
		binary_dv => binary_dv,
		binary     => value,
		point      => point,
		bcd_left   => '0',
		bcd_dv     => bcd_dv,
		bcd_dat    => bcd_dat);

end;
