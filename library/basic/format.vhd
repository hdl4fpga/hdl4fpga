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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;

entity format is
	port (
		code_blank : in  std_logic_vector := to_ascii(" ");
		code_tab   : in  std_logic_vector := to_ascii("0123456789");
		bcd        : in  std_logic_vector;
		code       : out std_logic_vector);

	constant bcd_length  : natural := 4;
	constant code_length : natural := code'length*bcd_length/bcd'length;
end;

architecture def of format is
begin
	process (code_blank, code_tab, bcd)
		variable bcd_shr  : unsigned(0 to bcd'length-1);
		variable code_shr : unsigned(0 to code'length-1);
		variable blank    : boolean;
	begin
		bcd_shr := unsigned(bcd);
		blank := true;
		blank_l : for i in 0 to bcd'length/bcd_length-1 loop
			if bcd_shr(0 to bcd_length-1)=x"0" and blank then
				code_shr(0 to code_length-1) := unsigned(code_blank);
			else
				code_shr(0 to code_length-1) := unsigned(multiplex(code_tab, std_logic_vector(bcd_shr(0 to bcd_length-1)), code'length*bcd_length/bcd'length));
				blank := false;
			end if;
			code_shr := rotate_left(code_shr, code_length);
			bcd_shr  := rotate_left(bcd_shr, bcd_length);
		end loop;

		align_left_l : for i in 0 to bcd'length/bcd_length-1 loop
			if code_shr(0 to code_length-1) = unsigned(code_blank) then
				code_shr := rotate_left(code_shr, code_length);
			else
				exit;
			end if;
		end loop;
		code <= std_logic_vector(code_shr);
	end process;
end;