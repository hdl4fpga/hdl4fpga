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
	signal   addr    : std_logic_vector( 7-1 downto 0);
	signal   endp    : std_logic_vector( 4-1 downto 0);
	signal   requesttype : std_logic_vector( 8-1 downto 0);
	signal   request : std_logic_vector( 8-1 downto 0);
	signal   value   : std_logic_vector(16-1 downto 0);
	signal   index   : std_logic_vector(16-1 downto 0);
	signal   length  : std_logic_vector(16-1 downto 0);
begin
	usbrqst_p : process (clk)
		type states is (s_setup, s_rqstdata, s_ackrqst, s_inout, s_dataout, s_ackin, s_datain, s_ackout);
		variable state : states;
		constant tbit  : std_logic_vector(data0'range) := b"1000";
		variable dpid  : std_logic_vector(data0'range);
		variable shr   : unsigned(rxrqst'range);
		variable setup_req : std_logic;
		variable setup_rdy : std_logic;
	begin
		if rising_edge(clk) then
			if cken='1' then
				case state is
				when s_setup =>
					if (to_bit(rx_rdy) xor to_bit(rx_req))='1' then
						case rxpid is
						when tk_setup =>
							shr(rxtoken'range) := unsigned(rxtoken);
							addr <= std_logic_vector(shr(0 to addr'length-1));
							shr := shr rol addr'length;
							endp <= std_logic_vector(shr(0 to endp'length-1));
							shr := shr rol endp'length;
							rx_rdy <= rx_req;
							state  := s_rqstdata;
						when data0|data1 =>
							state := s_ackout;
						when others =>
							assert false
							report "wrong case"
							severity failure;
						end case;
						rx_rdy <= rx_req;
					end if;
				when s_rqstdata =>
					if (to_bit(rx_rdy) xor to_bit(rx_req))='1' then
						case rxpid is
						when data0 =>
							requesttype <= std_logic_vector(shr(0 to requesttype'length-1));
							shr := shr rol requesttype'length;
							request <= std_logic_vector(shr(0 to request'length-1));
							shr := shr rol request'length;
							value   <= std_logic_vector(shr(0 to value'length-1));
							shr := shr rol value'length;
							index   <= std_logic_vector(shr(0 to index'length-1));
							shr := shr rol index'length;
							length  <= std_logic_vector(shr(0 to length'length-1));
							shr := shr rol length'length;
							dpid   := rxpid;
							dpid   := dpid xor tbit;
							state  := s_ackrqst;
						when others =>
							assert false
							report "wrong case"
							severity failure;
						end case;
						rx_rdy <= rx_req;
					end if;
				when s_ackrqst =>
					if (to_bit(tx_rdy) xor to_bit(tx_req))='0' then
						txpid  <= hs_ack;
						tx_req <= not to_stdulogic(to_bit(tx_rdy));
						state := s_inout;
					end if;
				when s_inout =>
					if (to_bit(rx_rdy) xor to_bit(rx_req))='1' then
						case rxpid is
						when tk_out =>
							state := s_datain;
						when tk_in  =>
							state := s_dataout;
						when data0|data1 =>
							state := s_ackrqst;
						when others =>
							assert false
							report "wrong case"
							severity failure;
						end case;
					end if;
				when s_dataout =>
					if (to_bit(tx_rdy) xor to_bit(tx_req))='0' then
						case rxpid is
						when tk_in  =>
							txpid  <= dpid;
							dpid   := dpid xor tbit;
							tx_req <= not to_stdulogic(to_bit(tx_rdy));
							state  := s_ackin;
						when others =>
							assert false
							report "wrong case"
							severity failure;
						end case;
						rx_rdy <= rx_req;
					end if;
				when s_ackin =>
					if (to_bit(rx_rdy) xor to_bit(rx_req))='1' then
						case rxpid is
						when hs_ack =>
							rx_rdy <= rx_req;
							state := s_setup;
						when others =>
							assert false
							report "wrong case"
							severity failure;
						end case;
					end if;
				when s_datain =>
					if (to_bit(tx_rdy) xor to_bit(tx_req))='0' then
						txpid  <= dpid;
						dpid   := dpid xor tbit;
						tx_req <= not to_stdulogic(to_bit(tx_rdy));
						state  := s_ackout;
					end if;
				when s_ackout =>
					if (to_bit(tx_rdy) xor to_bit(tx_req))='0' then
						txpid  <= hs_ack;
						tx_req <= not to_stdulogic(to_bit(tx_rdy));
						state := s_setup;
					end if;
				end case;
			end if;
		end if;
	end process;

end;