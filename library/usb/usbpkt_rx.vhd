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
		clk    : in  std_logic;
		cken   : in  std_logic;

		rx_req : buffer std_logic;
		rx_rdy : in  std_logic;

		tkdata : out std_logic_vector(0 to 11-1);
		rxpidv : in  std_logic;
		rxdv   : in  std_logic;
		rxpid  : in  std_logic_vector(4-1 downto 0);
		rxbs   : in  std_logic;
		rxd    : in  std_logic;
		phyerr : in  std_logic;
		tkerr  : in  std_logic;
		crcerr : in  std_logic);
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
							if (phyerr or tkerr)='0' then
    							if    unsigned(rxpid(2-1 downto 0))=resize(unsigned(tk_out),2) then
									state := s_token;
    							elsif unsigned(rxpid(2-1 downto 0))=resize(unsigned(data0), 2) then
									state := s_data;
    							elsif unsigned(rxpid(2-1 downto 0))=resize(unsigned(hs_ack),2) then
									state := s_hs;
    							else
    								-- assert false report "usbpkt_rx" severity failure;
    							end if;
							end if;
						end if;
					when s_token|s_data =>
						if rxdv='0' then
							if (phyerr or crcerr)='0' then
								if rxpid(4-1 downto 0)/=tk_sof then
									rx_req  <= not to_stdulogic(to_bit(rx_rdy));
								else
									state := s_idle;
								end if;
							else
								state := s_idle;
							end if;
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

	tkdata_p : process (cken, clk)
		type states is (s_idle, s_token);
		variable state : states;
		variable data : unsigned(0 to 16-1);
	begin
		if rising_edge(clk) then
			if cken='1' then
				if (phyerr or tkerr)='0' then
					if rxdv='1' then
						if unsigned(rxpid(2-1 downto 0))=resize(unsigned(tk_out),2) then
							if rxbs='0' then
								data(0) := rxd;
								data    := data rol 1;
							end if;
						end if;
					elsif crcerr='0' then
						if rxpid(4-1 downto 0)/=tk_sof then
							tkdata <= std_logic_vector(data(tkdata'range));
						end if;
					end if;
				end if;
			end if;
		end if;
	end process;

end;