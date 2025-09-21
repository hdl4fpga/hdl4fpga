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

entity devmux is
	generic (
		n    : natural;
		m    : natural := 1);
	port (
		clk  : in std_ulogic;
		ena  : in std_ulogic := '1';
		reqs : in std_logic_vector(0 to n-1);
		rdys : buffer std_logic_vector(0 to n-1) := (others => '0');
		gntd : out  std_logic_vector(0 to n-1);
		di   : in std_logic_vector(0 to n*m-1) := (others => '-');
		req  : buffer std_ulogic;
		rdy  : in std_ulogic;
		do   : out std_logic_vector(0 to m-1));
end;

architecture def of devmux is
	signal id : natural range 0 to reqs'length-1;
begin
	arbiter_p : process (clk)
		type states is (s_rdy, s_req);
		variable state : states;
	begin
		if rising_edge(clk) then
			if ena='1' then
				case state is
				when s_rdy =>
					gntd <= (others => '0');
					for i in reqs'range loop
						if (rdys(i) xor reqs(i))='1' then
							id  <= i;
							gntd(i) <= '1';
							req <= not rdy;
							state := s_req;
							exit;
						end if;
					end loop;
				when s_req =>
					if (req xor rdy)='0' then
						gntd <= (others => '0');
						rdys(id) <= reqs(id);
						state    := s_rdy;
					end if;
				end case;
			end if;
		end if;
	end process;
	do <= di(id*m to (id+1)*m-1);
end;
