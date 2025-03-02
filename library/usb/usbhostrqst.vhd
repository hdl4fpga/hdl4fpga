-- Copyright (c) 2015 Miguel Angel Sagreras                                       --
--                                                                                --
-- Permission is hereby granted, free of charge, to any person obtaining a copy   --
-- of this software and associated documentation files (the "Software"), to deal  --
-- in the Software without restriction, including without limitation the rights   --
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      --
-- copies of the Software, and to permit persons to whom the Software is          --
-- furnished to do so, subject to the following conditions:                       --
--                                                                                --
-- The above copyright notice and this permission notice shall be included in all --
-- copies or substantial portions of the Software.                                --
--                                                                                --
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     --
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       --
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    --
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         --
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  --
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  --
-- SOFTWARE.                                                                      --
--                                                                                --

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.usbpkg.all;

entity usbhostrqst is
	port (
		tp        : out std_logic_vector(1 to 32) := (others => '0');
		clk       : in  std_logic;
		cken      : in  std_logic;

		setup_req : in  std_logic;
		setup_rdy : buffer std_logic;
		tksetup_req : buffer bit;
		tksetup_rdy : in  bit;
		tkin_req  : buffer bit;
		tkin_rdy  : in  bit;
		dev_addr  : out std_logic_vector(0 to 7-1);
		dev_cfgd  : out std_logic;
		rqst_req  : in  bit;
		rqst_rdy  : buffer bit;

		rxpidv    : in  std_logic := '-';
		rxpid     : in  std_logic_vector(4-1 downto 0) := (others => '0');
		rxbs      : in  std_logic := '-';
		rxd       : in  std_logic := '-';

		in_req    : buffer  bit;
		in_rdy    : in  bit;
		ack_req   : in  bit;
		ack_rdy   : buffer  bit;
		phyerr    : in  std_logic;
		tkerr     : in  std_logic;
		crcerr    : in  std_logic;
		txen      : out std_logic;
		txbs      : in  std_logic;
		txd       : out std_logic);

end;

architecture def of usbhostrqst is

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
	signal rqstdata_req    : bit;
	signal rqstdata_rdy    : bit;
	signal reply_rdy       : bit;
	signal reply_req       : bit;

begin

	setup_p : process (cken, clk)
		type states is (s_idle, s_rqstsetup);
		variable state : states;
	begin
		if rising_edge(clk) then
			if cken='1' then
   				case state is
   				when s_idle =>
					if (setup_rdy xor setup_req)='1' then
						tksetup_req <= not tksetup_rdy;
						state := s_rqstsetup;
					end if;
   				when s_rqstsetup =>
					if (tksetup_req xor tksetup_rdy)='0' then
						if (rqst_rdy xor rqst_req)='0' then
							setup_rdy <= setup_req;
							state := s_idle;
						end if;
					end if;
				end case;
			end if;
		end if;
	end process;

	rqstsetup_p : process (cken, clk)
		type states is (s_idle, s_data, s_reply);
		variable state : states;
	begin
		if rising_edge(clk) then
			if cken='1' then
				if (rqst_rdy xor rqst_req)='1' then
					case state is
					when s_idle =>
						rqstdata_req <= not rqstdata_rdy;
						state := s_data;
					when s_data =>
						if rxpidv='0' then
							if (rqstdata_req xor rqstdata_rdy)='0' then
								reply_req <= not reply_rdy;
								state := s_reply;
							end if;
						end if;
					when s_reply =>
								rqst_rdy <= rqst_req;
						if (reply_rdy xor reply_req)='0' then
							rqst_rdy <= rqst_req;
						end if;
					end case;
				else
					state := s_idle;
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
				if (rqst_req xor rqst_rdy)='1' then
					case state is
					when s_idle =>
						if (rqstdata_rdy xor rqstdata_req)='1' then
							-- for i in request_ids'range loop
								-- if request(4-1 downto 0)=request_ids(i) then
									-- rqst_reqs(i) <= not rqst_rdys(i);
									-- state := s_rqst;
									-- exit;
								-- end if;
								-- if i=request_ids'right then
									-- rqstdata_rdy <= rqstdata_req;
								-- end if;
								-- assert i/=request_ids'right 
									-- report requests'image(i) 
									-- severity error;
							-- end loop;
							getdescriptor_req <= not getdescriptor_rdy;
							state := s_rqst;
						end if;
					when s_rqst =>
						-- for i in request_ids'range loop
							-- if (rqst_rdys(i) xor rqst_reqs(i))='1' then
								-- exit;
							-- end if;
							-- if i=request_ids'right then
								-- rqstdata_rdy <= rqstdata_req;
								-- state := s_idle;
							-- end if;
						-- end loop;
						if (getdescriptor_rdy xor getdescriptor_req)='0' then
							rqstdata_rdy <= rqstdata_req;
							state := s_idle;
						end if;
					end case;
				else
					state := s_idle;
				end if;
			end if;
		end if;
	end process;

	getdescriptor_p : process (clk)
		type states is (s_idle, s_data);
		variable state : states;
		constant descriptor_data   : std_logic_vector := reverse(x"8006000200004000",8);
		variable descriptor_addr   : natural range 0 to descriptor_data'length-1;
		variable descriptor_length : integer range -1 to descriptor_data'length-1;
	begin
		if rising_edge(clk) then
			if cken='1' then
				if (getdescriptor_rdy xor getdescriptor_req)='1' then
					case state is
					when s_idle => 
						descriptor_addr   := 0;
						descriptor_length := descriptor_data'length-1;
						state := s_data;
					when s_data =>
						if descriptor_length >= 0 then
							if txbs='0' then
								descriptor_addr   := descriptor_addr   + 1;
								descriptor_length := descriptor_length - 1;
							end if;
						elsif (in_rdy xor in_req)='1' then
							state := s_idle;
						elsif (ack_rdy xor ack_req)='1' then
							getdescriptor_rdy <= getdescriptor_req;
							state := s_idle;
						end if;
						ack_rdy <= ack_req;
					end case;
				else
					descriptor_length := -1;
					state := s_idle;
				end if;
			end if;
		end if;
		descriptor_txen <= setif(descriptor_length >= 0, '1', '0');
		descriptor_txd  <= descriptor_data(descriptor_addr);
	end process;

	(txen, txd) <= 
		std_logic_vector'(descriptor_txen, descriptor_txd) when request(4-1 downto 0)=request_ids(get_descriptor) else
		std_logic_vector'('0', '-');

	tp(1) <= to_stdulogic(rqst_reqs(set_address));
	tp(2) <= to_stdulogic(rqst_rdys(set_address));
	tp(3) <= to_stdulogic(rqst_reqs(get_descriptor));
	tp(4) <= to_stdulogic(rqst_rdys(get_descriptor));
end;
