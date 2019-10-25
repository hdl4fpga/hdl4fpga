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
						id      => "hz.offset") &
					text(
						style   => styles(background_color(0) & width(3) & alignment(center_alignment)),
						content => ":") &
					text(
						style   => styles(background_color(0) & width(8) & alignment(right_alignment)),
						id      => "hz.div") &
					text(
						style   => styles(background_color(0) & alignment(center_alignment)),
						content => " ") &
					text(
						style   => styles(background_color(0) & width(1) & alignment(right_alignment)),
						id      => "hz.mag") &
					text(
						style   => styles(background_color(0) & alignment(center_alignment)),
						content => "s")) &
			div (
				style    => styles(background_color(0) & alignment(right_alignment)),
				children => 
					text(
						style   => styles(background_color(0) & width(1) & alignment(right_alignment)),
						id      => "tgr.freeze") &
					text(
						style   => styles(background_color(0) & width(1) & alignment(right_alignment)),
						id      => "tgr.edge") &
					text(
						style   => styles(background_color(0) & width(1) & alignment(right_alignment)),
						id      => "tgr.level") &
					text(
						style   => styles(background_color(0) & alignment(center_alignment)),
						content => " ") &
					text(
						style   => styles(background_color(0) & width(2) & alignment(right_alignment)),
						id      => "tgr.div") &
					text(
						style   => styles(background_color(0) & alignment(center_alignment)),
						content => " ") &
					text(
						style   => styles(background_color(0) & width(1) & alignment(right_alignment)),
						id      => "tgr.mag") &
					text(
						style   => styles(background_color(0) & alignment(center_alignment)),
						content => "V")));

	function analogreadings (
		constant inputs : natural)
		return tag_vector
	is
		constant tags0 : tag_vector := div (
			style    => styles(background_color(0) & alignment(right_alignment)),
			children => 
				text(
					style   => styles(background_color(0) & width(8) & alignment(right_alignment)),
					id      => "vt(" & itoa(0) & ").offset") &
				text(
					style   => styles(background_color(0) & width(3) & alignment(center_alignment)),
					content => ":") &
				text(
					style   => styles(background_color(0) & width(8) & alignment(right_alignment)),
					id      => "vt("& itoa(0) & ").div" ) &
				text(
					style   => styles(background_color(0) & alignment(center_alignment)),
					content => " ") &
				text(
					style   => styles(background_color(0) & width(1) & alignment(right_alignment)),
					id      => "vt("& itoa(0) & ").mag") &
				text(
					style   => styles(background_color(0) & alignment(center_alignment)),
					content => "V"));
		variable tags : tag_vector(0 to inputs*tags0'length-1);
	begin
		tags(tags0'range) := tags0;
		for i in 1 to inputs-1 loop
			tags(i*tags0'length to (i+1)*tags0'length-1) := div (
				style    => styles(background_color(0) & alignment(right_alignment)),
				children => 
					text(
						style   => styles(background_color(0) & width(8) & alignment(right_alignment)),
						id      => "vt(" & itoa(i) & ").offset") &
					text(
						style   => styles(background_color(0) & width(3) & alignment(center_alignment)),
						content => ":") &
					text(
						style   => styles(background_color(0) & width(8) & alignment(right_alignment)),
						id      => "vt("& itoa(i) & ").div" ) &
					text(
						style   => styles(background_color(0) & alignment(center_alignment)),
						content => " ") &
					text(
						style   => styles(background_color(0) & width(1) & alignment(right_alignment)),
						id      => "vt("& itoa(i) & ").mag") &
					text(
						style   => styles(background_color(0) & alignment(center_alignment)),
						content => "V"));
		end loop;
		return tags;
	end;

	constant xx : tag_vector := render_tags(layout & analogreadings(20), 1024);
	constant pp : string := render_content(layout & analogreadings(20), 1024);

begin
	process 
		variable mesg : textio.line;
	begin

		for i in 0 to pp'length/30-1 loop
			textio.write(mesg, character'('"'));
			textio.write(mesg, pp(i*30+1 to (i+1)*30));
			textio.write(mesg, character'('"'));
			textio.writeline(textio.output, mesg);
		end loop;
		std_logic_textio.write(mesg, tagvalid_byid(xx, "vt(20).offset"));
		textio.writeline(textio.output, mesg);
		wait;
	end process;


end;
