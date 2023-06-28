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

	subtype bit_requests is bit_vector(requests'pos(requests'low) to requests'pos(requests'high));

	-- signal rqst_req  : bit;
	-- signal rqst_rdy  : bit;
	signal rqst_rdys : bit_requests;
	signal rqst_reqs : bit_requests;

	signal in_req    : bit;
	signal in_rdys    : bit_requests;
	signal out_req   : bit;
	signal out_rdy   : bit_requests;

	alias setaddress_rdy    is rqst_rdys(requests'pos(set_address));
	alias setaddress_req    is rqst_reqs(requests'pos(set_address));
	alias getdescriptor_rdy is rqst_rdys(requests'pos(get_descriptor));
	alias getdescriptor_req is rqst_reqs(requests'pos(get_descriptor));

	function montrdy (
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
		type states is (s_setup, s_rqstdata, s_inout, s_dataout, s_ackin, s_datain);
		variable state : states;
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
								tp(1 to 4) <= x"1";
							if rxtoken(0 to addr'length-1)=(addr'range => '0') then
								state := s_rqstdata;
							elsif rxtoken(0 to addr'length-1)=reverse(addr) then
								tp(1 to 4) <= x"1";
								state := s_rqstdata;
							end if;
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

        					for i in request_ids'range loop
        						if request(4-1 downto 0)=request_ids(i) then
        							rqst_reqs(requests'pos(i)) <= not rqst_rdys(requests'pos(i));
									exit;
        							-- rqst_req <= not rqst_rdy;
        						end if;
        					end loop;

        					if (to_bit(tx_rdy) xor to_bit(tx_req))='0' then
        						txpid  <= hs_ack;
        						tx_req <= not to_stdulogic(to_bit(tx_rdy));
								tp(1 to 4) <= x"2";
								state   := s_inout;
        					end if;

						when others =>
							tp(1 to 4) <= x"f";
							state   := s_setup;
							assert false report "wrong case" severity failure;
						end case;
						rx_rdy  <= rx_req;
					end if;
				when s_inout =>
					if (to_bit(rx_rdy) xor to_bit(rx_req))='1' then
						case rxpid is
						when tk_out =>
							out_req <= not montrdy(out_rdy);
							tp(1 to 4) <= x"4";
							state   := s_datain;
						when tk_in  =>
							in_req <= not montrdy(in_rdys);
							tp(1 to 4) <= x"3";
							state  := s_dataout;
						when data0|data1 =>
							if (to_bit(tx_rdy) xor to_bit(tx_req))='0' then
								txpid  <= hs_ack;
								tx_req <= not to_stdulogic(to_bit(tx_rdy));
							end if;
						when others =>
							state := s_setup;
							assert false report "wrong case" severity failure;
						end case;
						rx_rdy <= rx_req;
					end if;
				when s_dataout =>
					if (in_req xor montrdy(in_rdys))='0' then
						if (to_bit(tx_rdy) xor to_bit(tx_req))='0' then
							tp(1 to 4) <= x"5";
							txpid  <= dpid;
							tx_req <= not to_stdulogic(to_bit(tx_rdy));
							-- state  := s_ackin;
						end if;
					end if;
				when s_ackin =>
					if (to_bit(rx_rdy) xor to_bit(rx_req))='1' then
						case rxpid is
						when hs_ack =>
							dpid   := dpid xor tbit;
							rx_rdy <= rx_req;
							tp(1 to 4) <= x"6";
							state  := s_setup;
						when others =>
							state := s_setup;
							assert false report "wrong case" severity failure;
						end case;
						rx_rdy  <= rx_req;
					end if;
				when s_datain =>
					if (to_bit(rx_rdy) xor to_bit(rx_req))='1' then
						case rxpid is
						when data0|data1 =>
							if (to_bit(tx_rdy) xor to_bit(tx_req))='0' then
								dpid   := dpid xor tbit;
								txpid  <= hs_ack;
								tp(1 to 4) <= x"7";
								tx_req <= not to_stdulogic(to_bit(tx_rdy));
							end if;
						when others =>
							state := s_setup;
							assert false report "wrong case" severity failure;
						end case;
						rx_rdy <= rx_req;
					end if;
				end case;
			end if;
			tp(5) <= to_stdulogic(setaddress_req);
			tp(6) <= to_stdulogic(setaddress_rdy);
			tp(7) <= to_stdulogic(in_req);
			tp(8) <= to_stdulogic(montrdy(in_rdys));
		end if;
	end process;

	-- montrequests_p : process (clk)
		-- variable z : bit;
	-- begin
		-- if rising_edge(clk) then
			-- if cken='1' then
				-- if (rqst_rdy xor rqst_req)='1' then
					-- z := '0';
					-- for i in rqst_rdys'range loop
						--  z := z or (rqst_rdys(i) xor rqst_reqs(i));
					-- end loop;
				-- end if;
				-- if z='0' then
					-- rqst_rdy <= rqst_req;
				-- end if;
			-- end if;
		-- end if;
	-- end process;

	setaddress_p : process (clk)
		alias in_rdy is in_rdys(requests'pos(set_address));
	begin
		if rising_edge(clk) then
			if cken='1' then
				if (setaddress_rdy xor setaddress_req)='1' then
					if (montrdy(in_rdys) xor in_req)='1' then
						addr   <= value(addr'range);
						in_rdy <= not in_rdy;
						setaddress_rdy <= setaddress_req;
					end if;
    			end if;
			end if;
		end if;
	end process;

	-- getdescriptor_p : process (getdescriptor_rdy, clk)
		-- alias out_rdy is out_rdy(requests'pos(get_descriptor));
	-- begin
		-- if rising_edge(clk) then
			-- if cken='1' then
				-- if (getdescriptor_rdy xor getdescriptor_req)='1' then
					-- if (out_rdy xor out_req)='1' then
						-- out_rdy <= not out_rdy;
						-- getdescriptor_rdy <= getdescriptor_req;
					-- end if;
    			-- end if;
			-- end if;
		-- end if;
	-- end process;

end;