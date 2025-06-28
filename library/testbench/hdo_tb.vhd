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

use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library hdl4fpga;
-- use hdl4fpga.hdo.all;
use hdl4fpga.base.all;
-- use hdl4fpga.usbpkg.all;
use work.hdo.all;

architecture hdo_tb of testbench is
	constant inputs    : natural := 2;
	constant max_delay : natural := 2**14;
	constant vt_step   : real := 1.0/2.0**16; -- Volts
	constant test : string := compact      ("{"     &
		"device:{"                                  &
			"bLength             :0x12,"            &
			"bDescriptorType     :0x01,"            &
			"bcdUSB              :0x0110,"          &
			"bDeviceClass        :0x00,"            &
			"bDeviceSubClass     :0x00,"            &
			"bDeviceProtocol     :0x00,"            &
			"bMaxPacketSize0     :0x40,"            &
			"idVendor            :0x1234,"          &
			"idProduct           :0xabcd,"          &
			"bcdDevice           :0x0100,"          &
			"iManufacturer       :0x01,"            &
			"iProduct            :0x00,"            &
			"iSerialNumber       :0x00,"            &
			"bNumConfigurations  :0x01},"           &
		"configurations:[{"                         &
			"configuration:{"                       &
			"bLength             :0x09,"            &
			"bDescriptorType     :0x02,"            &
			"wTotalLength        :0x0020,"          &
			"bNumInterfaces      :0x01,"            &
			"bConfigurationValue :0x01,"            &
			"iConfiguration      :0x00,"            &
			"bmAttribute         :0xc0,"            &
			"MaxPower            :0x32},"           &
			"interfaces:[{"                         &
				"interface:{"                       &
				"bLength            :0x09,"         &
				"bDescriptorType    :0x04,"         &
				"bInterfaceNumber   :0x00,"         &
				"bAlternateSetting  :0x00,"         &
				"bNumEndpoints      :0x02,"         &
				"bInterfaceClass    :0x00,"         &
				"bInterfaceSubClass :0x00,"         &
				"bIntefaceProtocol  :0x00,"         &
				"iInterface         :0x00},"        &
				"endpoints:[{"                      &
					"bLength          :0x07,"       &
					"bDescriptorType  :0x05,"       &
					"bEndpointAddress :0x01,"       &
					"bmAttibutes      :0x02,"       &
					"wMaxPacketSize   :0x0040,"     &
					"bInterval        :0x00},"      &
					"{"                             &
					"bLength          :0x07,"       &
					"bDescriptorType  :0x05,"       &
					"bEndpointAddress :0x81,"       &
					"bmAttibutes      :0x02,"       &
					"wMaxPacketSize   :0x0040,"     &
					"bInterval        :0x00}]}]}]," &
		"strings:["                                 &
			"string:{"                              &
				"bLength             :0x04,"        &
				"bDescriptorType     :0x03},"       &
			"wLANGID:["                             &
				"0x0409],"                          &
			"unicodes:[{"                           &
				"bLength            :0x12," & 
				"bDescriptorType    :0x03," &
				"bstring            :0x"&to_string(to_utf16("HDL4FPGA"),16)&"}]]}");

	function to_string (
		constant value : std_logic_vector)
		return string is
		variable retval : string(1 to value'length);
		variable n : natural;
	begin
		n := retval'left;
		for i in value'range loop
			if value(i)='1' then
				retval(n) := '1';
			else
				retval(n) := '0';
			end if;
			n := n + 1;
		end loop;
		return retval;
	end;

begin
	process

		procedure get_value (
			variable value    : inout string;
			variable length   : inout natural;
			constant object   : in    string) is
			variable offset     : positive;
			variable tag_offset : positive;
			variable tag_length : natural;
		begin
			resolve(object, offset, length, tag_offset, tag_length);
			if length/=0 then
				value(value'left to value'left+length-1) := object(offset to offset+length-1);
			end if;
		end;
			
		procedure get_value (
			variable value    : inout string;
			variable length   : inout natural;
			constant object   : in    string;
			constant position : in    natural) is
			constant key        : string := '[' & natural'image(position) & ']';
			constant expression : string := object & key;
		begin
			get_value(value, length, expression);
		end;
			
		procedure get_value (
			variable value    : inout string;
			variable length   : inout natural;
			constant object   : in    string;
			constant key      : in    string) is
			constant expression : string := object & key;
			variable offset     : positive;
			variable tag_offset : positive;
			variable tag_length : natural;
		begin
			get_value(value, length, expression);
		end;
			
		procedure sweep (
			variable data          : inout string;
			variable data_position : inout natural;
			variable data_length   : inout natural;
			constant object        : in    string) is
			variable value_length  : natural;
			variable value         : string(data'range);
			variable position      : natural;
		begin
			data_length := 0;
			if object'length=0 then
				return;
			end if;
			position := 0;
			for i in object'range loop 
				get_value(value, value_length, object, position);
				exit when value_length=0;

				data_length := value_length-2;
				data(data_position to data_position+data_length-1) := to_string(reverse(to_stdlogicvector(value(value'left to value'left+value_length-1))), 16);
				data_position := data_position+data_length;
				position := position + 1;
			end loop;
		end;

		procedure sweep (
			variable data          : inout string;
			variable data_position : inout natural;
			variable data_length   : inout natural;
			constant object        : in string;
			constant keys          : in string) is
			variable key_length    : natural;
			variable key           : string(keys'range);
			variable value_length  : natural;
			variable value         : string(data'range);
			variable position      : natural;
		begin
			data_length := 0;
			if object'length=0 then
				return;
			end if;
			position    := 0;
			data_length := 0;
			for i in keys'range loop 
				get_value(key, key_length, keys, position);
				exit when key_length=0;
				get_value(value, value_length, object, '.' & key(key'left to key'left+key_length-1));
				exit when value_length=0;

				data_length := value_length-2;
				data(data_position to data_position+data_length-1) := to_string(reverse(to_stdlogicvector(value(value'left to value'left+value_length-1))), 16);
				data_position := data_position+data_length;
				position := position + 1;
			end loop;
			data_position := data_position + data_length;
			data_length := 0;
		end;

		procedure get_device(
			variable data   : inout string;
			variable offset : inout positive;
			variable length : inout natural;
			constant object : in string) is
			constant keys : string := 
				"device:["                                                               &
					"bLength, bDescriptorType, bcdUSB, bDeviceClass, bDeviceSubClass,"   &
					"bDeviceProtocol, bMaxPacketSize0, idVendor, idProduct, bcdDevice,"  &
					"iManufacturer, iProduct,iSerialNumber, bNumConfigurations]";
			constant device : string := object**".device";
		begin
			sweep(data, offset, length, device, keys);
		end;

		procedure get_configurations(
			variable value  : inout string;
			variable offset : inout positive;
			variable length : inout natural;
			constant object : in    string) is

			procedure get_configuration(
				variable value  : inout string;
				variable offset : inout positive;
				variable length : inout natural;
				constant object : in    string) is

    			procedure get_interfaces (
    				variable value  : inout string;
    				variable offset : inout positive;
    				variable length : inout natural;
    				constant object : in    string) is

    				procedure get_interface(
    					variable value  : inout string;
    					variable offset : inout positive;
    					variable length : inout natural;
    					constant object : in    string) is

						procedure get_endpoints(
							variable value  : inout string;
							variable offset : inout positive;
							variable length : inout natural;
							constant object : in    string) is

    						procedure get_endpoint(
    							variable value  : inout string;
    							variable offset : inout positive;
    							variable length : inout natural;
    							constant object : in    string) is
    							constant keys : string := 
    								"endpoint:["                                                                        &
    									"bLength, bDescriptorType, bEndpointAddress, bmAttibutes, wMaxPacketSize, bInterval]";
    						begin
    							sweep(value, offset, length, object, keys);
    						end;

							variable index : natural;
						begin
							index := 0;
							for i in object'range loop 
								get_endpoint(value, offset, length, hdo(object)**index);
								exit when length=0;
								index := index + 1;
							end loop;
						end;

    					constant keys : string := 
    						"interface:["                                                                       &
    							"bLength, bDescriptorType, bInterfaceNumber, bAlternateSetting, bNumEndpoints," &
    							"bInterfaceClass, bInterfaceSubClass, bIntefaceProtocol, iInterface]";

    				begin
						sweep(value, offset, length,  hdo(object)**".interface", keys);
						if length=0 then
							return;
						end if;
						get_endpoints(value, offset, length, hdo(object)**".endpoints");
    				end;

    				variable index : natural;

    			begin
					index  := 0;
					for i in test'range loop 
						get_interface(value, offset, length, object**index);
						exit when length=0;
						index := index + 1;
					end loop;
    			end;
				constant keys : string := 
					"configuration:["                                                                   &
						"bLength, bDescriptorType, wTotalLength, bNumInterfaces, bConfigurationValue,"  &
						"iConfiguration, bmAttribute, MaxPower]";
			begin
				sweep(value, offset, length, hdo(object)**".configuration", keys);
				get_interfaces(value, offset, length, hdo(object)**".interfaces");
			end;

			variable index : natural;
			constant configurations : string := object**".configurations";
		begin
			length := 0;
			index  := 0;
			for i in test'range loop 
				get_configuration(value, offset, length, configurations**index);
				exit when length=0;
				index := index + 1;
			end loop;
 		end;

		procedure get_strings(
			variable value  : inout string;
			variable offset : inout positive;
			variable length : inout natural;
			constant object : in    string) is

			procedure get_string (
				variable value   : inout string;
				variable offset : inout positive;
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
				variable offset : inout positive;
				variable length : inout natural;
				constant object : in    string) is
			begin
				sweep(value, offset, length, hdo(object)**".wLANGID");
			end;

			procedure get_unicodes(
				variable value   : inout string;
				variable offset : inout positive;
				variable length : inout natural;
				constant object : in    string) is

				procedure get_unicode(
					variable value   : inout string;
					variable offset : inout positive;
					variable length : inout natural;
					constant object : in    string) is
					constant keys : string := 
						"unicodes:["                           &
							"bLength," & 
							"bDescriptorType," &
							"bstring]";
				begin
					sweep(value, offset, length, object, keys);
				end;
				constant unicodes : string := object**".unicodes";

				variable index : natural;
			begin
				for i in object'range loop
					get_unicode(value, offset, length, unicodes**index);
					exit when length=0;
					index := index + 1;
				end loop;
			end;

			constant strings : string := object**".strings";
		begin
			get_string(value, offset, length, strings);
			get_landids(value, offset, length, strings);
			get_unicodes(value, offset, length, strings);
		end;

		variable value  : string(1 to 1024);
		variable offset : natural;
		variable length : natural;
	begin
		offset := value'left;
		get_device(value, offset, length, test);
		get_configurations(value, offset, length, test);
		get_strings(value, offset, length, test);
		report natural'image(length);
		report value(1 to offset+length-1);
		-- report segment_map(xxx(test));
		-- report segment_table(segment_map(xxx(test))**".table");
		-- report segment_map(xxx(test));
		wait;
	end process;

end;
