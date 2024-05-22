--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2015                                                         --
--    Miguel Angel Sagreras                                                   --
--                                                                            --
-- This source file may be used and distributed without restriction provided  --
-- that this copyright statement is not removed from the file and that any    --
-- derivative work contains  the original copyright notice and the associated --
-- disclaimer.                                                                --
--                                                                            --
-- This source file is free software; you can redistribute it and/or modify   --
-- it under the terms of the GNU General Public License as published by the   --
-- Free Software Foundation, either version 3 of the License, or (at your     --
-- option) any later version.                                                 --
--                                                                            --
-- This source is distributed in the hope that it will be useful, but WITHOUT --
-- ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or      --
-- FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for   --
-- more details at http://www.gnu.org/licenses/.                              --
--                                                                            --

use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library hdl4fpga;
use work.hdo.all;

architecture hdo_tb of testbench is
    constant inputs : natural := 2;
    signal input_sample  : std_logic_vector(13-1 downto 0);
	constant test      : hdo := 
            "{                             " &   
            "   inputs  :                  " & natural'image(inputs) & ',' &
            "   num_of_segments : 3,       " &
            "   display : {                " &
            "       width  : 1280,         " &
            "       height : 720},         " &
            "   grid : {                   " &
            "       unit   : 32,           " &
            "       width  :               " & natural'image(31*32+1) & ',' &
            "       height :               " & natural'image( 6*32+1) & ',' &
            "       color  : 0xff_ff_00_00, " &
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
            "           unit   : 50.00e-3," &
            "           width  :           " & natural'image(6*8) & ','  &
            "           rotate : ccw0,     " &
            "           inside : false,    " &
            "           color  : 0xff_ff_ff_ff," &
            "           background-color : 0xff_00_00_ff}}," &
            "   textbox : {                " &
            "       font_width :  8,       " &
            "       width      :           " & natural'image(32*6+1) & ','&
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
            "   { text : GN14,            " &
            "     step  : " & real'image(3.3/2.0**(input_sample'length-1)) & "," &
            "     color : 0xff_ff_ff_ff},  " &
            "   { text : GP14,            " &
            "     step  : " & real'image(3.3/2.0**(input_sample'length-1)) & "," &
            "     color : 0xff_ff_ff_00},  " & -- vt(1)
            "   { text : GN15,            " &
            "     step  : " & real'image(3.3/2.0**(input_sample'length-1)) & "," &
            "     color : 0xff_ff_00_ff},  " & -- vt(2)
            "   { text : GP15,            " &
            "     step  : " & real'image(3.3/2.0**(input_sample'length-1)) & "," &
            "     color : 0xff_ff_00_00},  " & -- vt(3)
            "   { text : GN16,            " &
            "     step  : " & real'image(3.3/2.0**(input_sample'length-1)) & "," &
            "     color : 0xff_00_ff_ff},  " & -- vt(4)
            "   { text : GP16,            " &
            "     step  : " & real'image(3.3/2.0**(input_sample'length-1)) & "," &
            "     color : 0xff_00_ff_00},  " & -- vt(5)
            "   { text : GN17,            " &
            "     step  : " & real'image(3.3/2.0**(input_sample'length-1)) & "," &
            "     color : 0xff_00_00_ff},  " & -- vt(6)
            "   { text : GP17,            " &
            "     step  : " & real'image(3.3/2.0**(input_sample'length-1)) & "," &
            "     color : 0xff_ff_ff_ff}]}";   -- vt(7)
	constant max_delay     : natural := 2**14;
	constant vt_step       : real := 1.0/2.0**16; -- Volts
	constant layout      : string := 
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
			"           scales : [         " &
							natural'image(2**(0+0)*5**(0+0)) & "," & -- [0]
							natural'image(2**(0+0)*5**(0+0)) & "," & -- [1]
							natural'image(2**(0+0)*5**(0+0)) & "," & -- [2]
							natural'image(2**(0+0)*5**(0+0)) & "," & -- [3]
							natural'image(2**(0+0)*5**(0+0)) & "," & -- [4]
							natural'image(2**(1+0)*5**(0+0)) & "," & -- [5]
							natural'image(2**(2+0)*5**(0+0)) & "," & -- [6]
							natural'image(2**(0+0)*5**(1+0)) & "," & -- [7]
							natural'image(2**(0+1)*5**(0+1)) & "," & -- [8]
							natural'image(2**(1+1)*5**(0+1)) & "," & -- [9]
							natural'image(2**(2+1)*5**(0+1)) & "," & -- [10]
							natural'image(2**(0+1)*5**(1+1)) & "," & -- [11]
							natural'image(2**(0+2)*5**(0+2)) & "," & -- [12]
							natural'image(2**(1+2)*5**(0+2)) & "," & -- [13]
							natural'image(2**(2+2)*5**(0+2)) & "," & -- [14]
							natural'image(2**(0+2)*5**(1+2)) & "," & -- [15]
			"               length : 16],  " &
			"           unit   : 31.25e-6, " &
			"           height : 8,        " &
			"           inside : false,    " &
			"           color  : 0xff_ff_ff_ff," &
			"           background-color : 0xff_00_00_ff}," &
			"       vertical : {           " &
			"           gains : [         " &
							natural'image(2**17/(2**(0+0)*5**(0+0))) & "," & -- [0]
							natural'image(2**17/(2**(1+0)*5**(0+0))) & "," & -- [1]
							natural'image(2**17/(2**(2+0)*5**(0+0))) & "," & -- [2]
							natural'image(2**17/(2**(0+0)*5**(1+0))) & "," & -- [3]
							natural'image(2**17/(2**(0+1)*5**(0+1))) & "," & -- [4]
							natural'image(2**17/(2**(1+1)*5**(0+1))) & "," & -- [5]
							natural'image(2**17/(2**(2+1)*5**(0+1))) & "," & -- [6]
							natural'image(2**17/(2**(0+1)*5**(1+1))) & "," & -- [7]
							natural'image(2**17/(2**(0+2)*5**(0+2))) & "," & -- [8]
							natural'image(2**17/(2**(1+2)*5**(0+2))) & "," & -- [9]
							natural'image(2**17/(2**(2+2)*5**(0+2))) & "," & -- [10]
							natural'image(2**17/(2**(0+2)*5**(1+2))) & "," & -- [11]
							natural'image(2**17/(2**(0+3)*5**(0+3))) & "," & -- [12]
							natural'image(2**17/(2**(1+3)*5**(0+3))) & "," & -- [13]
							natural'image(2**17/(2**(2+3)*5**(0+3))) & "," & -- [14]
							natural'image(2**17/(2**(0+3)*5**(1+3))) & "," & -- [15]
			"               length : 16],  " &
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
			"   { text  : 'V_P(+) V_N(-)', " &
			"     step  : " & real'image(vt_step) & "," &
			"     color : 0xff_ff_ff_ff},  " &
			"   { text  : 'A6(+)  A7(-)',  " &
			"     step  : " & real'image(vt_step) & "," &
			"     color : 0xff_ff_ff_00},  " & -- vt(1)
			"   { text  : 'A8(+)  A9(-)', " &
			"     step  : " & real'image(vt_step) & "," &
			"     color : 0xff_ff_00_ff},  " & -- vt(2)
			"   { text  : 'A10(+) A11(-)', " &
			"     step  : " & real'image(vt_step) & "," &
			"     color : 0xff_ff_00_00},  " & -- vt(3)
			"   { text  : 'A0(+)',       " &
			"     step  : " & real'image(3.32*vt_step) & "," &
			"     color : 0xff_00_ff_ff},  " & -- vt(4)
			"   { text  : 'A1(+)',       " &
			"     step  : " & real'image(3.32*vt_step) & "," &
			"     color : 0xff_00_ff_00},  " & -- vt(5)
			"   { text  : 'A2(+)',       " &
			"     step  : " & real'image(3.32*vt_step) & "," &
			"     color : 0xff_00_00_ff},  " & -- vt(6)
			"   { text  : 'A3(+)',       " &
			"     step  : " & real'image(3.32*vt_step) & "," &
			"     color : 0xff_ff_ff_ff},  " &  -- vt(7)
			"   { text  : 'A4(+)',           " &
			"     step  : " & real'image(3.32*vt_step) & "," &
			"     color : 0xff_ff_ff_00}]}";   -- vt(8)
    function to_string (
        constant value : std_logic_vector)
        return string is
        variable retval : string(1 to value'length);
        variable j : natural;
    begin
        j := retval'left;
        for i in value'range loop
            if value(i)='1' then
                retval(j) := '1';
            else
                retval(j) := '0';
            end if;
            j := j + 1;
        end loop;
        return retval;
    end;

begin
    process 
		constant xx : string  := "{ h : \'a(0)\ \'s(1) }";
		constant xxx : string := hdo(compact(xx))**".h";
    begin
        -- report "VALUE : " & ''' & real'image(test**"[5].top") & ''';
        -- report "VALUE : " & ''' & ((hso(layout)**".vt")**"[0]")**".step" & ''';

        report '"' & escaped(xxx) & '"';
        wait;
    end process;
end;
