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

use work.hdo.all;

architecture hdo_tb of testbench is
    constant inputs    : natural := 2;
	constant max_delay : natural := 2**14;
	constant vt_step   : real := 1.0/2.0**16; -- Volts
	constant test      : string := compact(
			"{                             " &   
			"   inputs          : " & natural'image(inputs) & ',' &
			"   max_delay       : " & natural'image(max_delay)  & ',' &
			"   min_storage     : 256,     " & -- samples, storage size will be equal or larger than this
			"   num_of_segments :   3,     " &
			"   display : {                " &
			"       width  : 1280,         " &
			"       height : 720},         " &
			"   grid : {                   " &
			"       unit   : 32,           " &
			"       width  : " & natural'image(31*32+1) & ',' &
			"       height : " & natural'image( 6*32+1) & ',' &
			"       color  : 0xff_ff_00_00," &
			"       background-color : 0xff_00_00_00}," &
			"   axis : {                   " &
			"       fontsize   : 8,        " &
			"       horizontal : {         " &
			"           unit   : 31.25e-6, " &
			"           height : 8,        " &
			"           inside : false,    " &
			"           color  : 0xff_ff_ff_ff," &
			"           background-color : 0xff_00_00_ff}," &
			"       vertical : {           " &
			"           unit   : 500.00e-6, " &
			"           width  : " & natural'image(6*8) & ','  &
			"           rotate : ccw0,     " &
			"           inside : false,    " &
			"           color  : 0xff_ff_ff_ff," &
			"           background-color : 0xff_00_00_ff}}," &
			"   textbox : {                " &
			"       font_width :  8,       " &
			"       width      : " & natural'image(32*4+1) & ','&
			"       inside     : false,    " &
			"       color      : 0xff_ff_ff_ff," &
			"       background-color : 0xff_00_00_00}," &
			"   main : {                   " &
			"       top        : 23,       " & 
			"       left       :  3,       " & 
			"       right      :  0,       " & 
			"       bottom     :  0,       " & 
			"       vertical   : 16,       " & 
			"       horizontal :  0,       " &
			"       background-color : 0xff_00_00_00}," &
			"   segment : {                " &
			"       top        : 1,        " &
			"       left       : 1,        " &
			"       right      : 1,        " &
			"       bottom     : 1,        " &
			"       vertical   : 0,        " &
			"       horizontal : 1,        " &
			"       background-color : 0xff_00_00_00}," &
			"  vt : [                      " &
			"   { text  : J3,        " &
			"     step  : " & real'image(vt_step) & ","  &
			"     color : 0xff_00_ff_ff},  " &
			"   { text  : J4,        " &
			"     step  : " & real'image(vt_step) & ","  &
			"     color : 0xff_ff_ff_ff}]}");

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
		constant obj : string := compact(hdo(test))**".vt";
    begin
        -- report LF & '"' & string'(hdo(obj)**"[1].text1=ffff.") & '"';
        report LF & '"' & work.hdo.tag(hdo(obj)&"[1][0]") & '"';
        wait;
    end process;
end;
