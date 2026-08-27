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

package hdoutils is
	procedure copy (
		variable dst : inout string;
		variable scc : inout natural;
		variable pos : in  natural;
		constant src : in  string);

	procedure append (
		variable dst : inout string;
		variable scc : inout natural;
		variable pos : in  natural;
		constant src : in  string);

	function map_memory (
		constant description : string;
		constant max_length  : natural := 1024)
		return string;

	function map_table (
		constant description  : string;
		constant max_sections : natural := 64)
		return string;

	function decoder (
		constant object       : string;
		constant max_length   : natural := 1024;
		constant max_sections : natural := 64)
		return std_logic_vector;

end;

package body hdoutils is
	
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
		variable pos : inout natural;
		constant val : in  integer) is
		constant cvt : string := integer'image(val)&',';
	begin
		dst(pos to pos+cvt'length-1) := cvt;
		pos := pos+cvt'length;
	end;

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

	procedure append (
		variable dst : inout string;
		variable scc : inout natural;
		variable pos : in  natural;
		constant src : in  string) is

	begin
		if src'length > 0 then
			copy(dst, scc, pos, src);
		else
			scc := pos;
		end if;
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
		constant max_sections : natural := 64)
		return std_logic_vector is
		variable value    : natural;
		variable valid    : boolean;
		variable n        : natural;
		variable length   : natural;
		variable bases    : natural_vector(0 to max_sections-1);
		variable retval   : std_logic_vector(0 to max_length-1);
		variable num_bits : natural;
	begin
		n := 0;
		for i in 0 to max_sections-1 loop
			n := i;
			if i > 0 then
				bases(i) := bases(i-1) + length;
			else
				bases(i) := 0;
			end if;
			get_value(length, valid, escaped(hdo(object)**("["&natural'image(i)&"]=")));
			exit when not valid;
		end loop;
		num_bits := unsigned_num_bits(bases(n-1));
		retval := (others => '0');
		for i in 0 to 2**num_bits-1 loop
			for j in 0 to n-1 loop
				if bases(j) <= i and i < bases(j+1) then
					retval(i*n+j) := '1';
				else
					retval(i*n+j) := '0';
				end if;
			end loop;
		end loop;
		return retval(0 to 2**num_bits*n-1);
	end;

	function map_table (
		constant description  : string;
		constant max_sections : natural := 64)
		return string is

		function table_content (
			constant bases   : natural_vector;
			constant base_num_bits : natural;
			constant lengths : natural_vector;
			constant length_num_bits : natural)
			return std_logic_vector is
			variable content : unsigned(0 to (base_num_bits+length_num_bits)*bases'length-1);
		begin
			assert bases'length=lengths'length
				report "map_table() : bases'length => (" & natural'image(bases'length) & ") /= " & "lengths'length -> (" & natural'image(lengths'length) & ")"
				severity failure;

			for i in bases'range loop
				content(0 to base_num_bits-1) := to_unsigned(bases(i), base_num_bits);
				content := content rol base_num_bits;
				content(0 to length_num_bits-1) := to_unsigned(lengths(i)-1, length_num_bits);
				content := content rol length_num_bits;
			end loop;
			return std_logic_vector(content);
		end;

		variable lengths : natural_vector(0 to max_sections-1);
		variable bases   : natural_vector(0 to max_sections-1);
		variable length_num_bits : natural;
		variable base_num_bits   : natural;
		variable valid        : boolean;
		variable address      : natural;
		variable num_bits     : natural;
		variable base_left    : natural;
		variable base_right   : natural;
		variable length_left  : natural;
		variable length_right : natural;
		variable n            : natural;
	begin
		n := 0;
		for i in 0 to max_sections-1 loop
			n := i;
			get_value(bases(i), valid, escaped(hdo(description)**("["&natural'image(i)&"][0]=")));
			get_value(lengths(i), valid, escaped(hdo(description)**("["&natural'image(i)&"][1]=")));
			exit when not valid;
		end loop;
		length_num_bits := unsigned_num_bits(max(lengths(0 to n-1))-1);
		base_num_bits := unsigned_num_bits(bases(n-1)+lengths(n-1)-1);

		assert true 
			report "map_table() : length_num_bits -> " & natural'image(length_num_bits)
			severity note;

		address  := unsigned_num_bits(n-1);
		num_bits := base_num_bits+length_num_bits;
		base_left    := 0;
		base_right   := base_left+base_num_bits-1;
		length_left  := base_right+1;
		length_right := length_left+length_num_bits-1;
		return
			"{" &
				"content:"   & hdl4fpga.base.to_string(table_content(bases(0 to n-1), base_num_bits, lengths(0 to n-1), length_num_bits)) & "," &
				"address:"   & natural'image(address)      & "," &
				"data:"      & natural'image(num_bits)     & "," &
				"base:{"   &
					"left:"  & natural'image(base_left)    & "," &
					"right:" & natural'image(base_right)   &
					"},"     &
				"length:{"   &
					"left:"  & natural'image(length_left)  & "," &
					"right:" & natural'image(length_right) &
					"}}";
	end;

	function map_memory (
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

		variable content   : std_logic_vector(0 to description'length*4-1);
		variable pos       : natural;
		variable scc       : natural;
		variable table     : string(1 to max_length);
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
			copy(table, table_pos, table_pos, natural'image(scc-pos)&"],");
			-- copy(table, table_pos, table_pos, std_logic'image(content(pos))&"],");
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

	procedure get_value (
		variable value        : inout string;
		constant base         : in    natural;
		variable length       : inout natural;
		constant object       : in    string) is
		variable value_base   : positive;
		variable tag_base     : positive;
		variable tag_length   : natural;
	begin
		resolve(object, value_base, length, tag_base, tag_length);
		if length/=0 then
			value(base to base+length-1) := object(value_base to value_base+length-1);
		end if;
	end;
		
	procedure get_value (
		variable value      : inout string;
		constant base       : in    natural;
		variable length     : inout natural;
		constant object     : in    string;
		constant position   : in    natural) is
		constant key        : string := '[' & natural'image(position) & ']';
		constant expression : string := object & key;
	begin
		get_value(value, base, length, expression);
	end;
		
	procedure get_value (
		variable value    : inout string;
		constant base     : in    natural;
		variable length   : inout natural;
		constant object   : in    string;
		constant key      : in    string) is
		constant expression : string := object & key;
	begin
		get_value(value, base, length, expression);
	end;
end;
