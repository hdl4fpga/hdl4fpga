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

package ipoepkg is
	constant frames : string := compact("{" &
		"format:{"                  &
			"mac:{"                 &
				"    hwda:48,"      &
				"    hwsa:48,"      &
				"    type:16},"     &
    		"arp:{"                 &
    			"   htype:16,"      &
    			"   ptype:16,"      &
    			"    hlen:8,"       &
    			"    plen:8,"       &
    			"    oper:16,"      &
    			"     sha:48,"      &
    			"     spa:32,"      &
    			"     tha:48,"      &
    			"     tpa:32},"     &
    		"ipv4:{"                &
    			"  verihl:8,"       &
    			"     tos:8,"       &
    			"  legnth:16,"      &
    			"   ident:16,"      &
    			" flgsfrg:16,"      &
    			"     ttl:8,"       &
    			"   proto:8,"       &
    			"  chksum:16,"      &
    			"      sa:32,"      &
    			"      da:32},"     &
    		"icmp:{"                &
    			"    type:8,"       &
    			"    code:8,"       &
    			"  ckksum:16,"      &
    			"      id:16,"      &
    			"     seq:16},"     &
    		"udp:{"                 &
    			"      sp:16,"      &
    			"      dp:16,"      &
    			"  length:16,"      &
    			"  chksum:16},"     &
    		"dhcp:{"                &
    			"      op:8,"       &
    			"   htype:8,"       &
    			"    hlen:8,"       &
    			"    hops:8,"       &
    			"     xid:32,"      &
    			"    secs:16,"      &
    			"   flags:16,"      &
    			"  ciaddr:32,"      &
    			"  yiaddr:32,"      &
    			"  siaddr:32,"      &
    			"  giaddr:32,"      &
    			" chaddr6:48,"      &
    			"chaddr10:80,"      &
    			"  shname:512,"     &
    			"  fbname:1024,"    &
    			"  cookie:32}},"    &
		"data:{"                    &
    		"mac:{"                 &
				"type:{"            &
					"ipv4:0x0800,"  &
					" arp:0x0806}}," &
    		"arp:{"                 &
			    "htype:0x0001,"     &
			    "ptype:0x0800,"     &
			    " hlen:0x06,"       &
			    " plen:0x04,"       &
			    " oper:{"           &
					"reply:0x0002}}," &
    		"ipv4:{"                &
				"proto:{"           &
					"icmp:0x01,"    &
					" udp:0x11}},"  &
			"icmp:{"                &
				"reply:{"           &
					"code:0x00,"    &
					"type:0x08},"   &
				"rqst:{"            &
					"code:0x00,"    &
					"type:0x00}},"  &
			"dhcp:{"                &
				"op:{"              &
					"offer:0x02}}}}");

	function aton (
		constant ipa : string)
		return std_logic_vector;

	function udp_checksummed(
		constant src  : std_logic_vector(0 to 32-1);
		constant dst  : std_logic_vector(0 to 32-1);
		constant udp  : std_logic_vector)
		return std_logic_vector;

	function summation (
		constant format : string)
		return natural;

end;

package body ipoepkg is

	function aton (
		constant ipa : string)
		return std_logic_vector is
		constant n      : natural := 8;
		variable aux    : natural range 0 to 2**n-1;
		variable retval : unsigned(0 to 32-1);
	begin
		retval := (others => '0');
		aux    := 0;
		for i in ipa'range loop
			if ipa(i)='.' then
				retval(0 to n-1) := to_unsigned(aux,n);
				retval := retval rol 8;
				aux := 0;
			else
				aux := aux * 10;
				aux := aux + (character'pos(ipa(i))-character'pos('0'));
			end if;
		end loop;
		retval(0 to n-1) := to_unsigned(aux,n);
		retval := retval rol 8;
		return std_logic_vector(retval);
	end;

	function udp_checksummed(
		constant src  : std_logic_vector(0 to 32-1);
		constant dst  : std_logic_vector(0 to 32-1);
		constant udp  : std_logic_vector)
		return std_logic_vector is

    	function oneschecksum (
    		constant data : std_logic_vector;
    		constant size : natural)
    		return std_logic_vector is
    		constant n        : natural := (data'length+size-1)/size;
    		variable aux      : unsigned(0 to n*size-1);
    		variable checksum : unsigned(0 to size);
    		variable retval   : std_logic_vector(0 to size-1);
    	begin
    		aux := (others => '0');
    		aux(0 to data'length-1) := unsigned(data);
    		checksum := ('0', others => '1');
    		for i in 0 to n-1 loop
    			checksum := checksum + resize(aux(0 to size-1), checksum'length);
    			if checksum(0)='1' then
    				checksum := checksum + to_unsigned(1, checksum'length); -- Xilinx's bug
    			end if;
    			checksum(0) := '0';
    			aux := aux sll size;
    		end loop;
    		return std_logic_vector(checksum(1 to size));
    	end;

		variable len : unsigned(0 to 16-1);
		variable aux : unsigned(0 to udp'length+src'length+32+dst'length-1) := (others => '0');
	begin
		aux(0 to udp'length-1) := unsigned(udp);
		len := aux(32 to 48-1);
		aux := aux rol udp'length;
		aux(src'range) := unsigned(src);
		aux := aux rol src'length;
		aux(dst'range) := unsigned(dst);
		aux := aux rol dst'length;
		aux( 0 to 16-1) := x"0011";
		aux(16 to 32-1) := len;
		aux := aux rol 32;

		aux(48 to 64-1) := unsigned(oneschecksum(not std_logic_vector(aux), 16));
		return std_logic_vector(aux(0 to udp'length-1));
	end;

	function summation (
		constant format : string)
		return natural is
		variable retval : natural;
		variable value  : integer;
	begin
		for i in 0 to format'length-1 loop
			value := hdo(format)**('['&natural'image(i)&"]=-1");
			exit when value <= 0;
			retval := retval + value;
		end loop;
		return retval;
	end;
		

end;
