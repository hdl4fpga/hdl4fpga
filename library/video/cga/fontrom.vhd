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

entity fontrom is
	generic (
		bitrom : std_logic_vector;		-- Font Bit Rom
		height : natural;				-- Character Height
		width  : natural;				-- Character Width

		row_reverse : boolean := false;
		col_reverse : boolean := false;
		row_offset  : integer := 0;
		col_offset  : integer := 0);
	port (
		clk  : in std_logic;
		code : in std_logic_vector;
		row  : in std_logic_vector;
		data : out std_logic_vector(0 to width-1));

	constant num_of_char : natural := bitrom'length/(width*height);
end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture def of fontrom is

	subtype word is std_logic_vector(width-1 downto 0);
	type word_vector is array (natural range <>) of word;

	function cgadata (
		constant arg : in std_logic_vector)
		return word_vector is

		variable data : std_logic_vector(0 to arg'length-1);
		variable val  : word_vector(num_of_char*height-1 downto 0);
		variable addr : natural;
		variable line : word;

	begin 
		data := arg;
		for i in val'range loop
			line := data(i*width to (i+1)*width-1);

			addr := i mod height;
			if row_reverse then
				addr := (height+row_offset-addr) mod height;
			else
				addr := (height+row_offset+addr) mod height;
			end if;
			addr := (i/height)*height + addr;

			if col_reverse then
				val(addr) := reverse(line);
			else
				val(addr) := line;
			end if;
			val(addr) := std_logic_vector(unsigned(val(addr)) rol col_offset);
		end loop;
		return val;
	end;

	constant rom : word_vector(num_of_char*height-1 downto 0) := cgadata(bitrom);

begin

	process (clk)
	begin
		if rising_edge(clk) then
			data <= rom(to_integer(unsigned(std_logic_vector'(code & row))));
		end if;
	end process;

end;
