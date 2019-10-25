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
		style    => styles(width(30) & alignment(right_alignment)),
		children => 
			div (
				style    => styles(background_color(0) & alignment(right_alignment)),
				children => 
					text(
						style   => styles(background_color(0) & width(8) & alignment(right_alignment)),
						id      => "hzoffset") &
					text(
						style   => styles(background_color(0) & width(3) & alignment(center_alignment)),
						content => ":") &
					text(
						style   => styles(background_color(0) & width(8) & alignment(right_alignment)),
						id      => "hzdiv") &
					text(
						style   => styles(background_color(0) & alignment(center_alignment)),
						content => " ") &
					text(
						style   => styles(background_color(0) & width(1) & alignment(right_alignment)),
						id      => "hzmag") &
					text(
						style   => styles(background_color(0) & alignment(center_alignment)),
						content => "s")) &
			div (
				style    => styles(background_color(0) & alignment(right_alignment)),
				children => 
					text(
						style   => styles(background_color(0) & width(1) & alignment(right_alignment)),
						id      => "tgr_freeze") &
					text(
						style   => styles(background_color(0) & width(1) & alignment(right_alignment)),
						id      => "tgr_edge") &
					text(
						style   => styles(background_color(0) & width(1) & alignment(right_alignment)),
						id      => "tgr_level") &
					text(
						style   => styles(background_color(0) & alignment(center_alignment)),
						content => " ") &
					text(
						style   => styles(background_color(0) & width(2) & alignment(right_alignment)),
						id      => "tgr_div") &
					text(
						style   => styles(background_color(0) & alignment(center_alignment)),
						content => " ") &
					text(
						style   => styles(background_color(0) & width(1) & alignment(right_alignment)),
						id      => "tgr_mag") &
					text(
						style   => styles(background_color(0) & alignment(center_alignment)),
						content => "V")));

	constant xx : tag_vector := render_tags(layout, 1024);
	constant pp : string := render_content(layout, 1024);
begin
	process 
		variable mesg : textio.line;
	begin

--		for i in 0 to pp'length/30-1 loop
--			textio.write(mesg, character'('"'));
--			textio.write(mesg, pp(i*30+1 to (i+1)*30));
--			textio.write(mesg, character'('"'));
--			textio.writeline(textio.output, mesg);
--		end loop;
		textio.write(mesg, width(tagbyid(xx, "tgr_mag")));
--		std_logic_textio.write(mesg, tagvalid_byid(xx, "tgr_mag"));
		textio.writeline(textio.output, mesg);
		wait;
	end process;


end;
