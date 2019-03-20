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
use ieee.std_logic_textio.all;

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
		frm       : in  std_logic;

		bcd_irdy  : in  std_logic := '1';
		bcd_trdy  : out std_logic;
		bcd_left  : in  std_logic_vector;
		bcd_right : in  std_logic_vector;
		bcd_prec  : in  std_logic_vector := (0 to 0 => 'U');
		bcd_di    : in  std_logic_vector;
		bcd_end   : out std_logic;

		mem_addr  : out std_logic_vector;
		mem_do    : out std_logic_vector);
end;
		
architecture def of stof is
begin

	process (clk)
		variable ptr   : signed(bcd_left'range);
		variable left  : signed(bcd_left'range);
		variable right : signed(bcd_right'range);
		variable prec  : signed(bcd_right'range);
		variable point : std_logic;
		type states is (s1, s2);
		variable state : states;
	begin
		if rising_edge(clk) then
			if frm='0' then
				right := signed(bcd_right);
				left  := signed(bcd_left);
				if left < 0 then
					left := (others => '0');
				end if;
				ptr   := left;
				point := '0';
				prec  := right;
				state := s1;
				bcd_trdy <= '0';
				bcd_end  <= '0';
			else
				case state is
				when s1 =>
					bcd_trdy <= '0';
					if bcd_irdy='1' then
						if ptr = -1 then
							if point='0' then
								mem_do <= dot;
								point  := '1';
							else
								if ptr > left then
									mem_do <= zero;
								else
									mem_do <= bcd_di;
								end if;
								if ptr = prec then
									bcd_end <= '1';
								end if;
								point := '0';
								ptr   := ptr - 1;
							end if;
						elsif ptr > left then
							mem_do <= zero;
							point  := '0';
							ptr    := ptr - 1;
						elsif ptr >= prec then
							if ptr >= right then
								mem_do <= bcd_di;
							elsif ptr > prec then
								mem_do <= zero;
							end if;
							if ptr = prec then
								bcd_end <= '1';
							end if;
							point := '0';
							ptr   := ptr - 1;
						else
							mem_do <= zero;
						end if; 
						state := s2;
					end if;
				when s2 =>
					bcd_trdy <= '1';
					state    := s1;
				end case;
			end if;
			mem_addr <= std_logic_vector(ptr);
		end if;
	end process;

end;
