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

entity scopeio_write is
	port (
		clk      : in  std_logic;
		fill_req : in  std_logic;
		fill_rdy : out std_logic;
		length   : in  std_logic_vector;
		point    : in  std_logic_vector;
		element  : out std_logic_vector;
		bin_val  : in  std_logic_vector;
		bin_dv   : out std_logic;
		bcd_dv   : out std_logic;
		bcd_val  : out std_logic_vector);
end;

architecture def of scopeio_write is
	signal dv  : std_logic;
	signal ena : std_logic;
begin

	process(clk)
		variable cntr : unsigned(0 to element'length);
	begin
		if rising_edge(clk) then
			if fill_req='0' then
				cntr := (others => '0');
				ena  <= '0';
			elsif dv='1' then
				if cntr(to_integer(unsigned(length)))='0' then
					cntr := cntr + 1;
				end if;
				ena <= '1';
			else
				ena <= '1';
			end if;
			element  <= std_logic_vector(cntr(1 to element'length));
			fill_rdy <= cntr(to_integer(unsigned(length)));
		end if;
	end process;

	du: entity hdl4fpga.scopeio_format
	port map (
		clk        => clk,
		binary_ena => ena,
		binary     => bin_val,
		point      => point,
		bcd_dv     => dv,
		bcd_dat    => bcd_val);

	bin_dv <= dv;
	bcd_dv <= dv;
end;
