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

entity usbdevflow is
	port (
		tp      : out std_logic_vector(1 to 32) := (others => '0');
		clk     : in  std_logic;
		cken    : in  std_logic;

		rx_req  : in  std_logic;
		rx_rdy  : buffer std_logic;
		rxpid   : in  std_logic_vector(4-1 downto 0);
		rxtoken : in  std_logic_vector;
		rxrqst  : in  std_logic_vector;
		rxdv    : in  std_logic;
		rxbs    : in  std_logic;
		rxd     : in  std_logic;

		tx_req  : buffer std_logic;
		tx_rdy  : in  std_logic;
		txpid   : out std_logic_vector(4-1 downto 0);
		txen    : buffer std_logic;
		txbs    : in  std_logic;
		txd     : buffer std_logic;

		in_req    : buffer bit;
		in_rdy    : buffer bit;
		out_req   : buffer bit;
		out_rdy   : buffer bit;
	    rqst_rdys : in  bit_requests;
	    rqst_reqs : buffer bit_requests;
		rqst_txen : in std_logic);
		rqst_txd  : in std_logic);

	alias tp_state is tp(5 to 8);

	alias setaddress_rdy    is rqst_rdys(set_address);
	alias setaddress_req    is rqst_reqs(set_address);
	alias getdescriptor_rdy is rqst_rdys(get_descriptor);
	alias getdescriptor_req is rqst_reqs(get_descriptor);

end;

architecture def of usbdevflow is

	signal addr      : std_logic_vector( 7-1 downto 0);
	signal endp      : std_logic_vector( 4-1 downto 0);
	signal requesttype : std_logic_vector( 8-1 downto 0);
	signal value     : std_logic_vector(16-1 downto 0);
	signal index     : std_logic_vector(16-1 downto 0);
	signal length    : std_logic_vector(16-1 downto 0);

	signal rqst_req  : std_logic;
	signal rqst_rdy  : std_logic;

	signal ack_rdy   : bit;
	signal ack_req   : bit;

	signal data_req  : bit;
	signal data_rdy  : bit;

	function montrdy (
		constant rdys : in bit_requests)
		return bit is
		variable retval :bit;
	begin
		retval := '0';
		for i in rdys'range loop
			retval := retval xor rdys(i);
		end loop;
		return retval;
	end;


	constant tbit : std_logic_vector(data0'range) := b"1000";
	signal ddata  : std_logic_vector(data0'range);
	signal hdata  : std_logic_vector(data0'range);
	signal token  : std_logic_vector(rxpid'range);


begin

	token <= reverse(rxtoken(rxpid'reverse_range));
	hosttodev_p : process (cken, clk)
		variable request : std_logic_vector( 8-1 downto 0);
		variable shr : unsigned(0 to rxrqst'length);
		alias tk_addr is rxtoken(2*rxpid'length to 2*rxpid'length+addr'length-1);
		alias tk_endp is rxtoken(2*rxpid'length+addr'length to 2*rxpid'length+addr'length+endp'length-1);
	begin
		if rising_edge(clk) then
			if cken='1' then
				if (to_bit(rx_rdy) xor to_bit(rx_req))='1' then
					case rxpid is
					when tk_setup =>
						if tk_addr=(addr'range => '0') then
							data_req <= not data_rdy;
						elsif tk_addr=reverse(addr) then
							data_req <= not data_rdy;
						end if;
					when tk_in =>
						if (out_req xor out_rdy)='0' then
							endp    <= reverse(tk_endp);
							hdata   <= ddata;
							out_req <= not out_rdy;
						end if;
					when tk_out=>
						if (in_req xor in_rdy)='0' then
							endp   <= tk_endp;
							in_req <= not in_rdy;
						end if;
					when data0|data1 =>
						case token is 
						when tk_setup =>
							shr(0 to rxrqst'length-1) := unsigned(rxrqst);
							shr     := shr rol 2*data0'length;
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
								assert i/=request_ids'right report requests'image(i) severity error;
							end loop;
							hdata <= data0;
							ddata <= data0 xor tbit;
						when tk_in =>
						when tk_out =>
							if (in_rdy xor in_req)='1' then
								in_rdy <= in_req;
							end if;
						when others =>
						end case;

						hdata <= hdata xor tbit;
						ack_req  <= not ack_rdy; 
						data_rdy <= data_req;
					when hs_ack =>
						ddata <= ddata xor tbit;
					when others =>
					end case;
				end if;
				rx_rdy <= to_stdulogic(to_bit(rx_req));
			end if;
		end if;
	end process;

	devtohost_p : process (clk)
		constant tbit : std_logic_vector(data0'range) := b"1000";
		variable cntr : natural range 0 to 1024*8-1;
	begin
		if rising_edge(clk) then
			if cken='1' then
				if (to_bit(tx_rdy) xor to_bit(tx_req))='0' then
					if (out_rdy xor out_req)='1' then
						txpid   <= ddata;
						if (getdescriptor_rdy xor getdescriptor_req)='1' then
							txen <= '1';
							cntr := to_integer(shift_left(unsigned(length),3))-1;
						elsif (setaddress_rdy xor setaddress_req)='1' then
							txen <= '0';
							cntr := 0;
						elsif endp=b"0001" then
							txen <= '1';
							cntr := 16-1;
						else
							txen <= '0';
							cntr := 0;
						end if;
						tx_req  <= not to_stdulogic(to_bit(tx_rdy));
						out_rdy <= out_req;
					else
						txen  <= '0';
					end if;
					if (ack_rdy xor ack_req)='1' then
						txpid   <= hs_ack;
						txen    <= '0';
						tx_req  <= not to_stdulogic(to_bit(tx_rdy));
						ack_rdy <= ack_req;
					end if;
				elsif txbs='0' then
					if cntr > 0 then
						txen  <= '1';
						cntr  := cntr - 1;
					else
						txen  <= '0';
					end if;
				end if;
			end if;
		end if;
	end process;
	txd <= 
		rqst_txd when (getdescriptor_rdy xor getdescriptor_req)='1' else
		'1';

	tp(1)  <= to_stdulogic(rqst_reqs(set_address));
	tp(2)  <= to_stdulogic(rqst_rdys(set_address));
	tp(3)  <= to_stdulogic(rqst_reqs(get_descriptor));
	tp(4)  <= to_stdulogic(rqst_rdys(get_descriptor));
	tp(9)  <= to_stdulogic(in_req);
	tp(10) <= to_stdulogic(in_rdy);
	tp(11) <= to_stdulogic(out_req);
	tp(12) <= to_stdulogic(out_rdy);

	tp(13) <= txen or (rxdv and to_stdulogic(in_rdy xor in_req));
	tp(14) <= txbs when txen='1' else rxbs;
	tp(15) <= txd  when txen='1' else rxd;
end;