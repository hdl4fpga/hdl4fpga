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
use hdl4fpga.usbpkg.all;

entity usbpkt_tx is
	port (
		tp        : out std_logic_vector(1 to 32):= (others => '0');
		clk       : in  std_logic;
		cken      : in  std_logic;

		tx_req    : in  std_logic;
		tx_rdy    : buffer std_logic;

		pkt_txpid : in  std_logic_vector(4-1 downto 0);
		pkt_txen  : in  std_logic :='0';
		pkt_txbs  : out std_logic;
		pkt_txd   : in  std_logic :='-';

		phy_txen : out std_logic;
		phy_txbs : in  std_logic;
		phy_txd  : out std_logic);
end;

architecture def of usbpkt_tx is
	signal data : std_logic;
begin
	process (pkt_txen, phy_txbs, pkt_txd, data, clk)
		type states is (s_idle, s_pid, s_token, s_data);
		variable state : states;
		variable pid   : unsigned(8-1 downto 0);
		variable cntr  : natural range 0 to pid'length-1;
	begin
		if rising_edge(clk) then
			if cken='1' then
				case state is
				when s_idle =>
					pid  := unsigned(not pkt_txpid) & unsigned(pkt_txpid);
					cntr := pid'length-1;
					if (to_bit(tx_req) xor to_bit(tx_rdy))='1' then
						if phy_txbs='0' then
							state := s_pid;
						end if;
					end if;
				when s_pid =>
					if cntr > 0 then
						if phy_txbs='0' then
							pid  := pid ror 1;
							cntr := cntr - 1;
						end if;
					else
						case pkt_txpid is
						when tk_setup|tk_in|tk_out|tk_sof =>
							state := s_token;
						when data0|data1 =>
							state := s_data;
						when hs_ack|hs_nack|hs_stall =>
							if phy_txbs='0' then
							tx_rdy <= to_stdulogic(to_bit(tx_req));
								state := s_idle;
							end if;
						when others =>
						end case;
					end if;
				when s_token =>
					tx_rdy <= to_stdulogic(to_bit(tx_req));
					state  := s_idle;
				when s_data =>
					if phy_txbs='0' then
						if pkt_txen='0' then
							tx_rdy <= to_stdulogic(to_bit(tx_req));
							state  := s_idle;
						end if;
					end if;
				end case;
				data <= pid(0);
			end if;
		end if;

		comb_l : case state is
		when s_idle =>
			(phy_txen, pkt_txbs, phy_txd) <= std_logic_vector'('0', '1', data);
		when s_pid =>
			(phy_txen, pkt_txbs, phy_txd) <= std_logic_vector'('1', '1', data);
		when others =>
			(phy_txen, pkt_txbs, phy_txd) <= std_logic_vector'(pkt_txen, phy_txbs, pkt_txd);
		end case;
	end process;
end;