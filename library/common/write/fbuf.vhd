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
use hdl4fpga.std.all;

entity fbuf is
	generic (
		space    : std_logic_vector := x"f";
	port (
		clk      : in  std_logic;
		fix_frm  : in  std_logic;
		fix_irdy : in  std_logic;
		fix_trdy : out std_logic := '1';
		fix_di   : out std_logic_vector;
		buf_frm  : out std_logic;
		buf_irdy : out std_logic := '1';
		buf_trdy : in  std_logic := '1';
		buf_do   : out std_logic_vector);
end;

architecture fbuf of testbench is


begin

	process (fix_frm, clk)
		variable buf : unsigned(0 to buf_do'length-1);
		variable rdy : unsigned(0 to buf_do'length/space'length-1);
	begin
		if fix_frm='0' then
			rdy(0) := '1';
			rdy := rdy srl 1;
			buf := unsigned(fill(value => space, size => buf'length));
		elsif rising_edge(clk) then
			if fix_irdy='1' then
				buf := buf rol fix_di'length;
				buf(0 to fix_di'length-1) := unsigned(fix_di);
				rdy := rdy sll 1;
			end if;
		end if;
		buf_tdry <= fix_frm and rdy(0);
		buf_do   <= buf;
	end process;

end;
