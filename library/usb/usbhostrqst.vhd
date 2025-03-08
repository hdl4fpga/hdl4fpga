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
		dev_ack   : in  std_logic := '1';
		tksetup_req : buffer std_logic := '0';
		tksetup_rdy : in  std_logic := '0';
		tkin_req  : buffer std_logic;
		tkin_rdy  : in  std_logic;
		sof_tick  : in  std_logic;

		rxdv      : in  std_logic := '-';
		rxbs      : in  std_logic := '-';
		rxd       : in  std_logic := '-';

		txen      : out std_logic;
		txbs      : in  std_logic;
		txd       : out std_logic);

end;

architecture def of usbhostrqst is
	constant test   : string := segment_map("[{content:0x8006000100004000},{content:0xffff},{content:0xffff}]");
	constant table  : string := segment_table(hdo(test)**".table");
	constant bitrom : string := hdo(table)**".content";
	signal segment_id        : std_logic_vector(0 to hdo(table)**".address"-1);
	signal segment_data      : std_logic_vector(0 to hdo(table)**".data"-1);
	signal segment_offset    : std_logic_vector(natural'(hdo(table)**".offset.left") to natural'(hdo(table)**".offset.right"));
	signal segment_length    : std_logic_vector(natural'(hdo(table)**".length.left") to natural'(hdo(table)**".length.right"));
	signal descriptor_length : unsigned(0 to segment_length'length);
	signal descriptor_addr   : unsigned(segment_offset'range);
	signal descriptor_data   : std_logic_vector(0 to 0);

	signal config_req : bit;
	signal config_rdy : bit;
begin

	setup_p : process (cken, clk)
		type states is (s_idle, s_flush, s_config, s_tksetup);
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
						config_req <= not config_rdy;
						state := s_config;
					end if;
				when s_config =>
					if (config_req xor config_rdy)='0' then
						dev_addr <= (others => '0');
						dev_endp <= (others => '0');
						tksetup_req <= not tksetup_rdy;
						state := s_tksetup;
					end if;
				when s_tksetup =>
					if (tksetup_req xor tksetup_rdy)='0' then
						setup_rdy <= setup_req;
						state := s_idle;
					end if;
				end case;
			end if;
		end if;
	end process;

	segmenttable_i : entity hdl4fpga.rom
	generic map (
		bitrom => reverse(hdo(table)**".content",8))
	port map (
		addr => segment_id,
		data => segment_data);
	segment_offset <= segment_data(segment_offset'range);
	segment_length <= segment_data(segment_length'range);

	segmentcontent_i : entity hdl4fpga.rom
	generic map (
		bitrom => reverse(hdo(test)**".content",8))
	port map (
		addr => std_logic_vector(descriptor_addr),
		data => descriptor_data);

	config_p : process (clk)
		type states is (s_idle, s_data);
		variable state : states;
		alias txdis is descriptor_length(descriptor_length'left);
	begin
		if rising_edge(clk) then
			if cken='1' then
				if (config_rdy xor config_req)='1' then
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
						elsif dev_ack='1' then
							config_rdy <= config_req;
							-- state := s_idle;
						else
							config_rdy <= config_req;
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
