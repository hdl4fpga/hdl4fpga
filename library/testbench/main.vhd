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
use hdl4fpga.scopeiopkg.all;

entity main is
	port (
		tp : buffer std_logic := '1');
end;

architecture def of main is

	constant w : natural := 32;
	constant xx : tag_vector := render_tags(analogreadings(styles(width(w) & alignment(right_alignment)), 2));
--	constant pp : string     := render_content(analogreadings(styles(width(w) & alignment(right_alignment)), 2), 1024);

begin
	process 
		variable mesg : textio.line;
	begin

--		for i in 0 to pp'length/w-1 loop
--			textio.write(mesg, character'('"'));
--			textio.write(mesg, pp(i*w+1 to (i+1)*w));
--			textio.write(mesg, character'('"'));
--			textio.writeline(textio.output, mesg);
--		end loop;
--		textio.writeline(textio.output, mesg);
		wait;
	end process;


end;
