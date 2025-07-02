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

	function description (
		constant object : in string)
		return string;

	function xxx (
		constant description_bin : string)
		return string;
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
		variable value    : natural;
		variable valid    : boolean;
		variable n        : natural;
		variable length   : natural;
		variable offsets  : natural_vector(0 to max_segments-1);
		variable retval   : std_logic_vector(0 to max_length-1);
		variable num_bits : natural;
	begin
		n := 0;
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
			constant length_num_bits : natural)
			return std_logic_vector is
			variable content : unsigned(0 to (offset_num_bits+length_num_bits)*offsets'length-1);
		begin
			assert offsets'length=lengths'length
				report "segment_table() : offsets'length => (" & natural'image(offsets'length) & ") /= " & "lengths'length -> (" & natural'image(lengths'length) & ")"
				severity failure;

			for i in offsets'range loop
				content(0 to offset_num_bits-1) := to_unsigned(offsets(i), offset_num_bits);
				content := content rol offset_num_bits;
				content(0 to length_num_bits-1) := to_unsigned(lengths(i)-1, length_num_bits);
				content := content rol length_num_bits;
			end loop;
			return std_logic_vector(content);
		end;

		variable lengths : natural_vector(0 to max_segments-1);
		variable offsets : natural_vector(0 to max_segments-1);
		variable length_num_bits : natural;
		variable offset_num_bits : natural;
		variable valid        : boolean;
		variable address      : natural;
		variable num_bits     : natural;
		variable offset_left  : natural;
		variable offset_right : natural;
		variable length_left  : natural;
		variable length_right : natural;
		variable n            : natural;
	begin
		n := 0;
		for i in 0 to max_segments-1 loop
			n := i;
			get_value(offsets(i), valid, escaped(hdo(description)**("["&natural'image(i)&"][0]=")));
			get_value(lengths(i), valid, escaped(hdo(description)**("["&natural'image(i)&"][1]=")));
			exit when not valid;
		end loop;
		length_num_bits := unsigned_num_bits(max(lengths(0 to n-1))-1);
		offset_num_bits := unsigned_num_bits(offsets(n-1)+lengths(n-1)-1);

		assert true 
			report "segment_table() : length_num_bits -> " & natural'image(length_num_bits)
			severity note;

		address := unsigned_num_bits(n-1);
		num_bits := offset_num_bits+length_num_bits;
		offset_left  := 0;
		offset_right := offset_left+offset_num_bits-1;
		length_left  := offset_right+1;
		length_right := length_left+length_num_bits-1;
		return
			"{" &
				"content:"   & hdl4fpga.base.to_string(table_content(offsets(0 to n-1), offset_num_bits, lengths(0 to n-1), length_num_bits)) & "," &
				"address:"   & natural'image(address)      & "," &
				"data:"      & natural'image(num_bits)     & "," &
				"base:{"   &
					"left:"  & natural'image(offset_left)  & "," &
					"right:" & natural'image(offset_right) &
					"},"     &
				"length:{"   &
					"left:"  & natural'image(length_left)  & "," &
					"right:" & natural'image(length_right) &
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
		constant offset       : in    natural;
		variable length       : inout natural;
		constant object       : in    string) is
		variable value_offset : positive;
		variable tag_offset   : positive;
		variable tag_length   : natural;
	begin
		resolve(object, value_offset, length, tag_offset, tag_length);
		if length/=0 then
			value(offset to offset+length-1) := object(value_offset to value_offset+length-1);
		end if;
	end;
		
	procedure get_value (
		variable value      : inout string;
		constant offset     : in    natural;
		variable length     : inout natural;
		constant object     : in    string;
		constant position   : in    natural) is
		constant key        : string := '[' & natural'image(position) & ']';
		constant expression : string := object & key;
	begin
		get_value(value, offset, length, expression);
	end;
		
	procedure get_value (
		variable value    : inout string;
		constant offset   : in    natural;
		variable length   : inout natural;
		constant object   : in    string;
		constant key      : in    string) is
		constant expression : string := object & key;
	begin
		get_value(value, offset, length, expression);
	end;
			
	function description (
		constant object : in string) 
		return string is

		procedure append(
			variable dst    : inout string;
			variable length : out   natural;
			constant offset : in    natural;
			constant src    : in    string) is
		begin
			dst(offset to offset+src'length-1) := src;
			length := src'length;
		end;

		procedure sweep (
			variable data         : inout string;
			constant data_offset  : in    natural;
			variable data_length  : inout natural;
			constant object       : in    string) is
			variable value_length : natural;
			variable value        : string(data'range);
			variable index        : natural;
			variable offset       : positive;
		begin
			data_length := 0;
			if object'length=0 then
				return;
			end if;
			index := 0;
			for i in object'range loop 
				get_value(value, value'left, value_length, object, index);
				exit when value_length=0;

				offset := data_offset+data_length;
				data(offset to offset+(value_length-2)-1) := to_string(reverse(to_stdlogicvector(value(value'left to value'left+value_length-1))), 16);
				data_length := data_length + value_length-2;
				index := index + 1;
			end loop;
		end;

		procedure sweep (
			variable data         : inout string;
			constant data_offset  : in    natural;
			variable data_length  : inout natural;
			constant object       : in string;
			constant keys         : in string) is
			variable key_length   : natural;
			variable key          : string(keys'range);
			variable value_length : natural;
			variable value        : string(data'range);
			variable index        : natural;
			variable offset       : positive;

		begin
			data_length := 0;
			if object'length=0 then
				return;
			end if;
			index := 0;
			for i in keys'range loop 
				get_value(key, key'left, key_length, keys, index);
				exit when key_length=0;
				get_value(value, value'left, value_length, object, '.' & key(key'left to key'left+key_length-1));
				exit when value_length=0;

				offset := data_offset+data_length;
				data(offset to offset+(value_length-2)-1) := to_string(reverse(to_stdlogicvector(value(value'left to value'left+value_length-1))), 16);
				data_length := data_length + value_length-2;
				index := index + 1;
			end loop;
		end;

		procedure get_device(
			variable value  : inout string;
			variable offset : inout positive;
			variable length : inout natural;
			constant object : in    string) is
			constant keys   : string := 
				"device:["                                                           &
					"bLength,bDescriptorType,bcdUSB,bDeviceClass,bDeviceSubClass,"   &
					"bDeviceProtocol,bMaxPacketSize0,idVendor,idProduct, bcdDevice," &
					"iManufacturer,iProduct,iSerialNumber,bNumConfigurations]";
			constant device : string := object**".device";
			variable value_length : natural;
		begin
			length := 0;
			append(value, value_length, offset, ",content:0x");
			length := length + value_length;
			sweep(value, offset+length, value_length, device, keys);
			length := length + value_length;
			append(value, value_length, offset+length, ",wValue:0x0100");
			length := length + value_length;
			value(offset) := '{';
			append(value, value_length, offset+length, "}");
			length := length + value_length;
		end;

		procedure get_configurations(
			variable value  : inout string;
			variable offset : inout positive;
			variable length : inout natural;
			constant object : in    string) is

			procedure get_configuration(
				variable value  : inout string;
    			constant offset : in    positive;
				variable length : inout natural;
				constant object : in    string) is

    			procedure get_interfaces (
    				variable value  : inout string;
    				constant offset : in    positive;
    				variable length : inout natural;
    				constant object : in    string) is

    				procedure get_interface(
    					variable value  : inout string;
    					constant offset : in    positive;
    					variable length : inout natural;
    					constant object : in    string) is

						procedure get_endpoints(
							variable value  : inout string;
    						constant offset : in    positive;
							variable length : inout natural;
							constant object : in    string) is

    						procedure get_endpoint(
    							variable value  : inout string;
    							constant offset : in    positive;
    							variable length : inout natural;
    							constant object : in    string) is
    							constant keys : string := 
    								"endpoint:["                                                                        &
    									"bLength, bDescriptorType, bEndpointAddress, bmAttibutes, wMaxPacketSize, bInterval]";
    						begin
								length := 0;
								if object'length=0 then
									return;
								end if;
    							sweep(value, offset, length, object, keys);
    						end;

							variable value_length : natural;
							variable index : natural;
						begin
							length := 0;
							if object'length=0 then
								return;
							end if;
							index := 0;
							for i in object'range loop 
								get_endpoint(value, offset+length, value_length, hdo(object)**index);
								length := length + value_length;
								exit when value_length=0;
								index := index + 1;
							end loop;
						end;

    					constant keys : string := 
    						"interface:["                                                                       &
    							"bLength, bDescriptorType, bInterfaceNumber, bAlternateSetting, bNumEndpoints," &
    							"bInterfaceClass, bInterfaceSubClass, bIntefaceProtocol, iInterface]";

						variable value_length : natural;
    				begin
						length := 0;
						if object'length=0 then
							return;
						end if;
						sweep(value, offset+length, value_length, hdo(object)**".interface", keys);
						length := length + value_length;
						if value_length=0 then
							return;
						end if;
						get_endpoints(value, offset+length, value_length, hdo(object)**".endpoints");
						length := length + value_length;
    				end;

    				variable index : natural;
					variable value_length : natural;

    			begin
					length := 0;
					if object'length=0 then
						return;
					end if;
					index := 0;
					for i in object'range loop 
						get_interface(value, offset+length, value_length, object**index);
						length := length + value_length;
						exit when value_length=0;
						index := index + 1;
					end loop;
    			end;

				constant keys : string := 
					"configuration:["                                                               &
						"bLength,bDescriptorType,wTotalLength,bNumInterfaces,bConfigurationValue,"  &
						"iConfiguration,bmAttribute,MaxPower]";
				variable value_length : natural;
			begin
				length := 0;
				if object'length=0 then
					return;
				end if;
				sweep(value, offset+length, value_length, hdo(object)**".configuration", keys);
				length := length + value_length;
				get_interfaces(value, offset+length, value_length, hdo(object)**".interfaces");
				length := length + value_length;
			end;
			constant data : string := ",data:0x";

			constant configurations : string := object**".configurations";

			variable index : natural;
			variable value_length : natural;

		begin
			length := 0;
			if object'length=0 then
				return;
			end if;
			index := 0;
			for i in object'range loop 
				append(value, value_length, offset+length, ",content:0x");
				length := length + value_length;
				get_configuration(value, offset+length, value_length, configurations**index);
				exit when value_length=0;
				length := length + value_length;
				append(value, value_length, offset+length, ",wValue:0x0200");
				length := length + value_length;
				index  := index  + 1;
			end loop;
			value(offset) := '{';
			append(value, value_length, offset+length, "}");
			length := length + value_length;
 		end;

		procedure get_strings(
			variable value  : inout string;
			constant offset : in    positive;
			variable length : inout natural;
			constant object : in    string) is

			procedure get_string (
				variable value  : inout string;
				constant offset : in    positive;
				variable length : inout natural;
				constant object : in    string) is
				constant keys : string := 
					"string:["              &
						"bLength,"          &
						"bDescriptorType]";
			begin
				sweep(value, offset, length, hdo(object)**".string", keys);
			end;

			procedure get_landids(
				variable value   : inout string;
				constant offset : in    positive;
				variable length : inout natural;
				constant object : in    string) is
			begin
				sweep(value, offset, length, hdo(object)**".wLANGID");
			end;

			procedure get_unicodes(
				variable value   : inout string;
				constant offset : in    positive;
				variable length : inout natural;
				constant object : in    string) is

				procedure get_unicode(
					variable value   : inout string;
					constant offset : in    positive;
					variable length : inout natural;
					constant object : in    string) is
					constant keys : string := 
						"unicodes:["                           &
							"bLength," & 
							"bDescriptorType," &
							"bstring]";
					variable value_length : natural;
				begin
					length := 0;
					append(value, value_length, offset+length, "{content:0x");
					length := length + value_length;
					sweep(value, offset+length, value_length, object, keys);
					length := length + value_length;
					if value_length=0 then
						length := 0;
						return;
					end if;
				end;
				constant unicodes : string := object**".unicodes";
				constant lanids   : string := object**".wLANGID";

				variable index : natural;
				variable value_length : natural;
			begin
				length := 0;
				if object'length=0 then
					return;
				end if;
				for i in object'range loop
					get_unicode(value, offset+length, value_length, unicodes**index);
					exit when value_length=0;
					length := length + value_length;
					append(value, value_length, offset+length, ",wValue:0x0300,wIndex:"&lanids**index);
					length := length + value_length;
					append(value, value_length, offset+length, "}");
					length := length + value_length;
					append(value, value_length, offset+length, ",");
					length := length + value_length;
					index  := index  + 1;
				end loop;
				length := length - 1;
			end;

			constant strings : string := object**".strings";
			variable value_length : natural;
		begin
			length := 0;
			append(value, value_length, offset+length, ",content:0x");
			length := length + value_length;
			get_string(value, offset+length, value_length, strings);
			length := length + value_length;
			get_landids(value, offset+length, value_length, strings);
			length := length + value_length;
			append(value, value_length, offset+length, ",wValue:0x0300,wIndex:0x0000");
			length := length + value_length;
			value(offset) := '{';
			append(value, value_length, offset+length, "},");
			length := length + value_length;

			get_unicodes(value, offset+length, value_length, strings);
			length := length + value_length;

		end;

		variable value  : string(object'range);
		variable offset : natural;
		variable length : natural;

	begin
		length := 0;
		offset := value'left;
		append(value, length, offset, "[");
		offset := offset + length;

		get_device(value, offset, length, object);
		offset := offset + length;

		append(value, length, offset, ",");
		offset := offset + length;

		get_configurations(value, offset, length, object);
		offset := offset + length;

		append(value, length, offset, ",");
		offset := offset + length;

		get_strings(value, offset, length, object);
		offset := offset + length;

		append(value, length, offset, "]");
		offset := offset + length;

		return value(value'left to offset-1);

	end;

	function xxx (
		constant description_bin : string)
		return string is
		constant mem_map         : string := segment_map(description_bin);
		constant mem_table       : string := segment_table(mem_map**".table");
		constant num_of_sgmts    : natural := mem_map**".length";

		variable valuew : std_logic_vector(0 to 16*num_of_sgmts-1);
		variable indexw : std_logic_vector(0 to 16*num_of_sgmts-1);
		variable maskw  : std_logic_vector(0 to  1*num_of_sgmts-1);
		variable value  : string(description_bin'range);
		variable wvalue_length : natural;
		variable wvalue : string(1 to 16);
		variable windex_length : natural;
		variable windex : string(1 to 16);
		variable index  : natural;
		variable length : natural;

	begin
		valuew := (others => '0');
		indexw := (others => '0');
		maskw  := (others => '0');
		index := 0;
		for i in 0 to num_of_sgmts-1 loop
			get_value(value, value'left, length, description_bin, index);
			exit when length=0;
			index := index + 1;
			get_value(wvalue, wvalue'left, wvalue_length, value(value'left to value'left+length-1), ".wValue");
			next when wvalue_length=0;
			valuew(i*16 to (i+1)*16-1) := to_stdlogicvector(wvalue(1 to wvalue_length));
			get_value(windex, windex'left, windex_length, value(value'left to value'left+length-1), ".wIndex");
			next when windex_length=0;
			maskw(i) := '1';
			indexw(i*16 to (i+1)*16-1) := to_stdlogicvector(windex(1 to windex_length));
		end loop;
		return '{' 
			& "wValue:0x" & to_string(valuew, 16) & ',' 
			& "wIndex:0x" & to_string(valuew, 16) & ','
			& "mask:0b"   & to_string(maskw,2)  
			& '}';
	end;
end;