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

package usbpkg is
	constant tk_out    : std_logic_vector := x"1";
	constant tk_sof    : std_logic_vector := x"5";
	constant tk_in     : std_logic_vector := x"9";
	constant tk_setup  : std_logic_vector := x"d";

	constant data0     : std_logic_vector := x"3";
	constant data1     : std_logic_vector := x"b";

	constant hs_ack    : std_logic_vector := x"2";
	constant hs_nak    : std_logic_vector := x"a";
	constant hs_stall  : std_logic_vector := x"e";

	constant get_status        : std_logic_vector := x"00";
	constant clear_feature     : std_logic_vector := x"01";
	constant get_state         : std_logic_vector := x"02";
	constant set_feature       : std_logic_vector := x"03";
	constant set_address       : std_logic_vector := x"05";
	constant get_descriptor    : std_logic_vector := x"06";
	constant set_configuration : std_logic_vector := x"09";

	constant DeviceClass_hub   : std_logic_vector := x"09";
	constant InterfaceClass_hid : std_logic_vector := x"03";
	constant Protocol_keyboard : std_logic_vector := x"01";
	constant Protocol_mouse    : std_logic_vector := x"02";

	-- hid device
	constant get_report        : std_logic_vector := x"01";
	constant get_idle          : std_logic_vector := x"02";
	constant get_protocol      : std_logic_vector := x"03";
	constant set_report        : std_logic_vector := x"09";
	constant set_idle          : std_logic_vector := x"0a";
	constant set_protocol      : std_logic_vector := x"0b";

	constant hub_port_power    : std_logic_vector := x"0008";
	constant hub_port_reset    : std_logic_vector := x"0004";

	constant device    : std_logic_vector := x"01";
	constant config    : std_logic_vector := x"02";
	constant str       : std_logic_vector := x"03";
	constant interface : std_logic_vector := x"04";
	constant endpoint  : std_logic_vector := x"05";
	
	function segment_map (
		constant description : string;
		constant max_length  : natural := 1024)
		return string;

	function segment_table (
		constant description  : string;
		constant max_segments : natural := 64)
		return string;

	function decoder (
		constant object       : string;
		constant max_length   : natural := 1024;
		constant max_segments : natural := 64)
		return std_logic_vector;
end;

package body usbpkg is
	
	procedure copy (
		variable dst : inout string;
		variable pos : inout positive;
		constant src : in    string) is
	begin
		dst(pos to pos+src'length-1) := src;
		pos := pos+src'length;
	end;

	procedure copy (
		variable dst : inout string;
		variable pos : inout  natural;
		constant val : in  integer) is
		constant cvt : string := integer'image(val)&',';
	begin
		dst(pos to pos+cvt'length-1) := cvt;
		pos := pos+cvt'length;
	end;

	procedure get_value (
		variable value       : out natural;
		variable valid       : out boolean;
		constant description : in string) is
	begin
		if description'length < 1 then
			valid := false;
		else
			valid := true;
			value := hdl4fpga.hdo.to_integer(description);
		end if;
	end;

	procedure get_value (
		variable value       : out std_logic;
		variable valid       : out boolean;
		constant description : in string) is
		constant escval : string := escaped(description);
	begin
		if description'length < 1 then
			valid := false;
		else
			valid := true;
			value := hdl4fpga.hdo.to_stdulogic(escval(1));
		end if;
	end;

	function decoder (
		constant object       : string;
		constant max_length   : natural := 1024;
		constant max_segments : natural := 64)
		return std_logic_vector is
		variable value : natural;
		variable valid : boolean;
		variable n : natural;
		variable length  : natural;
		variable offsets : natural_vector(0 to max_segments-1);
		variable retval  : std_logic_vector(0 to max_length-1);
		variable num_bits : natural;
	begin
		for i in 0 to max_segments-1 loop
			n := i;
			if i > 0 then
				offsets(i) := offsets(i-1) + length;
			else
				offsets(i) := 0;
			end if;
			get_value(length, valid, escaped(hdo(object)**("["&natural'image(i)&"]=")));
			exit when not valid;
		end loop;
		num_bits := unsigned_num_bits(offsets(n-1));
		retval := (others => '0');
		for i in 0 to 2**num_bits-1 loop
			for j in 0 to n-1 loop
				if offsets(j) <= i and i < offsets(j+1) then
					retval(i*n+j) := '1';
				else
					retval(i*n+j) := '0';
				end if;
			end loop;
		end loop;
		return retval(0 to 2**num_bits*n-1);
	end;

	function segment_table (
		constant description  : string;
		constant max_segments : natural := 64)
		return string is

		function table_content (
			constant offsets : natural_vector;
			constant offset_num_bits : natural;
			constant lengths : natural_vector;
			constant length_num_bits : natural;
			constant dirs    : std_logic_vector;
			constant dir_num_bits : natural)
			return std_logic_vector is
			variable content : unsigned(0 to (dir_num_bits+offset_num_bits+length_num_bits)*offsets'length-1);
		begin
			assert offsets'length=lengths'length
				report "segment_table() : offsets'length => (" & natural'image(offsets'length) & ") /= " & "lengths'length -> (" & natural'image(lengths'length) & ")"
				severity failure;

			for i in offsets'range loop
				content(0 to dir_num_bits-1) := unsigned(dirs(i to i+dir_num_bits-1));
				content := content rol dir_num_bits;
				content(0 to offset_num_bits-1) := to_unsigned(offsets(i), offset_num_bits);
				content := content rol offset_num_bits;
				content(0 to length_num_bits-1) := to_unsigned(lengths(i)-1, length_num_bits);
				content := content rol length_num_bits;
			end loop;
			return std_logic_vector(content);
		end;

		variable lengths : natural_vector(0 to max_segments-1);
		variable offsets : natural_vector(0 to max_segments-1);
		variable dirs : std_logic_vector(0 to max_segments-1);
		variable length_num_bits : natural;
		variable offset_num_bits : natural;
		constant dir_num_bits    : natural := 1;
		variable valid   : boolean;
		variable n       : natural;
		variable address : natural;
		variable num_bits : natural;
		variable dir_left     : natural;
		variable dir_right    : natural;
		variable offset_left  : natural;
		variable offset_right : natural;
		variable length_left  : natural;
		variable length_right : natural;
	begin
		for i in 0 to max_segments-1 loop
			n := i;
			get_value(offsets(i), valid, escaped(hdo(description)**("["&natural'image(i)&"][0]=")));
			get_value(lengths(i), valid, escaped(hdo(description)**("["&natural'image(i)&"][1]=")));
			get_value(dirs(i),    valid, escaped(hdo(description)**("["&natural'image(i)&"][2]=")));
			exit when not valid;
		end loop;
		length_num_bits := unsigned_num_bits(max(lengths(0 to n-1))-1);
		offset_num_bits := unsigned_num_bits(offsets(n-1)+lengths(n-1)-1);

		assert true 
			report "segment_table() : length_num_bits -> " & natural'image(length_num_bits)
			severity note;

		address := unsigned_num_bits(n-1);
		num_bits := dir_num_bits+offset_num_bits+length_num_bits;
		dir_left     := 0;
		dir_right    := dir_num_bits-1;
		offset_left  := dir_right+1;
		offset_right := offset_left+offset_num_bits-1;
		length_left  := offset_right+1;
		length_right := length_left+length_num_bits-1;
		return
			"{" &
				"content:"   & hdl4fpga.base.to_string(table_content(offsets(0 to n-1), offset_num_bits, lengths(0 to n-1), length_num_bits, dirs(0 to n-1), dir_num_bits)) & "," &
				"address:"   & natural'image(address)      & "," &
				"data:"      & natural'image(num_bits)     & "," &
				"dir:{"      &
					"left:"  & natural'image(dir_left)     & "," &
					"right:" & natural'image(dir_right)    & "," &
					"},"     &
				"offset:{"   &
					"left:"  & natural'image(offset_left)  & "," &
					"right:" & natural'image(offset_right) & "," &
					"},"     &
				"length:{"   &
					"left:"  & natural'image(length_left)  & "," &
					"right:" & natural'image(length_right) & ","  &
					"}}";
	end;

	function segment_map (
		constant description : string;
		constant max_length  : natural := 1024)
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

		variable content : std_logic_vector(0 to description'length*4-1);
		variable pos  : natural;
		variable scc  : natural;
		variable table : string(1 to max_length);
		variable table_pos : positive;
		variable n : natural;
	begin
		pos := content'left;
		table_pos := table'left;
		n := 0;
		for i in 0 to description'right-description'left loop
			append(content, scc, pos, hdo(description)**("["& natural'image(i) &"].content="));
			if scc=pos then
				table_pos := table_pos - 1;
				exit;
			end if;
			table(table_pos) := '[';
			table_pos := table_pos + 1;
			copy(table, table_pos, table_pos, natural'image(pos)&",");
			copy(table, table_pos, table_pos, natural'image(scc-pos)&",");
			copy(table, table_pos, table_pos, std_logic'image(content(pos))&"],");
			pos := scc;
			n := n + 1;
		end loop;
		return
			"{" &
				"content:0x" & to_string(content(0 to pos-1), 16) & "," &
				"length:"    & natural'image(n)                   & "," &
				"table:["    & table(1 to table_pos-1) & "]"      &
			"}";
	end;

	-- function to_hdo (
		-- constant val : natural_vector;
		-- constant max_length : natural := 1024)
		-- return string is
-- 
		-- variable obj : string(1 to max_length);
		-- variable pos : natural;
	-- begin
		-- pos := obj'left;
		-- for i in 0 to val'length-1 loop
			-- copy(obj, pos, val(i));
		-- end loop;
		-- pos := pos - 1;
		-- return "["&obj(1 to pos-1)&"]";
	-- end;

end;