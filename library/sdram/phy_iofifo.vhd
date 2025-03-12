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
use ieee.numeric_bit.all;

entity phy_iofifo is
	port (
		in_clr   : in  std_logic := '0';
		in_clk   : in  std_logic;
		in_rst   : in  std_logic := '0';
		in_irdy  : in  std_logic := '1';
		in_data  : in  std_logic_vector;

		out_clk  : in  std_logic;
		out_rst  : in  std_logic := '0';
		out_trdy : in  std_logic := '1';
		out_data : out std_logic_vector);
end;

architecture mix of phy_iofifo is

	type ram is array(natural range <>) of std_logic_vector(in_data'range);
	signal mem : ram(2**4-1 downto 0);

begin

	process (in_clr, in_clk)
		variable cntr : unsigned(4-1 downto 0);
	begin
		if in_clr='1' then
			cntr := (others => '0');
		elsif rising_edge(in_clk) then
			if in_rst='1' then
				cntr := (others => '0');
			elsif in_irdy='1' then
				mem(to_integer(cntr)) <= in_data;
				cntr := cntr + 1;
			end if;
		end if;
	end process;

	process (mem, out_clk)
		variable cntr : unsigned(4-1 downto 0);
	begin
		if rising_edge(out_clk) then
			if out_rst='1' then
				cntr := (others => '0');
			elsif out_trdy='1' then
				cntr := cntr + 1;
			end if;
		end if;
		out_data <= mem(to_integer(cntr));
	end process;

end;
