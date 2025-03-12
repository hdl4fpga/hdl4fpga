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

entity mul_ser is
	generic (
		lsb : boolean := false);
	port (
		clk  : in  std_logic;
		ena  : in  std_logic := '1';
		req  : in  std_logic;
		rdy  : buffer std_logic;
		comp : in std_logic := '0';
		a    : in  std_logic_vector;
		b    : in  std_logic_vector;
		s    : buffer std_logic_vector);
end;

architecture def of mul_ser is
begin

	process (clk)
		type states is (s_init, s_mul);
		variable state : states;
		variable cntr : unsigned(0 to unsigned_num_bits(b'length-3));
		variable uacc : unsigned(0 to a'length);
		variable up   : unsigned(0 to a'length+b'length-1);
		variable sacc : signed(0 to a'length);
		variable sp   : signed(0 to a'length+b'length-1);
	begin
		if rising_edge(clk) then
			if (to_bit(req) xor to_bit(rdy))='1' then
				if ena='1' then
					case state is
					when s_init =>
						up    := unsigned(resize(unsigned(b), up'length));
						sp    :=   signed(resize(unsigned(b), up'length));
						cntr  := to_unsigned(b'length-3, cntr'length);
						state := s_mul;
					when s_mul =>
						if cntr(0)='0' then
							cntr := cntr - 1;
						else
							rdy   <= req;
							state := s_init;
						end if;
					end case;
					if up(up'right)='0' then
						uacc := (others => '0');
						sacc := (others => '0');
					else
						uacc := resize(unsigned(a), uacc'length);
						sacc := resize(  signed(a), uacc'length);
					end if;
					uacc := uacc + resize(up(0 to a'length-1), uacc'length);
					up   := shift_right(up, 1);
					up(uacc'range) := uacc;
					sacc := sacc + resize(sp(0 to a'length-1), uacc'length);
					sp   := shift_right(sp, 1);
					sp(uacc'range) := sacc;
					if not lsb then
						if comp='0' then
							s <= std_logic_vector(resize(up(0 to hdl4fpga.base.min(s'length,up'length)-1), s'length));
						else
							s <= std_logic_vector(resize(sp(0 to hdl4fpga.base.min(s'length,sp'length)-1), s'length));
						end if;
					else
						if comp='0' then
							s <= std_logic_vector(resize(up, s'length));
						else
							s <= std_logic_vector(resize(sp, s'length));
						end if;
					end if;
				end if;
			else
				state := s_init;
			end if;	
		end if;
	end process;

end;	