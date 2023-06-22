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

entity usbrqst_dev is
	port (
		clk     : in  std_logic;
		cken    : in  std_logic;

		rx_req  : in  std_logic;
		rx_rdy  : buffer std_logic;
		rxpid   : in  std_logic_vector(4-1 downto 0);
		rxtoken : in  std_logic_vector(0 to 7+4+5-1);
		rxrqst  : in  std_logic_vector(0 to 8*8+15-1);

		tx_req  : buffer std_logic;
		tx_rdy  : in  std_logic;
		txpid   : out std_logic_vector(4-1 downto 0));

end;

architecture def of usbrqst_dev is
	constant tdbi : std_logic_vector(data0'range) := b"1000";
	signal   dpid : std_logic_vector(data0'range);
	signal addr     : std_logic_vector( 7-1 downto 0);
	signal endp     : std_logic_vector( 4-1 downto 0);
	signal bmrequesttype : std_logic_vector( 8-1 downto 0);
	signal brequest : std_logic_vector( 8-1 downto 0);
	signal wvalue   : std_logic_vector(16-1 downto 0);
	signal windex   : std_logic_vector(16-1 downto 0);
	signal wlength  : std_logic_vector(16-1 downto 0);
begin
	usbrqst_p : process (clk)
		type states is (s_setup, s_rxdata, s_in, s_rxack);
		variable state : states;
		variable shr   : unsigned(rxrqst'range);
	begin
		if rising_edge(clk) then
			if cken='1' then
				case state is
				when s_setup =>
					if (to_bit(rx_rdy) xor to_bit(rx_req))='1' then
						shr := unsigned(rxtoken);
						addr <= std_logic_vector(shr(0 to addr'length-1));
						shr := shr rol addr'length;
						endp <= std_logic_vector(shr(0 to endp'length-1));
						shr := shr rol endp'length;

						if rxpid=tk_setup then
							rx_rdy <= rx_req;
							state  := s_rxdata;
						end if;
						rx_rdy <= rx_req;
					end if;
				when s_rxdata =>
					if (to_bit(tx_rdy) xor to_bit(tx_req))='0' then
						if (to_bit(rx_rdy) xor to_bit(rx_req))='1' then
							case rxpid is
							when data0 =>
    							bmrequesttype <= std_logic_vector(shr(0 to bmrequesttype'length-1));
								shr := shr rol bmrequesttype'length;
    							brequest <= std_logic_vector(shr(0 to brequest'length-1));
    							shr := shr rol brequest'length;
    							wvalue   <= std_logic_vector(shr(0 to wvalue'length-1));
    							shr := shr rol wvalue'length;
    							windex   <= std_logic_vector(shr(0 to windex'length-1));
    							shr := shr rol windex'length;
    							wlength  <= std_logic_vector(shr(0 to wlength'length-1));
    							shr := shr rol wlength'length;
								txpid  <= hs_ack;
								dpid   <= rxpid xor tdbi;
								tx_req <= not to_stdulogic(to_bit(tx_rdy));
								state  := s_in;
							when data1 =>
							when others =>
							end case;
							rx_rdy <= rx_req;
						end if;
					end if;
				when s_in =>
					if (to_bit(tx_rdy) xor to_bit(tx_req))='0' then
						if (to_bit(rx_rdy) xor to_bit(rx_req))='1' then
							case rxpid is
							when tk_out =>
							when tk_in  =>
								txpid  <= dpid;
								tx_req <= not to_stdulogic(to_bit(tx_rdy));
								state  := s_rxack;
							when others =>
							end case;
							rx_rdy <= rx_req;
						end if;
					end if;
				when s_rxack =>
					if (to_bit(tx_rdy) xor to_bit(tx_req))='0' then
						if (to_bit(rx_rdy) xor to_bit(rx_req))='1' then
							case rxpid is
							when hs_ack =>
								rx_rdy <= rx_req;
								state := s_setup;
							when others =>
							end case;
						end if;
					end if;
				end case;
			end if;
		end if;
	end process;

end;