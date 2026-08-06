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

entity mdio is
	port (
		clk  : in  std_logic;
		req  : in  std_logic;
		rdy  : buffer std_logic := '0';
		rd   : in  std_logic :='1';
		dev  : in  std_logic_vector(0 to  5-1):= b"00001";
		rid  : in  std_logic_vector(0 to 16-1) := x"8001";
		din  : in  std_logic_vector(0 to 16-1) := x"5555";
		dout : out std_logic_vector(0 to 16-1);
		mdc  : out std_logic   := '0';
		mdio : inout std_logic := 'Z');
end;

architecture mix of mdio is
	constant start_bits : std_logic_vector := "01";
	constant trna_bits  : std_logic_vector := "10";
	signal op : std_logic_vector(0 to 2-1);
	shared variable shr : unsigned(0 to din'length-1);
begin
	op <= rd & not rd;
	process(clk)
		type states is (s_prem, s_start, s_op, s_dev, s_rid, s_trna, s_data);
		variable state : states;
		variable cntr  : integer range -1 to 31;
	begin
		if rising_edge(clk) then
			if (rdy xor req)='1' then
				case state is
				when s_prem =>
					if cntr < 0 then
						cntr  := start_bits'length-1;
						shr(0 to 2-1) := unsigned(start_bits);
						state := s_start;
					else
						shr(0) := '1';
					end if;
				when s_start =>
					if cntr < 0 then
						cntr  := op'length-1;
						shr(op'range) := unsigned(op);
						state := s_op;
					end if;
				when s_op =>
					if cntr < 0 then
						cntr  := dev'length-1;
						shr(dev'range) := unsigned(dev);
						state := s_dev;
					end if;
				when s_dev =>
					if cntr < 0 then
						cntr  := rid'length-1;
						shr(rid'range) := unsigned(rid);
						state := s_rid;
					end if;
				when s_rid =>
					if cntr < 0 then
						cntr := trna_bits'length-1;
						shr(trna_bits'range) := unsigned(trna_bits);
						state := s_trna;
					end if;
				when s_trna =>
					if cntr < 0 then
						cntr  := din'length-1;
						shr(din'range) := unsigned(din);
						state := s_data;
					end if;
				when s_data =>
					if cntr < 0 then
						rdy   <= req;
						cntr  := 32-1;
						dout  <= std_logic_vector(shr(dout'range));
						shr   := (others => '0');
						state := s_prem;
					end if;
				end case;
				cntr   := cntr - 1;
			else
				cntr   := 32-1;
				shr(0) := '0';
				state := s_prem;
			end if;

			case state is
			when s_trna|s_data =>
				if op(0)='1' then
					mdio <= 'Z';
				else 
					mdio <= shr(0);
				end if;
			when others =>
				mdio <= shr(0);
			end case;

			shr(0) := mdio;
			shr := rotate_left(shr, 1);
		end if;
	end process;
	mdc <= clk;
end;
