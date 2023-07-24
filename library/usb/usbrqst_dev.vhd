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
		config_dscptr   : std_logic_vector;
		interface_dscptr: std_logic_vector;
		endpoint_dscptr : std_logic_vector);
	port (
		tp        : out std_logic_vector(1 to 32) := (others => '0');
		clk       : in  std_logic;
		cken      : in  std_logic;

		dev_addr  : out std_logic_vector(0 to 7-1);
		dev_cfgd  : out std_logic;
		rqst_req  : buffer bit;
		rqst_rdy  : buffer bit;

		setup_req : in  bit;
		setup_rdy : buffer bit;

		rxdv      : in  std_logic := '-';
		rxbs      : in  std_logic := '-';
		rxd       : in  std_logic := '-';

		txen      : out std_logic;
		txbs      : in  std_logic;
		txd       : out std_logic);

end;

architecture def of usbrqst_dev is

	signal requesttype : std_logic_vector( 8-1 downto 0);
	signal request   : std_logic_vector( 8-1 downto 0);
	signal value     : std_logic_vector(16-1 downto 0);
	signal index     : std_logic_vector(16-1 downto 0);
	signal length    : unsigned(16-1 downto 0);

	signal rqst_rdys : bit_requests;
	signal rqst_reqs : bit_requests;

	alias setaddress_rdy    is rqst_rdys(set_address);
	alias setaddress_req    is rqst_reqs(set_address);
	alias getdescriptor_rdy is rqst_rdys(get_descriptor);
	alias getdescriptor_req is rqst_reqs(get_descriptor);
	alias setconfiguration_rdy is rqst_rdys(set_configuration);
	alias setconfiguration_req is rqst_reqs(set_configuration);

	signal descriptor_txen : std_logic;
	signal descriptor_txd  : std_logic;

begin

	setup_p : process (cken, clk)
		type states is (s_idle, s_rqst);
		variable state : states;
		variable data : unsigned(0 to 64+2*8-1);
		variable shr  : unsigned(data'range);
	begin
		if rising_edge(clk) then
			if cken='1' then
				case state is
				when s_idle =>
					if (setup_rdy xor setup_req)='1' then
						if rxdv='1'then
							state := s_rqst;
						end if;
					end if;
				when s_rqst =>
					if rxdv='0' then
						rqst_req  <= not rqst_rdy;
						setup_rdy <= setup_req;
						state     := s_idle;
					end if;
				end case;
				data_l : if (setup_rdy xor setup_req)='1' then
					if rxdv='1' then
						if rxbs='0' then
							data(0) := rxd;
							data := data rol 1;
						end if;
					end if;
					shr := data;
					requesttype <= reverse(std_logic_vector(shr(0 to requesttype'length-1)));
					shr := shr rol requesttype'length;
					request <= reverse(std_logic_vector(shr(0 to request'length-1)));
					shr := shr rol request'length;
					value   <= reverse(std_logic_vector(shr(0 to value'length-1)));
					shr := shr rol value'length;
					index   <= reverse(std_logic_vector(shr(0 to index'length-1)));
					shr := shr rol index'length;
					length  <= unsigned(reverse(std_logic_vector(shr(0 to length'length-1))));
					shr := shr rol length'length;
				end if;
			end if;
		end if;
	end process;

	request_p : process (rqst_req, clk)
		type states is (s_idle, s_rqst);
		variable state : states;
	begin
		if rising_edge(clk) then
			if cken='1' then
				case state is
				when s_idle =>
					if (rqst_rdy xor rqst_req)='1' then
						for i in request_ids'range loop
							if request(4-1 downto 0)=request_ids(i) then
								rqst_reqs(i) <= not rqst_rdys(i);
								state := s_rqst;
								exit;
							end if;
							assert i/=request_ids'right report requests'image(i) severity error;
						end loop;
					end if;
				when s_rqst =>
					for i in request_ids'range loop
						if (rqst_rdys(i) xor rqst_reqs(i))='1' then
							exit;
						end if;
						if i=request_ids'right then
							rqst_rdy <= rqst_req;
							state := s_idle;
						end if;
					end loop;
				end case;
			end if;
		end if;
	end process;

	setaddress_p : process (setaddress_rdy, clk)
	begin
		if rising_edge(clk) then
			if cken='1' then
				if (setaddress_rdy xor setaddress_req)='1' then
					dev_addr <= value(dev_addr'range);
					setaddress_rdy <= setaddress_req;
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
		variable descriptor_length : unsigned(0 to unsigned_num_bits(max(descriptor_lengths)-1));
		variable descriptor_addr   : natural range 0 to summation(descriptor_lengths)-1;
		alias txdis is descriptor_length(0);

		alias descriptor is value(16-1 downto 8);
	begin
		if rising_edge(clk) then
			if cken='1' then
				if (getdescriptor_rdy xor getdescriptor_req)='1' then
					case state is
					when s_idle => 
						descriptor_addr := 0;
						for i in descriptor_lengths'range loop
							if (i+1)=unsigned(descriptor) then
								state := s_data;
								exit;
							end if;
							descriptor_addr := descriptor_addr + descriptor_lengths(i);
						end loop;
						descriptor_length := shift_left(resize(length, descriptor_length'length),3)-1;
					when s_data =>
						if descriptor_length(0)='0' then
							if txbs='0' then
								descriptor_addr   := descriptor_addr   + 1;
								descriptor_length := descriptor_length - 1;
							end if;
						else
							getdescriptor_rdy <= getdescriptor_req;
							state := s_idle;
						end if;
					end case;
				else
					descriptor_length := (others=> '1');
					state := s_idle;
				end if;
			end if;
		end if;
		descriptor_txen <= not txdis;
		descriptor_txd  <= descriptor_data(descriptor_addr);
	end process;

	setconfiguration_p : process (setconfiguration_rdy, clk)
	begin
		if rising_edge(clk) then
			if cken='1' then
				if (setaddress_rdy xor setaddress_req)='1' then
					dev_cfgd <= '0';
				elsif (setconfiguration_rdy xor setconfiguration_req)='1' then
					dev_cfgd <= '1';
					setconfiguration_rdy <= setconfiguration_req;
				end if;
			end if;
		end if;
	end process;

	(txen, txd) <= 
		std_logic_vector'(descriptor_txen, descriptor_txd) when request(4-1 downto 0)=request_ids(get_descriptor) else
		std_logic_vector'('0', '-');

	tp(1)  <= to_stdulogic(rqst_reqs(set_address));
	tp(2)  <= to_stdulogic(rqst_rdys(set_address));
	tp(3)  <= to_stdulogic(rqst_reqs(get_descriptor));
	tp(4)  <= to_stdulogic(rqst_rdys(get_descriptor));

end;