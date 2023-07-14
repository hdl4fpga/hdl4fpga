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
	 generic (
		device_dscptr   : std_logic_vector;
		config_dscptr : std_logic_vector;
		interface_dscptr: std_logic_vector;
		endpoint_dscptr : std_logic_vector);
	port (
		tp      : out std_logic_vector(1 to 32) := (others => '0');
		clk     : in  std_logic;
		cken    : in  std_logic;

	    rqst_rdys : buffer  bit_requests;
	    rqst_reqs : in  bit_requests;
		rqst_txd  : out std_logic;

		rx_req  : in  std_logic;
		rx_rdy  : buffer std_logic;
		rxpid   : in  std_logic_vector(4-1 downto 0);
		rxtoken : in  std_logic_vector;
		rxrqst  : in  std_logic_vector;

		tx_req  : buffer std_logic;
		tx_rdy  : in  std_logic;
		txen    : buffer std_logic;
		txbs    : in  std_logic);
end;

architecture def of usbrqst_dev is

	signal addr      : std_logic_vector( 7-1 downto 0);
	signal endp      : std_logic_vector( 4-1 downto 0);
	signal requesttype : std_logic_vector( 8-1 downto 0);
	signal value     : std_logic_vector(16-1 downto 0);
	signal index     : std_logic_vector(16-1 downto 0);
	signal length    : std_logic_vector(16-1 downto 0);

	signal rqst_req  : bit;
	signal rqst_rdy  : bit;

	signal in_req    : bit;
	signal in_rdy    : bit;
	signal out_req   : bit;
	signal out_rdy   : bit;
	signal ack_rdy   : bit;
	signal ack_req   : bit;

	signal data_req  : bit;
	signal data_rdy  : bit;

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

	signal descriptor_txd : std_logic;

begin

	setaddress_p : process (setaddress_rdy, clk)
	begin
		if rising_edge(clk) then
			if cken='1' then
				if (setaddress_rdy xor setaddress_req)='1' then
					if (to_bit(rx_rdy) xor to_bit(rx_req))='0' then
						if (in_rdy xor in_req)='1' then
							addr   <= value(addr'range);
							setaddress_rdy <= setaddress_req;
						end if;
					end if;
				end if;
			end if;
		end if;
	end process;

	getdescriptor_p : process (getdescriptor_rdy, clk)
		type states is (s_idle, s_data);
		variable state : states;
		constant descriptor_data : std_logic_vector := (
			device_dscptr     &
			config_dscptr     &
			interface_dscptr  &
			endpoint_dscptr);

		constant descriptor_lengths : natural_vector := (
			device_dscptr'length,
			config_dscptr'length,
			interface_dscptr'length,
			endpoint_dscptr'length);
		variable descriptor_length : natural range 0 to max(descriptor_lengths);
		variable descriptor_addr   : natural range 0 to summation(descriptor_lengths)-1;

		alias descriptor is value(16-1 downto 8);
	begin
		if rising_edge(clk) then
			if cken='1' then
				if (getdescriptor_rdy xor getdescriptor_req)='1' then
					case state is
					when s_idle => 
						if (out_rdy xor out_req)='1' then
							descriptor_addr := 0;
							for i in descriptor_lengths'range loop
								if (i+1)=unsigned(descriptor) then
									descriptor_length := descriptor_lengths(i);
									state := s_data;
									exit;
								end if;
								descriptor_addr := descriptor_addr + descriptor_lengths(i);
							end loop;
						end if;
					when s_data =>
						if txen='1' then
							if txbs='0' then
								descriptor_addr := descriptor_addr + 1;
							end if;
						else
							getdescriptor_rdy <= getdescriptor_req;
							state := s_idle;
						end if;
					end case;
				else
					state := s_idle;
				end if;
			end if;
		end if;
		descriptor_txd <= descriptor_data(descriptor_addr);
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