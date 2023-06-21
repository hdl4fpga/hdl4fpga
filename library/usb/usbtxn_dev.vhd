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

entity usbtxn_dev is
	port (
		tp    : out std_logic_vector(1 to 32);
		clk   : in  std_logic;
		cken  : in  std_logic;

		tx_req : buffer std_logic;
		tx_rdy : in  std_logic;
		txpid : out std_logic_vector(4-1 downto 0);
		txen  : out std_logic;
		txbs  : in  std_logic;
		txd   : out std_logic;

		rx_req : in  std_logic;
		rx_rdy : buffer std_logic;

		rxdv  : in  std_logic;
		rxpid : in  std_logic_vector(4-1 downto 0);
		rxbs  : in  std_logic;
		rxd   : in  std_logic);

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

architecture def of usbtxn_dev is
begin

	usbreqst_p : process (clk)
		type states is (s_setup, s_rxdata, s_txack, s_in, s_txdata, s_rxack);
		variable state : states;
	begin
		if rising_edge(clk) then
			if cken='1' then
				case state is
				when s_setup =>
					if (rx_rdy xor rx_req)='1' then
						if rxpid=tk_setup then
							rx_rdy <= rx_req;
							state := s_rxdata;
						end if;
						rx_rdy <= rx_req;
					end if;
				when s_rxdata =>
					if (rx_rdy xor rx_req)='1' then
						case rxpid is
						when data0|data1 =>
							state := s_txack;
						when others =>
						end case;
						rx_rdy <= rx_req;
					end if;
				when s_txack =>
					if (tx_rdy xor tx_req)='0' then
						txpid  <= hs_ack;
						tx_req <= not tx_rdy;
						state  := s_in;
					end if;
				when s_in =>
					if (tx_rdy xor tx_req)='0' then
						if (rx_rdy xor rx_req)='1' then
							case rxpid is
							when tk_out =>
							when tk_in  =>
								tx_req <= not tx_rdy;
								state  := s_txdata;
							when others =>
							end case;
							rx_rdy <= rx_req;
						end if;
					end if;
				when s_txdata =>
					if (tx_rdy xor tx_req)='0' then
						if (rx_rdy xor rx_req)='1' then
							case rxpid is
							when data0|data1 =>
								txpid  <= data0 xor x"88";
								tx_req <= not tx_rdy;
								state  := s_txdata;
							when others =>
							end case;
							rx_rdy <= rx_req;
						end if;
					end if;
				when s_rxack =>
					if (rx_rdy xor rx_req)='1' then
						case rxpid is
						when hs_ack =>
							state := s_setup;
						when others =>
						end case;
						rx_rdy <= rx_req;
					end if;
				end case;
			end if;
		end if;
	end process;

end;