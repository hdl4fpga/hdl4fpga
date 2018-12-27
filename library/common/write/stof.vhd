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

library hdl4fpga;
use hdl4fpga.std.all;

entity stof is
	generic (
		minus : std_logic_vector(4-1 downto 0) := x"d";
		plus  : std_logic_vector(4-1 downto 0) := x"c";
		zero  : std_logic_vector(4-1 downto 0) := x"0";
		dot   : std_logic_vector(4-1 downto 0) := x"b";
		space : std_logic_vector(4-1 downto 0) := x"f");
	port (
		clk       : in  std_logic := '-';
		bcd_eddn  : in  std_logic := '0';
		bcd_frm   : in  std_logic := '1';
		bcd_irdy  : in  std_logic := '1';
		bcd_trdy  : out std_logic;
		bcd_left  : in  std_logic_vector;
		bcd_right : in  std_logic_vector;
		bcd_di    : in  std_logic_vector;
		bcd_addr  : out std_logic_vector;
		fix_irdy  : out std_logic;
		fix_trdy  : in  std_logic := '1';
		fix_do    : out std_logic_vector);
end;
		
architecture def of stof is

begin

	fixfmt_p : process (bcd_left, bcd_di)
		variable fmt     : unsigned(fix_do'length-1 downto 0);
		variable codes   : unsigned(bcd_di'length-1 downto 0);
		variable msg     : line;
	begin

		codes := unsigned(bcd_di);
		fmt   := unsigned(fill(value => space, size => fmt'length));

		if signed(bcd_left) < 0 then
			for i in 0 to fmt'length/space'length-1 loop
				if signed(bcd_left) < -i then
					fmt := fmt rol space'length;
					if i=1 then
						fmt(space'range) := unsigned(dot);
					else
						fmt(space'range) := unsigned(zero);
					end if;
				else
					exit;
				end if;
			end loop;
		end if;
		fix_do <= std_logic_vector(fmt);
	end process;

--	process (bcd_right, bcd_di)
--		variable fmt   : unsigned(fix_do'length-1 downto 0);
--		variable codes : unsigned(bcd_di'length-1 downto 0);
--	begin
--		if bcd_frm='0' then
--			fmt := unsigned(fill(value => space, size => fmt'length));
--			for i in 0 to fmt'length/space'length-1 loop
--				if signed(bcd_right) > i then
--					fmt(space'range) := unsigned(zero);
--				else
--					exit;
--				end if;
--				fmt := fmt srl space'length;
--			end loop;
--		end if;
--
--		codes := unsigned(bcd_di);
--		for i in 0 to codes'length/space'length-1 loop
--			fmt(space'range)   := unsigned(codes(space'range));
--			codes(space'range) := unsigned(space);
--			codes := codes ror space'length;
--			if signed(bcd_right)+i = -1 then
--				fmt := fmt ror space'length;
--				fmt(space'range) := unsigned(dot);
--			end if;
--			fmt := fmt srl space'length;
--		end loop;
--
--		align_right <= std_logic_vector(fmt);
--	end process;
	

end;
