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
use hdl4fpga.hdoutils.all;
use hdl4fpga.base.all;
use hdl4fpga.ipoepkg.all;

entity tb_ethtx is
	generic (
		sha  : string;
		data : string);
	port (
		req  : in  std_logic :='0';
		rdy  : buffer std_logic :='0';
		id   : std_logic_vector;
		txc  : in  std_logic;
		txen : buffer std_logic;
		txd  : out std_logic_vector);
end;

architecture beh of tb_ethtx is
	constant bcast : string := "0xff_ff_ff_ff_ff_ff";

	function init_mac (
		constant data   : string;
		constant tha    : string := bcast;
		constant ethtyp : string)
		return std_logic_vector is
	begin
		return
			to_stdlogicvector(hdo(data)**(".tha"&'='&tha)) &
			to_stdlogicvector(hdo(data)**(".ethtyp"&'='&ethtyp));
	end;

	function init_arp (
		constant data : string)
		return std_logic_vector is
	begin
		return
			to_stdlogicvector(string'("0x0001"))              & -- htype
			to_stdlogicvector(string'("0x0800"))              & -- ptype
			to_stdlogicvector(string'("0x06"))                & -- hsize
			to_stdlogicvector(string'("0x04"))                & -- psize 
			to_stdlogicvector(string'("0x0001"))              & -- requst
			to_stdlogicvector(sha)                   & 
			aton(hdo(data)**".spa")                  & 
			to_stdlogicvector(string'("0x00_00_00_00_00_00")) & -- tmac                  & 
			aton(hdo(data)**".tpa");
	end;

	function init_ipv4 (
		constant data : string)
		return std_logic_vector is
		constant default_ipv4 : string := "{" &
			"verihl:0x45,"    &
				"tos:0x00,"    &
			 "length:0x0000," &
			  "ident:0x0000," &
			"flgsoff:0x0000," &
				"ttl:0x40,"   &
			  "proto:0x01,"   &
			 "chksum:0x0000}";

		constant verihl  : string := "0x45";
		constant tos     : string := hdo(data)**(".tos"     &'='& string'(hdo(default_ipv4)**".tos"));
		constant length  : string := hdo(data)**(".length"  &'='& string'(hdo(default_ipv4)**".length"));
		constant ident   : string := hdo(data)**(".ident"   &'='& string'(hdo(default_ipv4)**".ident"));
		constant flgsoff : string := hdo(data)**(".flgsoff" &'='& string'(hdo(default_ipv4)**".flgsoff"));
		constant ttl     : string := hdo(data)**(".ttl"     &'='& string'(hdo(default_ipv4)**".ttl"));
		constant proto   : string := hdo(data)**(".proto"   &'='& string'(hdo(default_ipv4)**".proto"));
		constant chksum  : string := hdo(data)**(".chksum"  &'='& string'(hdo(default_ipv4)**".chksum"));
		constant sa      : string := hdo(data)**".sa";
		constant da      : string := hdo(data)**".da";
	begin
		return 
			to_stdlogicvector(verihl)  & 
			to_stdlogicvector(tos)     & 
			to_stdlogicvector(length)  & 
			to_stdlogicvector(ident)   & 
			to_stdlogicvector(flgsoff) & 
			to_stdlogicvector(ttl)     & 
			to_stdlogicvector(proto)   & 
			to_stdlogicvector(chksum)  & 
			aton(sa)                   & 
			aton(da);
	end;

	function init_icmp (
		constant data : string)
		return std_logic_vector is
	begin
		return 
			to_stdlogicvector(hdo(data)**(".type"   &'='& "0x00"))       & 
			to_stdlogicvector(hdo(data)**(".code"   &'='& "0x00"))       & 
			to_stdlogicvector(hdo(data)**(".chksum" &'='& "0x0000"))     &
			to_stdlogicvector(hdo(data)**(".extn"   &'='& "0x00000000")) &
			to_stdlogicvector(hdo(data)**".data");
	end;

	function data_content (
		constant data : string;
		constant max_size : natural := 1024)
		return string is
		function pick (
			constant proto : string;
			constant data  : string)
			return string is
		begin

			if proto="icmp" then
				return
					"content:0x" &
					to_string(
						init_mac (
							data   => data**".mac", 
							tha    => bcast, 
							ethtyp => "0x0800")      &
						init_ipv4(
							data   => data**".ipv4") &
						init_icmp(
							data   => data), 
						16);
			elsif proto="arp" then
				return
					"content:0x" &
					to_string(
						init_mac (
							data   => data**".mac", 
							tha    => bcast,
							ethtyp => "0x0806")  &
						init_arp(
							data   => data),
						16);
			end if;
			return "";
		end;
		
		variable succ : natural;
		variable pos  : natural;
		variable cont : string(1 to max_size);
	begin
		pos := cont'left;
		cont(pos) := '{';
		pos := pos + 1;
		for i in 0 to length(data)-1 loop
			append (
				dst  => cont,
				scc => succ,
				pos  => pos,
				src  => pick(
					proto => tag(data&"["&natural'image(i)&"]"), 
					data  => data**("["&natural'image(i)&"]")) &',');
			pos := succ;
		end loop;
		cont(pos-1) := '}';

		return cont(cont'left to pos-1);
	end;

	signal pyl_frm  : std_logic;
	signal pyl_irdy : std_logic;
	signal pyl_trdy : std_logic;
	signal pyl_data : std_logic_vector(txd'range);

	constant data_mapped : string := map_memory(data_content(data));
	constant data_table  : string := map_table(data_mapped**".table");
	constant mem_data    : std_logic_vector := reverse(hdo(data_mapped)**".content",8);
	constant mem_table   : unsigned := hdo(data_table)**".content";

	signal line   : std_logic_vector(hdo(data_table)**".base.left" to hdo(data_table)**".length.right");
	signal addr   : unsigned(hdo(data_table)**".base.left"   to hdo(data_table)**".base.right");
	signal pos    : integer range -1 to 2**((hdo(data_table)**".length.right"-hdo(data_table)**".length.left")+1)-1;

	constant debug : boolean := false;
begin

	assert not debug
		report CR & data_mapped
		severity note;

	assert not debug
		report CR & data_table
		severity note;

	assert not debug
		report CR & data_content(data)
		severity note;

	data_rom_e : entity hdl4fpga.rom
	generic map(
		bitdata => reverse(hdo(data_mapped)**".content",8))
	port map(
		addr => std_logic_vector(addr(addr'left to addr'right-(unsigned_num_bits(txd'length)-1))),
		data => pyl_data);

	tab_rom_e : entity hdl4fpga.rom
	generic map(
		bitdata => hdo(data_table)**".content")
	port map(
		addr => id,
		data => line);

	process (req, rdy, txc)
	begin
		if rising_edge(txc) then
			if (rdy xor req)='1' then
				if pyl_trdy='1' then
					if pos < 0 then
						rdy <= req;
					else
						pos  <= pos  - txd'length;
						if pos > 1 then
						addr <= addr + txd'length;
						end if;
					end if;
				end if;
			else
				pos  <= to_integer(unsigned(line(hdo(data_table)**".length.left" to hdo(data_table)**".length.right")));
				addr <= unsigned(line(addr'range));
			end if;
		end if;
	end process;
	pyl_frm  <= (rdy xor req) when pos >= 0 else '0';
	pyl_irdy <= (rdy xor req);

	eth_e : entity hdl4fpga.eth_tx
	generic map (
		sha => to_stdlogicvector(sha))
	port map (
		mii_clk  => txc,
		mii_frm  => txen,
		mii_data => txd,
	
		pyl_frm  => pyl_frm,
		pyl_irdy => pyl_irdy,
		pyl_trdy => pyl_trdy,
		pyl_data => pyl_data);

end;
