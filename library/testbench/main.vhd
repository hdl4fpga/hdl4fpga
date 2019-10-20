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

use std.textio;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio;
use ieee.math_real.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.textboxpkg.all;

entity main is
	port (
		tp : buffer std_logic := '1');
end;

architecture def of main is

	constant layout : tag_vector := page(
		style    => styles(width(40)),
		children => 
			div (
				style    => styles(background_color(0) & alignment(center_alignment)),
				children => 
					text(
						style   => styles(background_color(0) & width(8) & alignment(right_alignment)),
						content => "hola",
						id      => "hzoffset") &
					text(
						style   => styles(background_color(0) & width(8) & alignment(center_alignment)),
						content => "hola",
						id      => "hzoffset")) &
			div (
				style    => styles(background_color(0) & alignment(center_alignment)),
				children => 
					text(
						style   => styles(background_color(0) & width(8) & alignment(right_alignment)),
						content => "hola1",
						id      => "hzoffset") &
					text(
						style   => styles(background_color(0) & width(8) & alignment(center_alignment)),
						content => "hola2",
						id      => "hzoffset")));

	constant pp : string := browse (layout);
begin
	process 
		variable mesg : textio.line;
	begin

		textio.write(mesg, character'('"'));
		textio.write(mesg, pp);
		textio.write(mesg, character'('"'));
		textio.writeline(textio.output, mesg);
		wait;
	end process;


end;
