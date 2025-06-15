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
use hdl4fpga.hdo.all;
-- use work.hdo.all;

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
					"Interval         :0x00}]}]}]," &
		"strings:["                                 &
			"string:{"                              &
				"bLength             :0x04,"        &
				"bDescriptorType     :0x03},"       &
			"wLANGID:["                             &
				"0x0409],"                          &
			"unicodes:[{"                           &
				"bLength            :0x12," & 
				"bDescriptorType    :0x03," &
				"bstring            :HDL4FPGA}]]}");

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
		constant ubskeys : string := compact("{"                                                       &
			"device:["                                                                                 &
				"bLength, bDescriptorType, bcdUSB, bDeviceClass, bDeviceSubClass,"                     &
				"bDeviceProtocol, bMaxPacketSize0, idVendor, idProduct, bcdDevice,"                    &
				"iManufacturer, iProduct,iSerialNumber, bNumConfigurations],"                          &
			"configurations:["                                                                         &
				"configuration, interfaces],"                                                          &
			"configuration:["                                                                          &
				"bLength, bDescriptorType, wTotalLength, bNumInterfaces, bConfigurationValue,"         &
				"iConfiguration, bmAttribute, MaxPower],"                                              &
			"configurations:["                                                                         &
				"configuration, interfaces],"                                                          &
			"interfaces:["                                                                             &
				"interface, endpoints],"                                                               &
			"interface:["                                                                              &
				"bLength, bDescriptorType, bInterfaceNumber, bAlternateSetting, bNumEndpoints,"        &
				"bInterfaceClass, bInterfaceSubClass, bIntefaceProtocol, iInterface],"                 &
			"endpoints:["                                                                              &
				"endpoint],"                                                                           &
			"endpoint:["                                                                               &
				"bLength, bDescriptorType, bEndpointAddress, bmAttibutes, wMaxPacketSize, bInterval]," &
			"string:["                                                                                 &
				"bLength, bDescriptorType],"                                                           &
			"strings:["                                                                                &
				"string, wLANGID, unicodes],"                                                          &
			"unicode:["                                                                                &
				"bLength, bDescriptorType, bstring]}");

		procedure get_value (
			variable value  : out string;
			variable length : out natural;
			constant obj    : in  string) is
			constant escobj : string := escaped(obj);
		begin
			length := escobj'length;
			if escobj'length > 0 then
				value(1 to escobj'length) := escobj;
			end if;
		end;
			
		procedure sweep (
			constant object : in string;
			constant keys   : in string) is
			variable key_length    : natural;
			variable key           : string(1 to 1024);
			variable value_length  : natural;
			variable value         : string(1 to 1024);
			variable n             : natural;
		begin
			n := 0;
			loop 
				get_value(key, key_length, hdo(keys)**("["&natural'image(n)&"]"));
				exit when key_length=0;
				get_value(value, value_length, hdo(object)**("."&key(1 to key_length)));
				exit when value_length=0;
				report key(1 to key_length) & " : " & '"' & value(1 to value_length) & '"';
				n := n + 1;
			end loop;
		end;

		variable value_length : natural;
		variable value        : string(1 to 2048);
		variable n : natural;
		variable i : natural;
		variable j : natural;
		variable k : natural;

	begin
		n := 0;
		loop
			get_value(value, value_length, tag(hdo(test)&"["&natural'image(n)&"]"));
			exit when value_length=0;
			report '"' & value(1 to value_length) & '"';
			if value(1 to value_length)="device" then
				sweep(hdo(test)**("."&value(1 to value_length)), hdo(ubskeys)**(".device"));
			elsif value(1 to value_length)="configurations" then
				i := 0;
				loop
					get_value(value, value_length, hdo(test)**(".configurations"&"["&natural'image(i)&"]"&".configuration"));
					exit when value_length=0;
					sweep(value(1 to value_length), hdo(ubskeys)**(".configuration"));
					j := 0;
					loop
						get_value(value, value_length, hdo(test)**(".configurations"&"["&natural'image(i)&"].interfaces"&"["&natural'image(j)&"].interface"));
						exit when value_length=0;
						sweep(value(1 to value_length), hdo(ubskeys)**".interface");
						k := 0;
						loop
							get_value(value, value_length, hdo(test)**(".configurations"&"["&natural'image(i)&"].interfaces"&"["&natural'image(j)&"].endpoints"&"["&natural'image(k)&"]"));
							exit when value_length=0;
							sweep(value(1 to value_length), hdo(ubskeys)**".endpoint");
							k := k + 1;
						end loop;
						j := j + 1;
					end loop;
					i := i + 1;
				end loop;
			elsif value(1 to value_length)="strings" then
				i := 0;
				loop
					get_value(value, value_length, hdo(ubskeys)**(".strings"&"["&natural'image(i)&"]"));
					exit when value_length=0;
					report value(1 to value_length);
					if value(1 to value_length)="string" then
						sweep(hdo(test)**("."&"strings.string"), hdo(ubskeys)**(".string"));
					elsif value(1 to value_length)="wLANGID" then
						j := 0;
						loop
							get_value(value, value_length, hdo(test)**(".strings.wLANGID"&"["&natural'image(j)&"]"));
							exit when value_length=0;
							report value(1 to value_length);
							j := j + 1;
						end loop;
					elsif value(1 to value_length)="unicodes" then
						j := 0;
						loop
							get_value(value, value_length, hdo(test)**(".strings.unicodes"&"["&natural'image(j)&"]"));
							exit when value_length=0;
							sweep(value(1 to value_length), hdo(ubskeys)**".unicode");
							j := j + 1;
						end loop;
					end if;
					i := i + 1;
				end loop;
				exit;
			end if;
			n := n + 1;
		end loop;
		wait;
	end process;
end;
