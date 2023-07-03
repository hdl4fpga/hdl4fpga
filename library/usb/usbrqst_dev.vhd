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
	signal in_rdys   : bit_requests := (others => '0');
	signal out_req   : bit;
	signal out_rdys  : bit_requests := (others => '0');

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
begin

	usbrqst_p : process (clk)
		type states is (s_rqstdata, s_ackrqstdata, s_inout, s_dataout, s_ackin, s_datain);
		variable state     : states;
		constant tbit      : std_logic_vector(data0'range) := b"1000";
		variable dpid      : std_logic_vector(data0'range);
		variable shr       : unsigned(0 to rxrqst'length);
		variable request   : std_logic_vector( 8-1 downto 0);
		variable setup_req : bit;
		variable setup_rdy : bit;
	begin
		if rising_edge(clk) then
			if cken='1' then
				if (setup_rdy xor setup_req)='1' then
					case state is
					when s_rqstdata =>
						if (rx_rdy xor rx_req)='1' then
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

								for i in request_ids'range loop
									if request(4-1 downto 0)=request_ids(i) then
										rqst_reqs(i) <= not rqst_rdys(i);
										rqst_req     <= not rqst_rdy;
										state        := s_ackrqstdata;
										exit;
									end if;
								end loop;

							when others =>
								assert false report "wrong case" severity warning;
							end case;
						end if;
					when s_ackrqstdata =>
						if (to_bit(tx_rdy) xor to_bit(tx_req))='0' then
							txpid  <= hs_ack;
							tx_req <= not to_stdulogic(to_bit(tx_rdy));
							state  := s_inout;
						end if;
					when s_inout =>
						if (rx_rdy xor rx_req)='1' then
							case rxpid is
							when tk_out =>
								out_req <= not montrdy(out_rdys);
								state   := s_datain;
							when tk_in  =>
								in_req  <= not montrdy(in_rdys);
								state   := s_dataout;
							when data0|data1 =>
							when tk_sof =>
							when others =>
								assert false report "wrong case" severity warning;
							end case;
						end if;
					when s_dataout =>
						if (in_req xor montrdy(in_rdys))='0' then
							if (to_bit(tx_rdy) xor to_bit(tx_req))='0' then
								txpid  <= dpid;
								tx_req <= not to_stdulogic(to_bit(tx_rdy));
								state  := s_ackin;
							end if;
						end if;
					when s_ackin =>
						if (rx_rdy xor rx_req)='1' then
							case rxpid is
							when hs_ack =>
								dpid  := dpid xor tbit;
								setup_rdy := setup_req;
							when data0|data1 =>
								state := s_dataout;
							when tk_sof =>
							when others =>
								setup_rdy := setup_req;
								assert false report "wrong case" severity warning;
							end case;
						end if;
					when s_datain =>
						if (rx_rdy xor rx_req)='1' then
							case rxpid is
							when data0|data1 =>
								if (to_bit(tx_rdy) xor to_bit(tx_req))='0' then
									dpid   := dpid xor tbit;
									txpid  <= hs_ack;
									tx_req <= not to_stdulogic(to_bit(tx_rdy));
								end if;
							when others =>
								setup_rdy := setup_req;
								assert false report "wrong case" severity warning;
							end case;
						end if;
					end case;
				end if;

				setup_l : if (to_bit(rx_rdy) xor to_bit(rx_req))='1' then
					if rxpid=tk_setup then
						if rxtoken(0 to addr'length-1)=(addr'range => '0') then
							setup_req := not setup_rdy;
							state     := s_rqstdata;
						elsif rxtoken(0 to addr'length-1)=reverse(addr) then
							setup_req := not setup_rdy;
							state     := s_rqstdata;
						end if;
						in_req    <= montrdy(in_rdys);
						out_req   <= montrdy(out_rdys);
						rqst_req  <= rqst_rdy;
						rqst_reqs <= rqst_rdys;
					end if;
				end if;


				rx_rdy <= to_stdulogic(to_bit(rx_req));
			end if;
			tp(13) <= to_stdulogic(setup_req);
			tp(14) <= to_stdulogic(setup_rdy);
		end if;
	end process;

	tp(1)  <= to_stdulogic(rqst_reqs(set_address));
	tp(2)  <= to_stdulogic(rqst_rdys(set_address));
	tp(3)  <= to_stdulogic(rqst_reqs(get_descriptor));
	tp(4)  <= to_stdulogic(rqst_rdys(get_descriptor));
	tp(9)  <= to_stdulogic(in_req);
	tp(10) <= to_stdulogic(montrdy(in_rdys));
	tp(11) <= to_stdulogic(out_req);
	tp(12) <= to_stdulogic(montrdy(out_rdys));

	setaddress_p : process (setaddress_rdy, clk)
		alias in_rdy is in_rdys(set_address);
	begin
		if rising_edge(clk) then
			if cken='1' then
				if (to_bit(rx_rdy) xor to_bit(rx_req))='0' then
					if (setaddress_rdy xor setaddress_req)='1' then
						if (in_req xor montrdy(in_rdys))='1' then
							addr   <= value(addr'range);
							in_rdy <= not in_rdy;
							setaddress_rdy <= setaddress_req;
						end if;
					end if;
				end if;
			end if;
		end if;
	end process;

	getdescriptor_p : process (getdescriptor_rdy, clk)
		alias in_rdy  is in_rdys(get_descriptor);
		alias out_rdy is out_rdys(get_descriptor);
	begin
		if rising_edge(clk) then
			if cken='1' then
				if (to_bit(rx_rdy) xor to_bit(rx_req))='0' then
					if (getdescriptor_rdy xor getdescriptor_req)='1' then
						if (out_req xor montrdy(out_rdys))='1' then
							out_rdy <= not out_rdy;
							getdescriptor_rdy <= getdescriptor_req;
						end if;
						if (in_req xor montrdy(in_rdys))='1' then
							in_rdy <= not in_rdy;
							getdescriptor_rdy <= getdescriptor_req;
						end if;
					end if;
				end if;
			end if;
		end if;
	end process;

	montrequests_p : process (clk)
	begin
		if rising_edge(clk) then
			if cken='1' then
				if (rqst_rdy xor rqst_req)='1' then
					l1 : for l in 0 to 0 loop
						for i in rqst_rdys'range loop
							if (rqst_rdys(i) xor rqst_reqs(i))='1' then
								exit l1;
							end if;
						end loop;
						rqst_rdy <= rqst_req;
					end loop;
				end if;
			end if;
		end if;
	end process;

end;

	-- rqst_p : process (clk)
		-- type states is (s_setup, s_rqstdata);
		-- variable state   : states;
		-- variable shr     : unsigned(0 to rxrqst'length);
		-- variable request : std_logic_vector( 8-1 downto 0);
	-- begin
		-- if rising_edge(clk) then
			-- if cken='1' then
				-- if (rqstdata_rdy xor rqstdata_req)='1' then
					-- case state is
					-- when s_data =>
						-- if (rx_rdy xor rx_req)='1' then
							-- if rxpid=data0 then
								-- shr(0 to rxrqst'length-1) := unsigned(rxrqst);
								-- requesttype <= reverse(std_logic_vector(shr(0 to requesttype'length-1)));
								-- shr     := shr rol requesttype'length;
								-- request := reverse(std_logic_vector(shr(0 to request'length-1)));
								-- shr     := shr rol request'length;
								-- value   <= reverse(std_logic_vector(shr(0 to value'length-1)));
								-- shr     := shr rol value'length;
								-- index   <= reverse(std_logic_vector(shr(0 to index'length-1)));
								-- shr     := shr rol index'length;
								-- length  <= reverse(std_logic_vector(shr(0 to length'length-1)));
								-- shr     := shr rol length'length;
								-- dpid    := rxpid;
								-- dpid    := dpid xor tbit;
	-- 
								-- for i in request_ids'range loop
									-- if request(4-1 downto 0)=request_ids(i) then
										-- rqst_reqs(i) <= not rqst_rdys(i);
										-- rqst_req     <= not rqst_rdy;
										-- ack_req      <= not ack_rdy;
										-- state        := s_ack;
										-- exit;
									-- end if;
								-- end loop;
							-- else
							-- end if;
						-- end if;
					-- end if;
				-- when s_ack =>
					-- if (ack_rdy xor ack_req)='0' then
						-- rqstdata_rdy <= rqstdata_req;
					-- end if;
				-- end case;
			-- else
				-- state := s_data;
			-- end if;
		-- end if;
	-- end process;