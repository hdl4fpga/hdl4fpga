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

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.textboxpkg.all;
use hdl4fpga.scopeiopkg.all;

entity main is
end;

architecture def of main is

	constant w : natural := 32;

begin
	process 
		constant tags : tag_vector := render_tags(
			analogreadings(
				style  => styles(width(40) & alignment(right_alignment)),
				inputs => 5));

		constant cc : attr_table := tagattr_tab(tags, key_textcolor);
		variable mesg : textio.line;
	begin

		report itoa(cc'length);
		for i in cc'range loop
			textio.write (mesg, "addr : " & itoa(cc(i).addr) & " attr : " & itoa(cc(i).attr));
			textio.writeline (textio.output, mesg);
		end loop;
		wait;
	end process;


end;
