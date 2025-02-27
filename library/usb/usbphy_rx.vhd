-- Copyright (c) <2015> <Miguel Angel Sagreras>                                    --
--                                                                                 --
-- Permission is hereby granted, free of charge, to any person obtaining a copy of --
-- this software and associated documentation files (the "Software"), to deal in   --
-- the Software without restriction, including without limitation the rights to    --
-- use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies   --
-- of the Software, and to permit persons to whom the Software is furnished to do  --
-- so, subject to the following conditions:                                        --
--                                                                                 --
-- The above copyright notice and this permission notice shall be included in all  --
-- copies or substantial portions of the Software.                                 --
--                                                                                 --
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR i    --
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,        --
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE     --
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER          --
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,   --
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE   --
-- SOFTWARE.                                                                       --
--                                                                                 --

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

