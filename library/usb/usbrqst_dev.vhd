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
		rxtoken : in  std_logic_vector;
		rxrqst  : in  std_logic_vector;

		tx_req  : buffer std_logic;
		tx_rdy  : in  std_logic;
		txpid   : out std_logic_vector(4-1 downto 0);
		txen    : out std_logic := '0';
		txbs    : in  std_logic := '0';
		txd     : out std_logic);

end;

architecture def of usbrqst_dev is
	signal addr     : std_logic_vector( 7-1 downto 0);
	signal requesttype : std_logic_vector( 8-1 downto 0);
	signal request  : std_logic_vector( 8-1 downto 0);
	signal value    : std_logic_vector(16-1 downto 0);
	signal index    : std_logic_vector(16-1 downto 0);
	signal length   : std_logic_vector(16-1 downto 0);
	signal rqst_rdy : bit;
	signal rqst_req : bit;
	signal out_req  : bit;
	signal out_rdy  : bit;
	signal in_rdy   : bit;
	signal in_req   : bit;

	subtype bit_requests is bit_vector(requests'pos(requests'low) to requests'pos(requests'high));
	signal rqst_rdys : bit_requests;
	signal rqst_reqs : bit_requests;
	signal out_reqs  : bit_requests;
	signal out_rdys  : bit_requests;
	signal in_rdys   : bit_requests;

	alias setaddress_rdy    is rqst_rdys(requests'pos(set_address));
	alias setaddress_req    is rqst_reqs(requests'pos(set_address));
	alias getdescriptor_rdy is rqst_rdys(requests'pos(get_descriptor));
	alias getdescriptor_req is rqst_reqs(requests'pos(get_descriptor));

	function montrdys (
		constant rdys : in bit_vector)
		return bit is
		variable retval : bit;
	begin
		retval := '0';
		for i in rdys'range loop
			retval := retval xor rdys(i);
		end loop;
		return retval;
	end;

begin

	usbrqst_p : process (cken, clk)
		type states is (s_setup, s_rqstdata, s_ackrqst, s_rqst, s_inout, s_dataout, s_ackin, s_datain, s_ackout);
		variable state : states;
		constant tbit  : std_logic_vector(data0'range) := b"1000";
		variable dpid  : std_logic_vector(data0'range);
		variable shr   : unsigned(0 to rxrqst'length);
	begin
		if rising_edge(clk) then
			if cken='1' then
				case state is
				when s_setup =>
					if (to_bit(rx_rdy) xor to_bit(rx_req))='1' then
						case rxpid is
						when tk_setup =>
							if rxtoken(0 to addr'length-1)=(addr'range => '0') then
								state := s_rqstdata;
							elsif rxtoken(0 to addr'length-1)=reverse(addr) then
								state := s_rqstdata;
							end if;
							rx_rdy <= rx_req;
						when data0|data1 =>
							state  := s_ackout;
							rx_rdy <= rx_req;
						when others =>
							-- assert false
							-- report "wrong case"
							-- severity failure;
						end case;
					end if;
				when s_rqstdata =>
					if (to_bit(rx_rdy) xor to_bit(rx_req))='1' then
						case rxpid is
						when data0 =>
							shr(0 to rxrqst'length-1) := unsigned(rxrqst);
							requesttype <= reverse(std_logic_vector(shr(0 to requesttype'length-1)));
							shr     := shr rol requesttype'length;
							request <= reverse(std_logic_vector(shr(0 to request'length-1)));
							shr     := shr rol request'length;
							value   <= reverse(std_logic_vector(shr(0 to value'length-1)));
							shr     := shr rol value'length;
							index   <= reverse(std_logic_vector(shr(0 to index'length-1)));
							shr     := shr rol index'length;
							length  <= reverse(std_logic_vector(shr(0 to length'length-1)));
							shr     := shr rol length'length;
							dpid    := rxpid;
							dpid    := dpid xor tbit;
							state   := s_ackrqst;
							rx_rdy <= rx_req;
						when others =>
							state   := s_setup;
							-- assert false
							-- report "wrong case"
							-- severity failure;
						end case;
					end if;
				when s_ackrqst =>
					if (to_bit(tx_rdy) xor to_bit(tx_req))='0' then
						txpid  <= hs_ack;
						tx_req <= not to_stdulogic(to_bit(tx_rdy));
					end if;
					state := s_rqst;
				when s_rqst =>
					if (tx_rdy xor tx_req)='0' then
						for i in request_ids'range loop
							if request(4-1 downto 0)=request_ids(i) then
								rqst_reqs(requests'pos(i)) <= not rqst_rdys(requests'pos(i));
								rqst_req <= not rqst_rdy;
							end if;
						end loop;
						state := s_inout;
					end if;
				when s_inout =>
					if (to_bit(rx_rdy) xor to_bit(rx_req))='1' then
						case rxpid is
						when tk_out =>
							state := s_datain;
						when tk_in  =>
							in_req  <= not in_rdy;
							state := s_dataout;
						when data0|data1 =>
							state := s_ackrqst;
						when others =>
							state := s_setup;
							-- assert false report "wrong case" severity failure;
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
							-- assert false report "wrong case" severity failure;
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
							state := s_setup;
							-- assert false report "wrong case" severity failure;
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
						state  := s_setup;
					end if;
				end case;
			end if;
		end if;
	end process;

	montrequests_p : process (clk)
		variable z : bit;
	begin
		if rising_edge(clk) then
			if cken='1' then
				if (rqst_rdy xor rqst_req)='1' then
					z := '0';
					for i in rqst_rdys'range loop
						 z := z or (rqst_rdys(i) xor rqst_reqs(i));
					end loop;
				end if;
				if z='0' then
					rqst_rdy <= rqst_req;
				end if;
			end if;
		end if;
	end process;
	in_rdy <= montrdys(in_rdys);

	setaddress_p : process (clk)
		alias in_rdy is in_rdys(requests'pos(set_address));
	begin
		if rising_edge(clk) then
			if cken='1' then
				if (setaddress_rdy xor setaddress_req)='1' then
					if (in_rdy xor in_req)='1' then
						addr <= value(addr'range);
						in_rdy <= not in_rdy;
						setaddress_rdy <= setaddress_req;
					end if;
    			end if;
			end if;
		end if;
	end process;

	getdescriptor_p : process (getdescriptor_rdy, clk)
		type states is (s_set);
		variable state : states;
		variable mem : std_logic_vector(device_descritptor'range) := device_descritptor;
	begin
		if rising_edge(clk) then
			if cken='1' then
				if (getdescriptor_rdy xor getdescriptor_req)='1' then

					getdescriptor_rdy <= getdescriptor_req;
    			end if;
			else
				state := s_set;
			end if;
		end if;
	end process;

end;