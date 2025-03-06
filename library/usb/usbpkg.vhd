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

package usbpkg is
	constant tk_out    : std_logic_vector := x"1";
	constant tk_sof    : std_logic_vector := x"5";
	constant tk_in     : std_logic_vector := x"9";
	constant tk_setup  : std_logic_vector := x"d";

	constant data0     : std_logic_vector := x"3";
	constant data1     : std_logic_vector := x"b";

	constant hs_ack    : std_logic_vector := x"2";
	constant hs_nack   : std_logic_vector := x"a";
	constant hs_stall  : std_logic_vector := x"e";

	type requests is (
    	-- get_status,
    	-- clear_status,
    	-- set_feature,
    	set_address,
    	get_descriptor,
    	-- set_descriptor,
    	-- get_configuration,
    	set_configuration);
    	-- get_interface,
    	-- set_interface,
    	-- synch_frame);

	type bit_requests is array(requests) of bit;
	type requestid_vector is array(requests) of std_logic_vector(4-1 downto 0);
	constant request_ids : requestid_vector := (
	    -- get_status        => x"0",
	    -- clear_status      => x"1",
	    -- set_feature       => x"3",
	    set_address       => x"5",
	    get_descriptor    => x"6",
	    -- set_descriptor    => x"7",
	    -- get_configuration => x"8",
	    set_configuration => x"9");
	    -- get_interface     => x"a",
	    -- set_interface     => x"b",
	    -- synch_frame       => x"c");

	type decriptor_types is (
		device, 
		config, 
		str   , 
		interface, 
		endpoint);
	type decriptortypes_vector is array(decriptor_types) of std_logic_vector(8-1 downto 0);
	constant decriptortypes_ids : decriptortypes_vector := (
    	device    => x"01",
    	config    => x"02",
    	str       => x"03",
    	interface => x"04",
    	endpoint  => x"05");
	
	function segments (
		constant description  : string;
		constant max_segments : natural := 64)
		return string;

end;

package body usbpkg is
	
	function segments (
		constant description  : string;
		constant max_segments : natural := 64)
		return string is

   		procedure copy (
   			variable dst : inout string;
   			variable scc : inout natural;
   			variable pos : in  natural;
   			constant src : in  string) is
   		begin
			if src'length > 0 then 
				dst(pos to pos+src'length-1) := src;
				scc := pos+src'length;
			end if;
   		end;

    	procedure append (
    		variable mem : inout std_logic_vector;
    		variable scc : inout natural;
    		variable pos : in  natural;
    		constant val : in  string) is

    		procedure copy (
    			variable mem : inout std_logic_vector;
    			variable scc : out natural;
    			variable pos : in  natural;
    			constant val : in  string) is
    			constant bin : std_logic_vector := to_stdlogicvector(val);
    		begin
    			mem(pos to pos+bin'length-1) := bin;
    			scc := pos+bin'length;
    		end;

    	begin
    		if val'length > 0 then
    			copy(mem, scc, pos, val);
    		else
    			scc := pos;
    		end if;
    	end;

		constant max_length : natural := max_segments;
		variable data : std_logic_vector(0 to description'length*4-1);
		variable pos : natural;
		variable scc : natural;
		variable length : string(1 to 1024);
		variable length_pos : positive;
		variable length_scc : positive;
		variable offset : string(1 to 1024);
		variable offset_pos : positive;
		variable offset_scc : positive;
	begin
		pos := data'left;
		offset_pos := offset'left;
		length_pos := length'left;
		for i in 0 to description'right-description'left loop
			append(data, scc, pos, hdo(description)**("["& natural'image(i) &"]="));
			if scc=pos then
				offset_pos := offset_pos - 1;
				-- length_pos := length_pos - 1;
				exit;
			end if;
			copy(offset, offset_pos, offset_pos, natural'image(pos)&",");
			copy(offset, offset_pos, offset_pos, natural'image(scc-pos)&",");
			-- copy(length, length_pos, length_pos, natural'image(scc-pos)&",");
			pos := scc;
		end loop;
		if pos > data'left then 
			return compact(
				"{" &
				"    data:0x"&to_string(data(0 to pos-1), 16) & "," &
				offset(1 to offset_pos-1) &
				"}"
				);
		end if;
		return "";
	end;

end;