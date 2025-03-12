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
		bit_stuffing : natural := 6);
	port (
		clk  : in  std_logic;
		cken : in  std_logic;
		j    : in  std_logic;
		k    : in  std_logic;
		se0  : in  std_logic;
		rxdv : out std_logic;
		rxbs : buffer std_logic;
		rxd  : buffer std_logic;
		err  : out std_logic);
end;

architecture def of usbphy_rx is
begin

	process (clk)
		type stateskj is (s_k, s_j);
		variable statekj : stateskj;
		type states is (s_eop, s_synck, s_syncj, s_data);
		variable state : states;

		variable cnt1  : natural range 0 to 7;
		variable q     : std_logic;
	begin
		if rising_edge(clk) then
			if cken='1' then
				sync_l : case state is
				when s_eop  =>
					if se0='1' then
						state := s_eop;
					elsif k='1' then
						state := s_syncj;
					elsif j='1' then
						state := s_synck;
					end if;
					rxdv  <= '0';
					rxbs  <= '0';
				when s_syncj =>
					if se0='1' then
						state := s_eop;
					elsif j='1' then
						state := s_synck;
					end if;
					rxdv  <= '0';
					rxbs  <= '0';
				when s_synck =>
					if se0='1' then
						state := s_eop;
					elsif k='1' then
						case statekj is
						when s_k =>
							rxdv  <='0';
							state := s_data;
						when others =>
							rxdv  <= '0';
							rxbs  <= '0';
						end case;
					elsif j='1' then
						rxdv  <= '0';
						rxbs  <= '0';
						case statekj is
						when s_j =>
							state := s_synck;
						when others =>
						end case;
					else
						rxdv  <= '0';
						rxbs  <= '0';
						state := s_syncj;
					end if;
				when s_data =>
					stuffedbit_l : if cnt1 >= bit_stuffing then
						rxdv  <= '1';
						rxbs  <= '1';
					elsif se0='1' then
						rxdv  <= '0';
						rxbs  <= '0';
					else
						rxdv  <= '1';
						rxbs  <= '0';
					end if;
					if se0='1' then
						state := s_eop;
					end if;
				end case;

				kj_l : case statekj is
				when s_k =>
					if cnt1 < bit_stuffing then
						case state is
						when s_synck =>
							if k='1' then
								cnt1 := cnt1 + 1;
							end if;
						when s_data =>
							cnt1 := cnt1 + 1;
						when others =>
						end case;
					end if;
					if j='1' then
						cnt1    := 0;
						statekj := s_j;
					end if;
				when s_j =>
					if cnt1 < bit_stuffing then
						case state is
						when s_data =>
							cnt1 := cnt1 + 1;
						when others =>
						end case;
					end if;
					if k='1' then
						cnt1    := 0;
						statekj := s_k;
					end if;
				end case;

				-- err_l : if se0='1' then
					-- err <= '0';
				err_l : if state=s_synck then
					err <= '0';
				elsif state=s_syncj then
					err <= '0';
				elsif rxbs='1' then
					if rxd='1' then
						err <= '1';
					end if;
				elsif cnt1 > bit_stuffing then
					err <= '1';
				end if;

				nrzi_l : rxd <= q xor k;
				q := not k;
			end if;
		end if;

	end process;

end;