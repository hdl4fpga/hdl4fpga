-- Copyright (c) 2015 Miguel Angel Sagreras                                       --
--                                                                                --
-- Permission is hereby granted, free of charge, to any person obtaining a copy   --
-- of this software and associated documentation files (the "Software"), to deal  --
-- in the Software without restriction, including without limitation the rights   --
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      --
-- copies of the Software, and to permit persons to whom the Software is          --
-- furnished to do so, subject to the following conditions:                       --
--                                                                                --
-- The above copyright notice and this permission notice shall be included in all --
-- copies or substantial portions of the Software.                                --
--                                                                                --
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     --
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       --
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    --
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         --
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  --
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  --
-- SOFTWARE.                                                                      --
--                                                                                --

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

		tkdata    : in  std_logic_vector(0 to 11-1) := (others => '-');
		tx_req    : in  std_logic;
		tx_rdy    : buffer std_logic;

		pkt_txpid : in  std_logic_vector(4-1 downto 0);
		pkt_txen  : in  std_logic :='0';
		pkt_txbs  : out std_logic;
		pkt_txd   : in  std_logic :='-';

		phy_txen  : out std_logic;
		phy_txbs  : in  std_logic;
		phy_txd   : out std_logic);
end;

architecture def of usbpkt_tx is
	signal data : std_logic;
begin
	process (pkt_txen, phy_txbs, pkt_txd, data, clk)
		type states is (s_idle, s_pid, s_token, s_data);
		variable state  : states;
		constant pid_length : natural := 8;
		variable shr  : unsigned(pid_length+tkdata'length-1 downto 0);
		variable cntr : natural range 0 to shr'length-1;
	begin
		if rising_edge(clk) then
			if cken='1' then
				case state is
				when s_idle =>
					shr := unsigned(not pkt_txpid) & unsigned(pkt_txpid) & unsigned(tkdata);
					case pkt_txpid is
					when tk_setup|tk_in|tk_out|tk_sof =>
						cntr := shr'length-1;
					when others =>
						cntr := pid_length-1;
					end case;
					if (to_bit(tx_req) xor to_bit(tx_rdy))='1' then
						if phy_txbs='0' then
							state := s_pid;
						end if;
					end if;
				when s_pid =>
					if cntr > 0 then
						if phy_txbs='0' then
							shr  := shr ror 1;
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
				data <= shr(0);
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
