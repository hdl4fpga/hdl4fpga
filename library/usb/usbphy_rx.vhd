library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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

entity usbphy_rx is
	generic (
		oversampling : natural);
	port (
		clk  : in  std_logic;
		rxd  : in  std_logic;
		rxdp : in  std_logic;
		rxdn : in  std_logic;
		rxc  : in  std_logic;
		rxdv : out std_logic;
		rxd  : buffer std_logic);
end;

architecture def of usbphy_rx is
	signal j : std_logic;
	signal k : std_logic;
begin
	j   <=     rxdp and not rxdn;
	k   <= not rxdp and     rxdn;
	se0 <= not rxdp and     rxdn;

	process (clk)
		type states is (
			s_idle, 
			s_k1, s_k1j1, s_k2j1, s_k2j2, s_k3j2, s_k3j3, s_k4j3, s_k4k5);
	begin
		if rising_edge(clk)
			case state is
			when s_idle =>
				if k = '1' then
					state := s_k1;
				end if;
			when s_k1 =>
				if j = '1' then
					state := s_k1j1;
				end if;
				state := s_idle;
			when s_k1j1 =>
				if k = '1' then
					state := s_k2j1;
				end if;
				state := s_idle;
			when s_k2j1 =>
				if j = '1' then
					state := s_k2j2;
				end if;
				state := s_idle;
			when s_k2j2 =>
				if k = '1' then
					state := s_k3j2;
				end if;
				state := s_idle;
			when s_k3j2 =>
				if j = '1' then
					state := s_k3j3;
				end if;
				state := s_idle;
			when s_k3j3 =>
				if k = '1' then
					state := s_k4j3;
				end if;
				state := s_idle;
			when s_k4j3 =>
				if k = '1' then
					state := s_k4k5;
				end if;
				state := s_idle;
			when s_k4k5 =>
			end case;
		end if;
	end process;

end;