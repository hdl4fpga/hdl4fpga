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
		err  : out std_logic;
		data : buffer std_logic);
end;

architecture def of usbphy_rx is
	signal j   : std_logic;
	signal k   : std_logic;
	signal se0 : std_logic;
begin

	j   <=     rxdp and not rxdn;
	k   <= not rxdp and     rxdn;
	se0 <= not rxdp and not rxdn;
 
	process (clk)
		type stateskj is (s_k, s_j);
		variable statekj : stateskj;
		type states is (s_idle, s_sync, s_syncj, s_data);
		variable state : states;

		variable cnt1  : natural range 0 to 7;
	begin
		if rising_edge(clk) then
			case state is
			when s_idle =>
				if k='1' then
					state := s_syncj;
				elsif j='1' then
					state := s_sync;
				end if;
				frm <= '0';
				dv  <= '0';
			when s_syncj =>
				if j='1' then
					state := s_sync;
				else
					state := s_idle;
				end if;
				frm <= '0';
				dv  <= '0';
			when s_sync =>
				if k='1' then
					case statekj is
					when s_k =>
						state := s_data;
					when others =>
					end case;
				elsif j='1' then
					case statekj is
					when s_j =>
						state := s_idle;
					when others =>
					end case;
				else
					state := s_idle;
				end if;
				frm <= '0';
				dv  <= '0';
			when s_data =>
				frm <= '1';
				stuffed_bit : if cnt1 > 5 then
					dv <= '0';
				else
					dv <= '1';
				end if;
			end case;

			case statekj is
			when s_k =>
				cnt1 := cnt1 + 1;
				if j='1' then
					cnt1    := 0;
					statekj := s_j;
				end if;
			when s_j =>
				cnt1 := cnt1 + 1;
				if k='1' then
					cnt1    := 0;
					statekj := s_k;
				end if;
			end case;

			err_l : if se0='1' then
				err <= '0';
			elsif cnt1 > 6 then
				err <= '1';
			end if;

			nrzi_l : data <= data xnor k;
		end if;

	end process;

end;