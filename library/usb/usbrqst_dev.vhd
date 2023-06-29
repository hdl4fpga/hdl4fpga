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

	signal in_req    : bit := '0';
	signal in_rdy    : bit := '0';
	signal in_rdys   : bit_requests := (others => '0');
	signal out_req   : bit;
	signal out_rdy   : bit_requests := (others => '0');

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

begin

	in_rdy <= montrdy(in_rdys);
	usbrqst_p : process (clk)
		type states is (s_setup, s_rqstdata, s_ackrqstdata, s_inout, s_dataout, s_ackin, s_datain);
		variable state : states := s_setup;
		constant tbit  : std_logic_vector(data0'range) := b"1000";
		variable dpid  : std_logic_vector(data0'range);
		variable shr   : unsigned(0 to rxrqst'length);
		variable request : std_logic_vector( 8-1 downto 0);
	begin
		if rising_edge(clk) then
			if cken='1' then
				case state is
				when s_setup =>
					if (to_bit(rx_rdy) xor to_bit(rx_req))='1' then
						case rxpid is
						when tk_setup =>
							if rxtoken(0 to addr'length-1)=(addr'range => '0') then
								tp(1 to 4) <= x"1";
								state := s_rqstdata;
							elsif rxtoken(0 to addr'length-1)=reverse(addr) then
								tp(1 to 4) <= x"1";
								state := s_rqstdata;
							end if;
							in_req    <= montrdy(in_rdys);
							rqst_req  <= rqst_rdy;
							rqst_reqs <= rqst_rdys;
						when others =>
							assert false report "wrong case" severity failure;
						end case;
						rx_rdy <= rx_req;
					end if;
				when s_rqstdata =>
					if (to_bit(rx_rdy) xor to_bit(rx_req))='1' then
						case rxpid is
						when data0 =>
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
							dpid    := rxpid;
							dpid    := dpid xor tbit;

							if (rqst_rdy xor rqst_req)='0' then
								for i in request_ids'range loop
									if request(request_ids(set_address)'range)=request_ids(i) then
										rqst_reqs(i) <= not rqst_rdys(i);
										rqst_req     <= not rqst_rdy;
										state        := s_ackrqstdata;
										exit;
									end if;
								end loop;
							end if;
							tp(1 to 4) <= x"2";

						when others =>
							state   := s_setup;
							assert false report "wrong case" severity failure;
						end case;
						rx_rdy  <= rx_req;
					end if;
				when s_ackrqstdata =>
  					if (to_bit(tx_rdy) xor to_bit(tx_req))='0' then
   						txpid  <= hs_ack;
						tx_req <= not to_stdulogic(to_bit(tx_rdy));
						tp(1 to 4) <= x"3";
						state  := s_inout;
					end if;
				when s_inout =>
					if (to_bit(rx_rdy) xor to_bit(rx_req))='1' then
						case rxpid is
						when tk_out =>
							out_req <= not montrdy(out_rdy);
							state   := s_datain;
							tp(1 to 4) <= x"4";
						when tk_in  =>
							in_req <= not montrdy(in_rdys);
							state  := s_dataout;
							tp(1 to 4) <= x"5";
						when others =>
							state := s_setup;
							assert false report "wrong case" severity failure;
						end case;
						rx_rdy <= rx_req;
					end if;
				when s_dataout =>
					if (in_req xor montrdy(in_rdys))='0' then
						if (to_bit(tx_rdy) xor to_bit(tx_req))='0' then
							txpid  <= dpid;
							tx_req <= not to_stdulogic(to_bit(tx_rdy));
							state  := s_ackin;
							tp(1 to 4) <= x"6";
						end if;
					end if;
				when s_ackin =>
					if (to_bit(rx_rdy) xor to_bit(rx_req))='1' then
						case rxpid is
						when hs_ack =>
							dpid   := dpid xor tbit;
							-- state  := s_setup;
							tp(1 to 4) <= x"7";
						when others =>
							-- state := s_dataout;
							tp(1 to 4) <= x"8";
							assert false report "wrong case" severity failure;
						end case;
						rx_rdy <= rx_req;
					end if;
				when s_datain =>
					if (to_bit(rx_rdy) xor to_bit(rx_req))='1' then
						case rxpid is
						when data0|data1 =>
							if (to_bit(tx_rdy) xor to_bit(tx_req))='0' then
								dpid   := dpid xor tbit;
								txpid  <= hs_ack;
								tx_req <= not to_stdulogic(to_bit(tx_rdy));
							end if;
						when others =>
							state := s_setup;
							-- state := s_freeze;
							assert false report "wrong case" severity failure;
						end case;
						rx_rdy <= rx_req;
					end if;
				end case;
			end if;
		end if;
	end process;

	-- tp(5) <= to_stdulogic(rqst_req);
	-- tp(6) <= to_stdulogic(rqst_rdy);
	tp(5) <= to_stdulogic(rqst_reqs(set_address));
	tp(6) <= to_stdulogic(rqst_rdys(set_address));
	tp(7) <= to_stdulogic(in_req);
	tp(8) <= to_stdulogic(montrdy(in_rdys));

	setaddress_p : process (clk)
	begin
		if rising_edge(clk) then
			if cken='1' then
				if (to_bit(rx_rdy) xor to_bit(rx_req))='0' then
					if (rqst_rdys(set_address) xor rqst_reqs(set_address))='1' then
						if (in_req xor montrdy(in_rdys))='1' then
							addr   <= value(addr'range);
							rqst_rdys(set_address) <= rqst_reqs(set_address);
							in_rdys(set_address) <= not in_rdys(set_address);
						end if;
					end if;
				end if;
			end if;
		end if;
	end process;

end;