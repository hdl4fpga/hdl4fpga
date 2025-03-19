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
use hdl4fpga.hdo.all;
use hdl4fpga.base.all;
use hdl4fpga.usbpkg.all;

entity usbhostrqst is
	port (
		tp        : out std_logic_vector(1 to 32) := (others => '0');
		clk       : in  std_logic;
		cken      : in  std_logic;

		setup_req : in  std_logic;
		setup_rdy : buffer std_logic := '0';
		flush_req : buffer  std_logic := '0';
		flush_rdy : in std_logic := '0';

		dev_addr  : out std_logic_vector(7-1 downto 0);
		dev_endp  : out std_logic_vector(11-1 downto 7);
		dev_ackrx   : in  std_logic := '1';
		dev_acktx   : in  std_logic := '1';
		tksetup_req : buffer std_logic := '0';
		tksetup_rdy : in  std_logic := '0';
		tkin_req  : buffer std_logic := '0';
		tkin_rdy  : in  std_logic;
		tkout_req  : buffer std_logic := '0';
		tkout_rdy  : in  std_logic;
		sof_tick  : in  std_logic;

		rxdv      : in  std_logic := '-';
		rxbs      : in  std_logic := '-';
		rxd       : in  std_logic := '-';

		txen      : out std_logic;
		txbs      : in  std_logic;
		txd       : out std_logic);

end;

architecture def of usbhostrqst is
	constant test   : string := segment_map(
		"["&
			-- "{content:0x" & -- Hexadecimal format
				-- "80"      & -- Device to Host
				-- "06"      & -- GET_DESCRIPTOR
				-- "00"      & -- Descriptor index 
				-- "01"      & -- Descriptor type -> DEVICE
				-- "0000"    & -- Offset 
				-- "4000"    & -- Length 64 bytes
			-- "},"          & 
			"{content:0x" & -- Hexadecimal format
				"00"      & -- Host to Device
				"05"      & -- SET_ADDRESS
				"0a00"    & -- Address
				"0000"    & -- Offset 
				"4000"    & -- Length 64 bytes
			"}"           & 
		"]");

	constant test1  : string := hdo(test)**".table";
	constant table  : string := segment_table(test1);
	constant bitrom : string := hdo(table)**".content";
	signal segment_id        : std_logic_vector(0 to hdo(table)**".address"-1) := (others => '0');
	signal segment_data      : std_logic_vector(0 to hdo(table)**".data"-1);
	signal segment_dir       : std_logic_vector(natural'(hdo(table)**".dir.left")    to natural'(hdo(table)**".dir.right"));
	signal segment_offset    : std_logic_vector(natural'(hdo(table)**".offset.left") to natural'(hdo(table)**".offset.right"));
	signal segment_length    : std_logic_vector(natural'(hdo(table)**".length.left") to natural'(hdo(table)**".length.right"));
	signal descriptor_length : unsigned(0 to segment_length'length);
	signal descriptor_addr   : unsigned(segment_offset'range);
	signal descriptor_data   : std_logic_vector(0 to 0);
	alias txdis is descriptor_length(descriptor_length'left);

	signal send_req   : bit;
	signal send_rdy   : bit;
	signal descriptor_req : bit;
	signal descriptor_rdy : bit;
	constant descriptors : string := 
		"{"                            &
			"device:{"                 &
				"bLength:1,"           &
				"bDescriptorType:1,"   &
				"bcdUSB:2,"            &
				"bDeviceClass:1,"      &
				"bDeviceSubClass:1,"   &
				"bDeviceProtocol:1,"   &
				"bMaxPacketSize0:1,"   &
				"idVendor:2,"          &
				"idProduct:2,"         &
				"bcdDevice:2,"         &
				"idProduct:2,"         &
				"iManufacturer:1,"     &
				"iProduct:1,"          &
				"iSerialNumber:1,"     &
				"bNumConfigurations:1" &
			"}"                        &
		"}";

	signal device_req : bit;
	signal device_rdy : bit;
				
begin

	setup_p : process (cken, clk)
		type states is (s_idle, s_flush, s_request, s_in, s_stin, s_out, s_stout);
		variable state : states;
	begin
		if rising_edge(clk) then
			if cken='1' then
   				case state is
   				when s_idle =>
					if (setup_rdy xor setup_req)='1' then
						flush_req <= not flush_rdy;
						state := s_flush;
					end if;
   				when s_flush =>
					if (flush_req xor flush_rdy)='0' then
						descriptor_req <= not descriptor_rdy;
						tksetup_req    <= not tksetup_rdy;
						state := s_request;
					end if;
				when s_request =>
					if (descriptor_req xor descriptor_rdy)='0' then
						dev_addr   <= (others => '0');
						dev_endp   <= (others => '0');
						device_req <= not device_req;
						if segment_dir(0)='1' then
							tkin_req <= not tkin_rdy;
							state   := s_in;
						else
							if false then
								tkout_req <= not tkout_rdy;
								state := s_out;
							else
    							tkin_req <= not tkin_rdy;
								state := s_stout;
							end if;
						end if;
					end if;
				when s_in =>
					if (tkin_req xor tkin_rdy)='0' then
						if rxdv='0' then
    						if (device_rdy xor device_req)='1' then
    							tkin_req <= not tkin_rdy;
    						else
    							tkout_req <= not tkout_rdy;
    							state := s_stin;
    						end if;
						end if;
					end if;
				when s_stin =>
					if (tkout_req xor tkout_rdy)='0' then
    					setup_rdy <= setup_req;
						state := s_idle;
					end if;
				when s_out =>
					if (tkout_req xor tkout_rdy)='0' then
						if txdis='1' then
    						tkin_req <= not tkin_rdy;
    						state := s_stout;
						else
    						tkout_req <= not tkout_rdy;
						end if;
					end if;
				when s_stout =>
					if (tkin_req xor tkin_rdy)='0' then
    					setup_rdy <= setup_req;
						state := s_idle;
					end if;
				end case;
			end if;
		end if;
	end process;

	device_p : process (device_rdy, clk)
		constant aaa : std_logic_vector := xxx(hdo(descriptors)**".device");
		variable cntr    : unsigned(0 to 8+3-1);
		variable bLength : unsigned(0 to 8-1);
		variable enas    : std_logic_vector(0 to 15-1);
	begin
		if rising_edge(clk) then
			if cken='1' then
				if (device_rdy xor device_req)='1' then
					if rxdv='1' then
						enas := multiplex(aaa, std_logic_vector(cntr(3 to 8-1)), 15);
						if rxbs='0' then
							if enas(0)='1' then
								blength := blength srl 1;
								blength(0) := rxd;
							end if;
							cntr := cntr + 1;
						end if;
						if cntr(0 to 8-1) >= blength then
							device_rdy <= device_req;
						end if;
					end if;
					tp(1 to 8) <= std_logic_vector(cntr(0 to 8-1));
				else
					blength := (others => '1');
					cntr    := (others => '0');
				end if;
			end if;
		end if;
	end process;

	segmenttable_i : entity hdl4fpga.rom
	generic map (
		bitrom => hdo(table)**".content")
	port map (
		addr => segment_id,
		data => segment_data);
	segment_dir    <= segment_data(segment_dir'range);
	segment_offset <= segment_data(segment_offset'range);
	segment_length <= segment_data(segment_length'range);

	segmentcontent_i : entity hdl4fpga.rom
	generic map (
		bitrom => reverse(hdo(test)**".content",8))
	port map (
		addr => std_logic_vector(descriptor_addr),
		data => descriptor_data);

	descriptor_p : process (clk)
		type states is (s_idle, s_send);
		variable state : states;
	begin
		if rising_edge(clk) then
			if cken='1' then
				if (descriptor_rdy xor descriptor_req)='1' then
					case state is
					when s_idle => 
						segment_id <= (others => '0');
						send_req <= not send_rdy;
						state := s_send;
					when s_send =>
						if (send_rdy xor send_req)='0' then
							descriptor_rdy <= descriptor_req;
							state := s_idle;
						end if;
					end case;
				else
					state := s_idle;
				end if;
			end if;
		end if;
	end process;

	send_p : process (clk)
		type states is (s_idle, s_data);
		variable state : states;
	begin
		if rising_edge(clk) then
			if cken='1' then
				if (send_rdy xor send_req)='1' then
    				case state is
    				when s_idle => 
    					descriptor_addr   <= unsigned(segment_offset);
    					descriptor_length <= resize(unsigned(segment_length), descriptor_length'length);
    					state := s_data;
    				when s_data =>
    					if txdis='0' then
    						if txbs='0' then
    							descriptor_addr   <= descriptor_addr   + 1;
    							descriptor_length <= descriptor_length - 1;
    						end if;
						else
    						send_rdy <= send_req;
    					end if;
    				end case;
				else
					descriptor_length <= (others => '1');
					state := s_idle;
				end if;
			end if;
		end if;
		txen <= not txdis;
		txd  <= descriptor_data(0);
	end process;

end;
