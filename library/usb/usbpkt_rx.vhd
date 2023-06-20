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

		rx_req : out std_logic;
		rx_rdy : in std_logic;

		rxdv   : in  std_logic;
		rxpid  : in  std_logic_vector(8-1 downto 0);
		rxbs   : in  std_logic;
		rxd    : in  std_logic);

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

	process (clk)
		type states is (s_idle, s_token, s_data);
		variable state : states;
	begin
		if rising_edge(clk) then
			if cken='1' then
				if (rx_rdy xor rx_req)='0' then
    				case state is
    				when s_idle =>
    					if rxdv='1' then
    						if rxbs='0' then
    							case rxpid(4-1 downto 0) is
    							when tk_setup|tk_in|tk_out|tk_sof =>
    								token := token rol 1;
    								token(0) := rxd;
    								state := s_token;
    							when others =>
    								if rxpid=data_pid then
    									state := s_data;
    								end if;
    							end case;
    						end if;
    					end if;
    				when s_token =>
    					if rxdv='1' then
    						if rxbs='0' then
    							token := token rol 1;
    							token(0) := rxd;
    						end if;
    					else
    						case rxpid(4-1 downto 0) is
    						when tk_setup =>
    							setup_req <= not setup_rdy;
    						when others =>
    							if rxpid=data_pid then
    								state := s_data;
    							end if;
    						end case;
    						state := s_idle;
    					end if;
    				when s_data =>
    				when others =>
    					rx_req <= not rx_rdy;
    				end case;
				else
					state := s_idle;
				end if;
			end if;
		end if;
	end process;

end;