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

entity scopeio_writeticks is
	port (
		clk       : in  std_logic;
		write_req : in  std_logic;
		write_rdy : out std_logic;
		length    : in  std_logic_vector;
		point     : in  std_logic_vector;
		element   : out std_logic_vector;
		bin_val   : in  std_logic_vector;
		bin_dv    : out std_logic;
		bcd_sign  : in  std_logic;
		bcd_left  : in  std_logic;
		bcd_dv    : out std_logic;
		bcd_val   : out std_logic_vector);
end;

architecture def of scopeio_writeticks is
	signal dv  : std_logic;
begin

	process(clk)
		variable cntr : unsigned(element'length downto 0);
	begin
		if rising_edge(clk) then
			if write_req='0' then
				cntr := (others => '0');
			elsif dv='1' then
				if cntr(to_integer(unsigned(length)))='0' then
					cntr := cntr + 1;
				end if;
			end if;
			element   <= std_logic_vector(cntr(element'length-1 downto 0));
			write_rdy <= cntr(to_integer(unsigned(length)));
		end if;
	end process;

	scopeio_format_e : entity hdl4fpga.scopeio_format
	port map (
		clk        => clk,
		binary_ena => write_req,
		binary_dv  => bin_dv,
		binary     => bin_val,
		point      => point,
		bcd_sign   => bcd_sign,
		bcd_left   => bcd_left,
		bcd_dv     => dv,
		bcd_dat    => bcd_val);

	bcd_dv <= dv;
end;
