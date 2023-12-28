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
begin
	process 
		constant test : string :=
			"{"                             &
		    	"display : {width : 1280, height : 720 }," &
		    	"num_of_segments   :    3, " &
		    	"division_size     :   32, " &
		    	"grid : {width : 31, height :  6}, " &
		    	"axis_fontsize     :    8, " &
		    	"hzaxis_height     :    8, " &
		    	"hzaxis_within     : false," &
		    	"vtaxis_width      :    6, " &
		    	"vtaxis_inside     : false," &
		    	"vttick_rotate     :  ccw0," &
		    	"textbox_fontwidth :    8, " &
		    	"textbox_width     :   32, " &
		    	"textbox_inside    : false," &
		    	"main    : {left : 3, top : 23, right : 0, bottom : 0, vertical :16, horizontal : 0}," &
		    	"segment : {left : 1, top :  1, right : 1, bottom : 1, vertical : 0, horizontal : 1} " &
			"}";
	begin
--		                                            11111111112222222222333333333333333333334444444444
--		                                   12345678901234567890123456789012345678901234567890123456789
		report "VALUE : " & ''' & resolve(test & "[main][vertical]") & ''';
		wait;
	end process;
end;
