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

library hdl4fpga;
use hdl4fpga.base.all;

entity usbphy_rx is
	generic (
		oversampling : natural);
	port (
		rxc  : in  std_logic;
		rxdp : in  std_logic;
		rxdn : in  std_logic;
		frm  : out std_logic;
		dv   : out std_logic;
		err  : out std_logic;
		data : out std_logic);
end;

architecture def of usbphy_rx is
	signal j   : std_logic;
	signal k   : std_logic;
	signal se0 : std_logic;
	signal ena : std_logic;
	signal rx_stuffedbit : std_logic;
begin

	process (rxc)
		variable cntr  : natural range 0 to oversampling-1;
		variable q     : std_logic;
		variable k_d   : std_logic;
		variable j_d   : std_logic;
		variable se0_d : std_logic;
	begin
		if rising_edge(rxc) then
			k_d   := not rxdp and     rxdn;
			j_d   :=     rxdp and not rxdn;
			se0_d := not rxdp and not rxdn;
			if (to_bit(q) xor to_bit(k_d))='1' then
				cntr := oversampling-1;
			elsif cntr=0 then
				cntr := oversampling-1;
			else
				cntr := cntr - 1;
			end if;
			if cntr=oversampling-2 then
				ena <= '1';
			else
				ena <= '0';
			end if;
			q   := k_d;
			k   <= k_d;
			j   <= j_d;
			se0 <= se0_d;
		end if;
	end process;

	assert false
	report cr & "oversampling/2 => " & natural'image(oversampling/2)
	severity note;

	process (k, j, rxc)
		type stateskj is (s_k, s_j);
		variable statekj : stateskj;
		type states is (s_idle, s_synck, s_syncj, s_data);
		variable state : states;

		variable cnt1  : natural range 0 to 7;
		variable q     : std_logic;
	begin
		if rising_edge(rxc) then
			rx_stuffedbit <= '0';
			if ena='1' then
				sync_l : case state is
				when s_idle =>
					if se0='1' then
						state := s_idle;
					elsif k='1' then
						state := s_syncj;
					elsif j='1' then
						state := s_synck;
					end if;
					frm <= '0';
					dv  <= '0';
				when s_syncj =>
					if se0='1' then
					elsif j='1' then
						state := s_synck;
					else
						state := s_idle;
					end if;
					frm <= '0';
					dv  <= '0';
				when s_synck =>
					if se0='1' then
						state := s_idle;
					elsif k='1' then
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
						rx_stuffedbit <= '1';
						dv <= '0';
					elsif se0='1' then
						dv <= '0';
					else
						dv <= '1';
					end if;
					if se0='1' then
						state := s_idle;
					end if;
				end case;

				kj_l : case statekj is
				when s_k =>
					if cnt1 < 6 then
						cnt1 := cnt1 + 1;
					end if;
					if j='1' then
						cnt1    := 0;
						statekj := s_j;
					end if;
				when s_j =>
					if cnt1 < 6 then
						cnt1 := cnt1 + 1;
					end if;
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

				nrzi_l : data <= q xor k;
				q := not k;
			else
				dv <= '0';
			end if;
		end if;

	end process;

end;