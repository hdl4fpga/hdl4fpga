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

use work.jso.all;

architecture jso_tb of testbench is
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
        constant test : jso :=
           " 720 : {                      " &   
           "    num_of_segments : 3,      " &
           "    display : {               " &
           "         width : 1280,        " &
           "         height : 720},       " &
           "    grid : {                  " &
           "        unit   : 32,          " &
           "        width  : 31,          " &
           "        height :  6},         " &
           "    axis : {                  " &
           "        fontsize   : 8,       " &
           "        horizontal : {        " &
           "            height : 8,       " &
           "            inside : false},  " &
           "        vertical : {          " &
           "            width  :    6,    " &
           "            rotate :  ccw0,   " &
           "            inside : false}}, " &
           "    textbox : {               " &
           "        width      : 32,      " &
           "        font_width :  8,      " &
           "        inside     : false},  " &
           "    main : {                  " &
           "        top        : '.2331e-2'," & 
           "        background-color : 0b10_01,  " &
           "        left       :  3,      " & 
           "        right      :  0,      " & 
           "        bottom     :  0,      " & 
           "        vertical   : 16,      " & 
           "        horizontal : 0},      " &
           "    segment : {               " &
           "        top        : 1,       " &
           "        left       : 1,       " &
           "        right      : 1,       " &
           "        bottom     : 1,       " &
           "        vertical   : 0,       " &
           "        horizontal : 1}       " &
           "}                             ";
    begin
        -- report "VALUE : " & ''' & real'image(test**"[5].top") & ''';
        report "VALUE : " & ''' & to_string(std_logic_vector'(test**".main.background-color")) & ''';
        wait;
    end process;
end;
