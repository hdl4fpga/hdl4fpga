--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2010-2013                                                    --
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

entity stuSync is
	port (
		clk  : in  std_ulogic;
		a    : in  std_ulogic_vector(0 to 1);
		sz   : in  std_ulogic_vector(0 to 1);
		din  : in  std_ulogic_vector(0 to 31);
		dout : out std_ulogic_vector(31 downto 0);
		memE : out std_ulogic_vector(0 to 3));
end;

architecture behavioral of stusync is

	component stu
		port (
			a     : in  std_ulogic_vector(0 to 1);
			sz    : in  std_ulogic_vector(0 to 1);
			din   : in  std_ulogic_vector(0 to 31);
			dout  : out std_ulogic_vector(31 downto 0);
			memE : out std_ulogic_vector(0 to 3));
	end component;
			
	signal aS    : std_ulogic_vector(1 downto 0);
	signal szS   : std_ulogic_vector(0 to 1);
	signal dinS  : std_ulogic_vector(0 to 31);
	signal doutS : std_ulogic_vector(31 downto 0);
	signal memES : std_ulogic_vector(3 downto 0);

begin
	dut : stu
		port map (
			a    => aS,
			sz   => szS,
			din  => dinS,
			dout => doutS,
			memE => memES);

	process (clk)
	begin
		if rising_edge(clk) then
			dinS <= din;
			aS  <= a;
			szS <= sz;
			dout <= doutS;
			memE <= memES;
		end if;
	end process;
end;