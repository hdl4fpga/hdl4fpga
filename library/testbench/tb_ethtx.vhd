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

library hdl4fpga;
use hdl4fpga.hdo.all;
use hdl4fpga.base.all;
use hdl4fpga.ipoepkg.all;

entity tb_ethtx is
	generic (
		sha  : string;
		data : string);
	port (
		req  : in  std_logic :='0';
		rdy  : buffer std_logic :='0';
		txc  : in  std_logic;
		txen : buffer std_logic;
		txd  : out std_logic_vector);
end;

architecture beh of tb_ethtx is

	constant default_ipv4 : string := "{" &
		"verihl:0x45,"    &
		    "tos:0x0,"    &
		 "length:0x0000," &
		  "ident:0x0000," &
		"flgsoff:0x0000," &
		    "ttl:0x40,"   &
		  "proto:0x01,"   &
		 "chksum:0x0000}";

	function init_ipv4 (
		constant data : string)
		return std_logic_vector is
		constant tha     : string := hdo(data)**".tha"          &'='& "0x00_00_00_00_00_00";
		constant tos     : string := hdo(data)**".ipv4.tos"     &'='& hdo(default_ipv4)**".tos";
		constant length  : string := hdo(data)**".ipv4.length"  &'='& hdo(default_ipv4)**".length";
		constant flgsoff : string := hdo(data)**".ipv4.flgsoff" &'='& hdo(default_ipv4)**".flgsoff";
		constant ttl     : string := hdo(data)**".ipv4.ttl"     &'='& hdo(default_ipv4)**".ttl";
		constant proto   : string := hdo(data)**".ipv4.proto"   &'='& hdo(default_ipv4)**".proto";
		constant chksum  : string := hdo(data)**".ipv4.chksum"  &'='& hdo(default_ipv4)**".chksum";
		constant spa     : string := hdo(data)**".spa"          &'='& hdo(data)**".ipv4.spa";
		constant dpa     : string := hdo(data)**".dpa"          &'='& hdo(data)**".ipv4.dpa";
	begin
		return 
			to_stdlogicvector(verihl)  & 
			to_stdlogicvector(tos)     & 
			to_stdlogicvector(length)  & 
			to_stdlogicvector(flgsoff) & 
			to_stdlogicvector(ttl)     & 
			to_stdlogicvector(proto)   & 
			to_stdlogicvector(chksum)  & 
			to_stdlogicvector(spa)     & 
			to_stdlogicvector(dpa);
	end;

	function init_icmp (
		constant data : string)
		return std_logic_vector is
	begin
		return 
			to_stdlogicvector(hdo(data)**".type") & 
			to_stdlogicvector(hdo(data)**".code") & 
			to_stdlogicvector(hdo(data)**".chksum");
	end;

	function init_rom (
		constant data : string)
		return std_logic_vector is
		constant bcast  : string := "0xff_ff_ff_ff_ff_ff";
		constant spa    : string := hdo(data)**".spa";
		constant ethtyp : string := "0x0806";
		constant htype  : string := "0x0001";
		constant ptype  : string := "0x0800";
		constant hsize  : string := "0x06";
		constant psize  : string := "0x04";
		constant requst : string := "0x0001";
		constant tmac   : string := "0x00_00_00_00_00_00";
		constant tpa    : string := hdo(data)**".tpa";
	begin
		return reverse(
			to_stdlogicvector(bcast)  &
			to_stdlogicvector(ethtyp) & 
			to_stdlogicvector(htype)  &
			to_stdlogicvector(ptype)  & 
			to_stdlogicvector(hsize)  & 
			to_stdlogicvector(psize)  & 
			to_stdlogicvector(requst) &
			to_stdlogicvector(sha)    & 
			aton(spa)                 & 
			to_stdlogicvector(tmac)   & 
			aton(tpa),8);
	end;

	function init_arp (
		constant data : string)
		return std_logic_vector is
		constant bcast  : string := "0xff_ff_ff_ff_ff_ff";
		constant spa    : string := hdo(data)**".spa";
		constant ethtyp : string := "0x0806";
		constant htype  : string := "0x0001";
		constant ptype  : string := "0x0800";
		constant hsize  : string := "0x06";
		constant psize  : string := "0x04";
		constant requst : string := "0x0001";
		constant tmac   : string := "0x00_00_00_00_00_00";
		constant tpa    : string := hdo(data)**".tpa";
	begin
		return reverse(
			to_stdlogicvector(bcast)  &
			to_stdlogicvector(ethtyp) & 
			to_stdlogicvector(htype)  &
			to_stdlogicvector(ptype)  & 
			to_stdlogicvector(hsize)  & 
			to_stdlogicvector(psize)  & 
			to_stdlogicvector(requst) &
			to_stdlogicvector(sha)    & 
			aton(spa)                 & 
			to_stdlogicvector(tmac)   & 
			aton(tpa),8);
	end;


	signal pyl_frm  : std_logic;
	signal pyl_irdy : std_logic;
	signal pyl_trdy : std_logic;
	signal pyl_data : std_logic_vector(txd'range);

	constant bitdata : std_logic_vector := reverse(reverse(init_rom(data)), txd'length);
	signal ptr : natural range 0 to bitdata'length/txd'length-1;

begin

	process (req, rdy, txc)
	begin
		if rising_edge(txc) then
			if (rdy xor req)='1' then
				if pyl_trdy='1' then
					if ptr > 0 then
						ptr <= ptr - 1;
					else
						ptr <= bitdata'length/txd'length-1;
						rdy <= req;
					end if;
				end if;
			else
				ptr <= bitdata'length/txd'length-1;
			end if;
		end if;
	end process;
	pyl_frm  <= (rdy xor req) when ptr > 0 else '0';
	pyl_irdy <= (rdy xor req);
	pyl_data <= bitdata(ptr*txd'length to (ptr+1)*txd'length-1);

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
