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
use hdl4fpga.base.all;

entity usbpkt_tx is
	port (
		clk    : in  std_logic;
		cken   : in  std_logic;

		tx_req : in  std_logic;
		tx_rdy : buffer std_logic;
		txpid  : in  std_logic_vector(4-1 downto 0);
		txen   : out std_logic;
		txbs   : in  std_logic;
		txd    : out std_logic);

	constant tk_out   : std_logic_vector := b"0001";
	constant tk_in    : std_logic_vector := b"1001";
	constant tk_setup : std_logic_vector := b"1101";
	constant tk_sof   : std_logic_vector := b"0101";

	constant data0    : std_logic_vector := b"0011";
	constant data1    : std_logic_vector := b"1011";

	constant hs_ack   : std_logic_vector := b"0010";
	constant hs_nack  : std_logic_vector := b"1010";
	constant hs_stall : std_logic_vector := b"1110";

end;

architecture def of usbpkt_tx is
begin
	process (clk)
		type states is (s_idle, s_pid, s_token, s_data);
		variable state : states;
		variable pid   : unsigned(8-1 downto 0);
		variable cntr  : natural range 0 to pid'length-1;
	begin
		if rising_edge(clk) then
			if cken='1' then
				if (to_bit(tx_req) xor to_bit(tx_rdy))='1' then
					case state is
					when s_idle =>
						cntr  := pid'length-1;
						pid(txpid'range) := unsigned(txpid);
						pid   := not pid;
						pid   := pid rol txpid'length;
						pid(txpid'range) := unsigned(txpid);
						txd   <= pid(0);
						txen  <= '1';
						state := s_pid;
					when s_pid =>
						if cntr > 0 then
							if txbs='0' then
								pid  := pid ror 1;
								txd  <= pid(0);
								cntr := cntr - 1;
							end if;
						else
							case txpid is
							when tk_setup|tk_in|tk_out|tk_sof =>
								state := s_token;
							when data0|data1 =>
								txen  <= '0';
								state := s_data;
							when hs_ack|hs_nack|hs_stall =>
								txen  <= '0';
								tx_rdy <= to_stdulogic(to_bit(tx_req));
								state := s_idle;
							when others =>
							end case;
						end if;
					when s_token =>
						tx_rdy <= to_stdulogic(to_bit(tx_req));
						state  := s_idle;
					when s_data =>
						state  := s_idle;
						tx_rdy <= to_stdulogic(to_bit(tx_req));
					end case;
				else
					txen  <= '0';
					state := s_idle;
				end if;
			end if;
		end if;
	end process;
end;