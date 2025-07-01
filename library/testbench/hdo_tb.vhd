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
use hdl4fpga.usbpkg.all;
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
			variable value        : inout string;
			constant offset       : in    natural;
			variable length       : inout natural;
			constant object       : in    string) is
			variable value_offset : positive;
			variable tag_offset   : positive;
			variable tag_length   : natural;
		begin
			length := 0;
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
			
		constant description_bin : string := description(test);
		constant mem_map         : string := segment_map(description_bin);
		constant mem_table       : string := segment_table(mem_map**".table");
		constant num_of_sgmts    : natural := mem_map**".length";

		variable valuew : std_logic_vector(0 to 16*num_of_sgmts-1);
		variable indexw : std_logic_vector(0 to 16*num_of_sgmts-1);
		variable maskw  : std_logic_vector(0 to  1*num_of_sgmts-1);
		variable value  : string(test'range);
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
			report "wValue "  & wvalue(1 to wvalue_length);
			get_value(windex, windex'left, windex_length, value(value'left to value'left+length-1), ".wIndex");
			next when windex_length=0;
			maskw(i) := '1';
			report "wIndex "  & windex(1 to windex_length);
			indexw(i*16 to (i+1)*16-1) := to_stdlogicvector(windex(1 to windex_length));
		end loop;
		report to_string(valuew,16);
		report to_string(indexw,16);
		report to_string(maskw,2);

		wait;
	end process;

end;
