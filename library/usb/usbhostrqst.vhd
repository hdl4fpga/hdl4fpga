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
		tp          : out std_logic_vector(1 to 32) := (others => '0');
		clk         : in  std_logic;
		cken        : in  std_logic;

		setup_req   : in  std_logic;
		setup_rdy   : buffer std_logic := '0';
		flush_req   : buffer  std_logic := '0';
		flush_rdy   : in std_logic := '0';
		phy_rst     : out std_logic;

		dev_addr    : out std_logic_vector(7-1 downto 0);
		dev_endp    : out std_logic_vector(11-1 downto 7);
		dev_ackrx   : in  std_logic := '1';
		dev_acktx   : in  std_logic := '1';
		tksetup_req : buffer std_logic := '0';
		tksetup_rdy : in  std_logic := '0';
		tkstall_req : in  std_logic := '0';
		tkstall_rdy : buffer std_logic := '0';
		tkin_req    : buffer std_logic := '0';
		tkin_rdy    : in  std_logic;
		tkout_req   : buffer std_logic := '0';
		tkout_rdy   : in  std_logic;
		sof_tick    : in  std_logic;

		rxdv        : in  std_logic := '-';
		rxbs        : in  std_logic := '-';
		rxd         : in  std_logic := '-';

		txen        : out std_logic;
		txbs        : in  std_logic;
		txd         : out std_logic);

end;

architecture def of usbhostrqst is
	constant test : string := segment_map(
		"["&
			"{content:0x" & -- Hexadecimal format
				"80"      & -- Device to Host
				"06"      & -- GET_DESCRIPTOR
				"00"      & -- Descriptor index 
				"01"      & -- Descriptor type -> DEVICE
				"0000"    & -- Offset 
				"ffff"    & -- Length 64 bytes
			"}"           & 
			","           &
			"{content:0x" & -- Hexadecimal format
				"00"      & -- Host to Device
				"05"      & -- SET_ADDRESS
				"----"    & -- Address
				"0000"    & -- Offset 
				"0000"    & -- Length 64 bytes
			"}"           & 
			","           &
			"{content:0x" & -- Hexadecimal format
				"80"      & -- Device to Host
				"06"      & -- GET_DESCRIPTOR
				"00"      & -- Descriptor index 
				"02"      & -- Descriptor type -> CONFIGURATION
				"0000"    & -- Offset 
				"ffff"    & -- Length 64 bytes
			"}"           & 
			","           &
			"{content:0x" & -- Hexadecimal format
				"a0"      & -- Device to Host, Class 
				"06"      & -- GET_DESCRIPTOR
				"00"      & -- Descriptor index 
				"29"      & -- Descriptor type -> HUB
				"0000"    & -- Offset 
				"ffff"    & -- Length 64 bytes
			"}"           & 
			","           &
			"{content:0x" & -- Hexadecimal format
				"23"      & -- Device to Host
				"03"      & -- GET_DESCRIPTOR
				"04"      & -- Descriptor index 
				"00"      & -- Descriptor type -> DEVICE
				"0100"    & -- Offset 
				"0000"    & -- Length 64 bytes
			"}"           & 
		"]");

	constant table_length : natural := hdo(test)**".length";
	constant test1  : string := hdo(test)**".table";
	constant table  : string := segment_table(test1);
	constant bitrom : string := hdo(table)**".content";
	signal segment_id        : unsigned(0 to hdo(table)**".address"-1) := (others => '0');
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
	signal rqst_req : bit;
	signal rqst_rdy : bit;
	constant request : string := 
		"{" &
			"bmRequestTYpe:1," &
			"bRequest:1,"      &
			"wValue:2,"        &
			"wLength:2"        &
		"}";

	signal rply_req : bit;
	signal rply_rdy : bit;
				
	signal addr_val        : std_logic_vector(16-1 downto 0);
	signal bLength         : std_logic_vector( 8-1 downto 0);
	signal bDescriptorType : std_logic_vector( 8-1 downto 0);
	signal wTotalLength    : std_logic_vector(16-1 downto 0);

begin

	setup_p : process (cken, clk)
		type states is (s_idle, s_flush, s_rqst);
		variable state : states;
		variable timer : integer range -1 to 63;
	begin
		if rising_edge(clk) then
			if cken='1' then
				if (tkstall_rdy xor tkstall_req)='0' then
					case state is
	   				when s_idle =>
						if (setup_rdy xor setup_req)='1' then
							timer       := 63;
							-- addr_val    <= x"0000";
							tkstall_rdy <= tkstall_req;
							flush_req   <= not flush_rdy;
							phy_rst     <= '1';
							state       := s_flush;
						end if;
					when s_flush =>
						dev_addr   <= (others => '0');
						dev_addr   <= (others => '0');
						dev_endp   <= (others => '0');
						segment_id <= (others => '0');
						addr_val   <= x"000a";
						if timer < 0 then
							if (flush_req xor flush_rdy)='0' then
								phy_rst   <= '0';
								rqst_req  <= not rqst_rdy;
								state     := s_rqst;
							end if;
						elsif sof_tick='1' then
							timer := timer - 1;
						end if;
					when s_rqst =>
						if (rqst_req xor rqst_rdy)='0' then
							if segment_id < table_length-1 then
								segment_id <= segment_id + 1;
								rqst_req   <= not rqst_rdy;
							else
								setup_rdy <= setup_req;
								state     := s_idle;
							end if;
						elsif segment_id=2 then
							dev_addr <= addr_val(dev_addr'range);
						-- elsif segment_id=4 then
							-- dev_addr <= (others => '0');
						end if;
					end case;
				else
					setup_rdy <= setup_req;
					tkstall_rdy <= tkstall_req;
					state := s_idle;
				end if;
			end if;
		end if;
	end process;

	rqst_p : process (rqst_rdy, clk)
		type states is (s_idle, s_setup, s_in, s_stin, s_out, s_stout);
		variable state : states;
	begin
		if rising_edge(clk) then
			if cken='1' then
				if (tkstall_req xor tkstall_rdy)='0' then
					case state is
					when s_idle =>
						if (rqst_rdy xor rqst_req)='1' then
							tksetup_req <= not tksetup_rdy;
							send_req <= not send_rdy;
							state := s_setup;
						end if;
					when s_setup =>
						if (send_req xor send_rdy)='0' then
							rply_req <= not rply_rdy;
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
								if (rply_rdy xor rply_req)='1' then
									tkin_req <= not tkin_rdy;
								else
									tkout_req <= not tkout_rdy;
									state := s_stin;
								end if;
							end if;
						end if;
					when s_stin =>
						if (tkout_req xor tkout_rdy)='0' then
							rqst_rdy <= rqst_req;
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
							rqst_rdy <= rqst_req;
							state := s_idle;
						end if;
					end case;
				else
					rqst_rdy <= rqst_req;
					state := s_idle;
				end if;
			end if;
		end if;
	end process;

	descriptors_p : process (rply_req, clk)
		constant enatab : std_logic_vector := hdl4fpga.usbpkg.decoder(hdo'(
			"{"                     &
				"bLength:1,"        &
				"bDescriptorType:1" &
			"}"));

		variable cntr : unsigned(8+3-1 downto 0);
		variable enas : std_logic_vector(0 to 2-1);
		alias ena_bLength         is enas(0);
		alias ena_bDescriptorType is enas(1);
		variable byte : unsigned( 8-1 downto 0);
		variable bLength         : unsigned( 8-1 downto 0);
		variable bDescriptorType : unsigned( 8-1 downto 0);
	begin
		if rising_edge(clk) then
			if cken='1' then
				if (rply_rdy xor rply_req)='1' then
					enas := multiplex(enatab, std_logic_vector(cntr srl 3), enas'length);
					if rxdv='1' then
						if rxbs='0' then
							byte(0) := rxd;
							byte    := byte ror 1;
							if ena_bLength='1' then
								blength := byte;
							elsif ena_bDescriptorType='1' then
								bDescriptorType := byte;
							end if;
							cntr := cntr + 1;
						end if;
					end if;
					if (ena_bLength or ena_bDescriptorType)='0' then
						if (cntr srl 3) >= blength then
							cntr := (others => '0');
						end if;
					end if;
				else
					blength         := (others => '-');
					bDescriptorType := (others => '-');
					cntr            := (others => '0');
				end if;
			end if;
		end if;
	end process;

	configuration_p : process (rply_rdy, clk)
		constant enatab : std_logic_vector := hdl4fpga.usbpkg.decoder(hdo'(
			"{"                        &
				"bLength:1,"           &
				"bDescriptorType:1,"   &
				"wTotalLength:2"       &
			"}"));

		variable cntr : unsigned(8+3-1 downto 0);
		variable enas : std_logic_vector(0 to 3-1);
		alias ena_bLength         is enas(0);
		alias ena_bDescriptorType is enas(1);
		alias ena_wTotalLength    is enas(2);
		variable word : unsigned(16-1 downto 0);
		variable byte : unsigned( 8-1 downto 0);
	begin
		if rising_edge(clk) then
			if cken='1' then
				if (rply_rdy xor rply_req)='1' then
					enas := multiplex(enatab, std_logic_vector(cntr srl 3), enas'length);
					if rxdv='1' then
						if rxbs='0' then
							word(0) := rxd;
							word    := word ror 1;
							byte(0) := rxd;
							byte    := byte ror 1;
							if ena_bLength='1' then
								blength <= std_logic_vector(byte);
							elsif ena_bDescriptorType='1' then
								bDescriptorType <= std_logic_vector(byte);
							else
								case bDescriptorType is 
								when config =>
									if ena_wTotalLength='1' then
										wTotalLength <= std_logic_vector(word);
									end if;
								when others =>
								end case;
							end if;
							cntr := cntr + 1;
						end if;
					end if;
					if (ena_bLength or ena_bDescriptorType)='0' then
						case bDescriptorType is 
						when config =>
							if ena_wTotalLength='0' then
								if (cntr srl 3) >= unsigned(wTotalLength) then
									wTotalLength <= std_logic_vector(word);
									rply_rdy <= rply_req;
								end if;
							end if;
						when others =>
							if (cntr srl 3) >= unsigned(blength) then
								rply_rdy <= rply_req;
							end if;
						end case;
					end if;
				else
					blength         <= (others => '-');
					bDescriptorType <= (others => '-');
					wTotalLength    <= (others => '-');
					cntr            := (others => '0');
				end if;
			end if;
		end if;
	end process;

	segmenttable_i : entity hdl4fpga.rom
	generic map (
		bitrom => hdo(table)**".content")
	port map (
		addr => std_logic_vector(segment_id),
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

	send_p : process (clk)
		type states is (s_idle, s_data);
		variable state    : states;
		constant enatab   : std_logic_vector := hdl4fpga.usbpkg.decoder(hdo(request));
		variable cntr     : unsigned(0 to 3+3);
		variable enas     : std_logic_vector(0 to 4-1);
		alias ena_bRequest is enas(1);
		alias ena_wValue   is enas(2);
		variable wValue   : unsigned(16-1 downto 0);
		variable bRequest : unsigned(8-1 downto 0);
	begin
		if rising_edge(clk) then
			if cken='1' then
				enas := multiplex(enatab, std_logic_vector(cntr srl 3), enas'length);
				if (send_rdy xor send_req)='1' then
					case state is
					when s_idle => 
						descriptor_addr   <= unsigned(segment_offset);
						descriptor_length <= resize(unsigned(segment_length), descriptor_length'length);
						wValue := resize(unsigned(addr_val), wValue'length);
						cntr   := (others => '0');
						state  := s_data;
					when s_data =>
						if txdis='0' then
							if txbs='0' then
								descriptor_addr   <= descriptor_addr   + 1;
								descriptor_length <= descriptor_length - 1;
								if cntr(0)='0' then
									if ena_bRequest='1' then
										bRequest(0) := descriptor_data(0);
										bRequest    := bRequest ror 1;
									end if;
									cntr := cntr + 1;
								end if;
							end if;
						else
							send_rdy <= send_req;
						end if;
					end case;
				else
					descriptor_length <= (others => '1');
					state := s_idle;
				end if;
				txen <= not txdis;
				if ena_wValue='1' then  
					case bRequest(4-1 downto 0) is
					when unsigned(set_address) =>
						if txdis='0' then
							txd <= wValue(0);
							wValue := wValue ror 1;
						end if;
					when others =>
						txd <= descriptor_data(0);
					end case;
				else
					txd <= descriptor_data(0);
				end if;
			end if;
		end if;
	end process;

end;
