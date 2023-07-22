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

entity usbpkt_rx is
	port (
		clk      : in  std_logic;
		cken     : in  std_logic;

		rx_req   : buffer std_logic;
		rx_rdy   : in  std_logic;

		rxpidv   : in  std_logic;
		rxpid    : in  std_logic_vector( 4-1 downto 0);
		rxdv     : in  std_logic;
		rxbs     : in  std_logic;
		rxd      : in  std_logic);
end;

architecture def of usbpkt_rx is
begin
	process (clk)
		type states is (s_idle, s_token, s_data, s_hs);
		variable state : states;
	begin
		if rising_edge(clk) then
			if cken='1' then
				if (to_bit(rx_rdy) xor to_bit(rx_req))='0' then
					case state is
					when s_idle =>
						if rxpidv='1' then
   							case rxpid is
   							when tk_setup|tk_in|tk_out|tk_sof =>
								state := s_token;
   							when data0|data1 =>
   								state := s_data;
							when hs_ack|hs_nack|hs_stall =>
   								state := s_hs;
							when others =>
								-- assert false report "usbpkt_rx" severity failure;
   							end case;
						end if;
					when s_token =>
						if rxdv='0' then
							rx_req  <= not to_stdulogic(to_bit(rx_rdy));
						end if;
					when s_data =>
						if rxdv='0' then
							rx_req <= not to_stdulogic(to_bit(rx_rdy));
						end if;
					when s_hs =>
						rx_req <= not to_stdulogic(to_bit(rx_rdy));
					when others =>
							-- assert false report "usbpkt_rx" severity failure;
					end case;
				else
					state := s_idle;
				end if;
			end if;
		end if;
	end process;
end;