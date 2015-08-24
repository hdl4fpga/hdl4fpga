--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2015                                                    --
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

entity pipe_adder is
	generic (
		n : natural := 64;
		m : natural := 4);
	port (
		clk : in std_logic;
		d : in std_logic;
		a : in std_logic_vector(n-1 downto 0);
		b : in std_logic_vector(n-1 downto 0);
		s : out std_logic_vector(n-1 downto 0));
end;

architecture def of pipe_adder is
	constant l : natural := n/m;
	signal cy : std_logic_vector(0 to l);
begin
	assert n mod m = 0 
		report "n  is not multiple of m"
		severity failure;
	cy(0) <= '0';
	g1ton: for i in 0 to l-1 generate 
		subtype word is std_logic_vector(m-1 downto 0);
		type word_vector is array (natural range <>) of word;

		function push (
			constant arg1 : word_vector;
			constant arg2 : word)
			return word_vector is
			variable aux : word_vector(0 to arg1'length-1);
		begin
			aux := arg1;
			if arg1'length < 2 then
				return (1 to 1 => arg2);
			else
				return aux(1 to aux'right) & arg2;
			end if;
		end function;

		alias as : word is a(m*(i+1)-1 downto m*i);
		alias bs : word is b(m*(i+1)-1 downto m*i);

	begin
		process (clk)
			variable aw : word_vector(0 to i);
			variable bw : word_vector(0 to i);
			variable sw : word_vector(i to l-1);
			
			variable add : unsigned(0 to m);
		begin
			if rising_edge(clk) then
				aw := push(aw,as);
				bw := push(bw,bs);


				case d is
				when '1' =>
					add := to_unsigned(
						to_integer(unsigned(aw(0)))-
						to_integer(unsigned(bw(0)))-
						to_integer(unsigned(std_logic_vector'(1 to 1 => cy(i)))),m+1);
				when others =>
					add := to_unsigned(
						to_integer(unsigned(aw(0)))+
						to_integer(unsigned(bw(0)))+
						to_integer(unsigned(std_logic_vector'(1 to 1 => cy(i)))),m+1);
				end case;

				sw := push(sw,word(add(1 to m)));
				cy(i+1) <= add(0);
				s(m*(i+1)-1 downto m*i) <= sw(i);
			end if;
		end process;
	end generate;
end;