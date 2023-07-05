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
		tp      : out std_logic_vector(1 to 32) := (others => '0');
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

	signal addr      : std_logic_vector( 7-1 downto 0);
	signal requesttype : std_logic_vector( 8-1 downto 0);
	signal value     : std_logic_vector(16-1 downto 0);
	signal index     : std_logic_vector(16-1 downto 0);
	signal length    : std_logic_vector(16-1 downto 0);

	type bit_requests is array(requests) of bit;

	signal rqst_req  : bit;
	signal rqst_rdy  : bit;
	signal rqst_rdys : bit_requests := (others => '0');
	signal rqst_reqs : bit_requests := (others => '0');

	signal in_req    : bit;
	signal in_rdy    : bit;
	signal out_req   : bit;
	signal out_rdy   : bit;
	signal ack_rdy   : bit;
	signal ack_req   : bit;

	signal data_req  : bit;
	signal data_rdy  : bit;
	signal rqstdata_req : bit;
	signal rqstdata_rdy : bit;

	alias setaddress_rdy    is rqst_rdys(set_address);
	alias setaddress_req    is rqst_reqs(set_address);
	alias getdescriptor_rdy is rqst_rdys(get_descriptor);
	alias getdescriptor_req is rqst_reqs(get_descriptor);

	function montrdy (
		constant rdys : in bit_requests)
		return bit is
		variable retval : bit;
	begin
		retval := '0';
		for i in rdys'range loop
			retval := retval xor rdys(i);
		end loop;
		return retval;
	end;

	alias tp_state is tp(5 to 8);

	constant tbit : std_logic_vector(data0'range) := b"1000";
	signal ddata : std_logic_vector(data0'range);
	signal hdata : std_logic_vector(data0'range);
	alias token  is rxtoken(rxpid'range);
begin

	tp(1)  <= to_stdulogic(rqst_reqs(set_address));
	tp(2)  <= to_stdulogic(rqst_rdys(set_address));
	tp(3)  <= to_stdulogic(rqst_reqs(get_descriptor));
	tp(4)  <= to_stdulogic(rqst_rdys(get_descriptor));
	tp(9)  <= to_stdulogic(in_req);
	tp(10) <= to_stdulogic(in_rdy);
	tp(11) <= to_stdulogic(out_req);
	tp(12) <= to_stdulogic(out_rdy);

	hosttodev_p : process (clk)
		variable shr : unsigned(0 to rxrqst'length);
	begin
		if rising_edge(clk) then
			if cken='1' then
				if (rx_rdy xor rx_req)='1' then
					case rxpid is
					when tk_setup =>
						if rxtoken(0 to addr'length-1)=(addr'range => '0') then
							data_req <= not data_rdy;
						elsif rxtoken(0 to addr'length-1)=reverse(addr) then
							data_req <= not data_rdy;
						end if;
					when tk_in =>
						if (out_req xor out_rdy)='0' then
							hdata <= ddata;
							out_req <= out_rdy;
						end if;
					when tk_out=>
						hdata <= ddata;
					when data0|data1 =>
						case token is 
						when tk_setup =>
							shr(0 to rxrqst'length-1) := unsigned(rxrqst);
							requesttype <= reverse(std_logic_vector(shr(0 to requesttype'length-1)));
							shr     := shr rol requesttype'length;
							request := reverse(std_logic_vector(shr(0 to request'length-1)));
							shr     := shr rol request'length;
							value   <= reverse(std_logic_vector(shr(0 to value'length-1)));
							shr     := shr rol value'length;
							index   <= reverse(std_logic_vector(shr(0 to index'length-1)));
							shr     := shr rol index'length;
							length  <= reverse(std_logic_vector(shr(0 to length'length-1)));
							shr     := shr rol length'length;
							for i in request_ids'range loop
								if request(4-1 downto 0)=request_ids(i) then
									rqst_reqs(i) <= not rqst_rdys(i);
									rqst_req     <= not rqst_rdy;
									exit;
								end if;
							end loop;
							hdata <= data0;
						when tk_in =>
						when tk_out =>
							if (in_req xor in_rdy)='1' then
								in_req <= not in_rdy;
							end if;
						when others =>
						end case;

						ack_req <= not ack_rdy; 
					when hs_ack =>
						hdata <= hdata xor tbit;
					end case;
				else
					state := s_data;
				end if;
			end if;
		end if;
	end process;

	devtohost_p : process (clk)
		constant tbit : std_logic_vector(data0'range) := b"1000";
	begin
		if rising_edge(clk) then
			if cken='1' then
				if (to_bit(tx_rdy) xor to_bit(tx_req))='0' then
					tx_req  <= not to_stdulogic(to_bit(tx_rdy));
					if (out_rdy xor out_req)='1' then
						txpid   <= hdata;
						out_rdy <= out_req;
					end if;
					if (ack_rdy xor ack_req)='1' then
						ddata   <= hdata xor tbit;
						txpid   <= hs_ack;
						ack_rdy <= ack_req;
					end if;
				end if;
			end if;
		end if;
	end process;

	setaddress_p : process (setaddress_rdy, clk)
	begin
		if rising_edge(clk) then
			if cken='1' then
				if (to_bit(rx_rdy) xor to_bit(rx_req))='0' then
					if (setaddress_rdy xor setaddress_req)='1' then
						addr   <= value(addr'range);
						setaddress_rdy <= setaddress_req;
					end if;
				end if;
			end if;
		end if;
	end process;

	getdescriptor_p : process (getdescriptor_rdy, clk)
	begin
		if rising_edge(clk) then
			if cken='1' then
				if (to_bit(rx_rdy) xor to_bit(rx_req))='0' then
					if (getdescriptor_rdy xor getdescriptor_req)='1' then
						if (out_req xor out_rdy)='1' then
							out_req <= out_rdy;
							getdescriptor_rdy <= getdescriptor_req;
						end if;
						if (in_req xor in_rdy)='1' then
							in_req <= in_rdy;
							getdescriptor_rdy <= getdescriptor_req;
						end if;
					end if;
				end if;
			end if;
		end if;
	end process;

	tp(1)  <= to_stdulogic(rqst_reqs(set_address));
	tp(2)  <= to_stdulogic(rqst_rdys(set_address));
	tp(3)  <= to_stdulogic(rqst_reqs(get_descriptor));
	tp(4)  <= to_stdulogic(rqst_rdys(get_descriptor));
	tp(9)  <= to_stdulogic(in_req);
	tp(10) <= to_stdulogic(in_rdy);
	tp(11) <= to_stdulogic(out_req);
	tp(12) <= to_stdulogic(out_rdy);

end;