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
		rxdp : in  std_logic;
		rxdn : in  std_logic;
		frm  : out std_logic;
		dv   : out std_logic;
		data : buffer std_logic);
end;

architecture def of usbphy_rx is

	signal j   : std_logic;
	signal k   : std_logic;

begin
	j   <=     rxdp and not rxdn;
	k   <= not rxdp and     rxdn;
	se0 <= not rxdp and not rxdn;
 
	process (clk)
		type states (s_idle, s_k, s_j, s_datak, s_dataj, s_data);
		variable state : states;
		variable cnt1  : natural range 0 to 7;
	begin
		if rising_edge(clk)
			case state is
			when s_idle  =>
				if k='1' then
					state := s_k;
				elsif j=1 then
					state := s_j;
				end if;
				cnt1 := 0;
				dv   <= '0';
			when s_k     =>
				if k='1' then
					cnt1  := cnt1 + 1;
					state := s_datak;
				elsif j='1' then
					cnt1  := 0;
					state := s_j;
				end if;
				dv <= '0';
			when s_j     =>
				if k='1' then
					state := s_k;
				end if;
				cnt1 := 0;
				dv   <= '0';
			when s_datak =>
				if j='1' then
					cnt1  := cnt1 + 1;
					state := s_dataj;
				else
					cnt1  := 0;
				end if;
				dv <= '1';
			when s_dataj =>
				if k=1 then
					cnt1  := cnt1 + 1;
					state := s_datak;
				else
					cnt1  := 0;
				end if;
				dv <= '1';
			end case;

			stuffed_bit : if cnt1 > 6 then
				cnt1 := '0';
				dv   <= '0';
			end if;

			nrzi : data <= data xnor k;
		end if;

	end process;

end;