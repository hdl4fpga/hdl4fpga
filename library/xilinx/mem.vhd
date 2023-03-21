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

entity dataph is
	generic (
		data_width90  : natural;
		data_width270 : natural);
	port (
		clk0   : in  std_logic := '-';
		clk270 : in  std_logic := '-';
		di90   : in  std_logic_vector(data_width90-1  downto 0) := (others => '-');
		di270  : in  std_logic_vector(data_width270-1 downto 0) := (others => '-');
		do90   : out std_logic_vector(data_width90-1  downto 0);
		do270  : out std_logic_vector(data_width270-1 downto 0));
end;

architecture inference of dataph is

	signal cntr0   : unsigned(4-1 downto 0);
	signal cntr90  : unsigned(4-1 downto 0);
	signal cntr180 : unsigned(4-1 downto 0);
	signal cntr270 : unsigned(4-1 downto 0);

	type mem90  is array (natural range <>) of std_logic_vector(di90'range);
	type mem270 is array (natural range <>) of std_logic_vector(di270'range);

	signal ram90  :  mem90(0 to 2**cntr0'length-1);
	signal ram270 : mem270(0 to 2**cntr0'length-1);
begin
	
	process (clk0)
	begin
		if rising_edge(clk0) then
			cntr0 <= unsigned(to_stdlogicvector(to_bitvector(std_logic_vector(cntr0)))) + 1;
		end if;
		if falling_edge(clk0) then
			cntr180 <= cntr270 + 1;
		end if;
	end process;

	process (clk270)
	begin
		if rising_edge(clk270) then
			cntr270 <= cntr0;
		end if;
		if falling_edge(clk270) then
			cntr90 <= cntr180;
		end if;
	end process;

	process (clk0)
	begin
		if rising_edge(clk0) then
			ram90(to_integer(cntr0))  <= di90;
			ram270(to_integer(cntr0)) <= di270;
		end if;
	end process;

	do90  <= ram90(to_integer(cntr270));
	do270 <= ram270(to_integer(cntr270));

end;
