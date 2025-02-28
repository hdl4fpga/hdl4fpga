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

entity phy_rl is
	port (
		clk        : in  std_logic;
		rl_req     : in  std_logic;
		rl_rdy     : buffer std_logic;
		write_req  : buffer std_logic;
		write_rdy  : in  std_logic;
		read_req   : buffer std_logic;
		read_rdy   : in  std_logic;
		burst      : out std_logic;
		sti        : in  std_logic := '1';
		adjdqs_req : buffer std_logic;
		adjdqs_rdy : in  std_logic;
		adjdqi_req : buffer std_logic;
		adjdqi_rdy : in  std_logic;
		adjsto_req : buffer std_logic;
		adjsto_rdy : in  std_logic);
end;

architecture def of phy_rl is
begin
	process (clk)
		type states is (s_start, s_write, s_dqs, s_dqi, s_sto);
		variable state : states;
	begin
		if rising_edge(clk) then
			if (to_bit(rl_req) xor to_bit(rl_rdy))='0' then
				adjdqs_req <= to_stdulogic(to_bit(adjdqs_rdy));
				adjdqi_req <= to_stdulogic(to_bit(adjsto_rdy));
				adjsto_req <= to_stdulogic(to_bit(adjsto_rdy));
				state := s_start;
			else
				case state is
				when s_start =>
					write_req <= not to_stdulogic(to_bit(write_rdy));
					burst <= '0';
					state := s_write;
				when s_write =>
					if (to_bit(write_req) xor to_bit(write_rdy))='0' then
						read_req <= not to_stdulogic(to_bit(read_rdy));
						burst <= '1';
						if sti='1' then
							adjdqs_req <= not to_stdulogic(to_bit(adjdqs_rdy));
							state := s_dqs;
						end if;
					end if;
				when s_dqs =>
					if (to_bit(adjdqs_req) xor to_bit(adjdqs_rdy))='0' then
						adjdqi_req <= not adjsto_req;
						state := s_dqi;
					end if;
				when s_dqi =>
					if (adjdqi_req xor adjdqi_rdy)='0' then
						burst <= '0';
						if (to_bit(read_req) xor to_bit(read_rdy))='0' then
							read_req   <= not read_rdy;
							adjsto_req <= not adjsto_rdy;
							state := s_sto;
						end if;
					end if;
				when s_sto =>
					if (read_req xor read_rdy)='0' then
						if (adjsto_req xor adjsto_rdy)='0' then
							rl_rdy <= rl_req;
							state := s_start;
						else
							read_req <= not read_rdy;
						end if;
					end if;
					burst <= '0';
				end case;
			end if;
		end if;
	end process;
end;


