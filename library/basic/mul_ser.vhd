-- Copyright (c) 2015 Miguel Angel Sagreras                                       --
--                                                                                --
-- Permission is hereby granted, free of charge, to any person obtaining a copy   --
-- of this software and associated documentation files (the "Software"), to deal  --
-- in the Software without restriction, including without limitation the rights   --
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      --
-- copies of the Software, and to permit persons to whom the Software is          --
-- furnished to do so, subject to the following conditions:                       --
--                                                                                --
-- The above copyright notice and this permission notice shall be included in all --
-- copies or substantial portions of the Software.                                --
--                                                                                --
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     --
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       --
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    --
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         --
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  --
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  --
-- SOFTWARE.                                                                      --
--                                                                                --

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


