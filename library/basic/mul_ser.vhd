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
	port (
		clk  : in  std_logic;
		ena  : in  std_logic := '1';
		req  : in  std_logic;
		rdy  : buffer std_logic;
		a    : in  std_logic_vector;
		b    : in  std_logic_vector;
		s    : out std_logic_vector);
end;

architecture def of mul_ser is
	signal freeze : std_logic;
	signal load : std_logic;
begin
	load <= req xor to_stdulogic(to_bit(rdy));
	process (clk, load)
		variable cntr : unsigned(0 to unsigned_num_bits(b'length-2));
	begin
		if rising_edge(clk) then
			if cntr(0)='0' then
				cntr := cntr - 1;
			elsif load='1' then
				cntr := to_unsigned(b'length-2, cntr'length);
			else
				rdy <= req;
			end if;
			freeze <= cntr(0);
		end if;
	end process;

	process (clk)
		variable acc : unsigned(0 to a'length);
		variable p   : unsigned(0 to a'length+b'length-1);
	begin
		if rising_edge(clk) then
			if ena='1' then
				if freeze='1' then
					if load='1' then	
						p   := resize(unsigned(b), p'length);
					end if;
				end if;
				acc := (others => '0');
				if freeze='0' then
					if p(p'right)='1' then
						acc := resize(unsigned(a), acc'length);
					end if;
					acc := acc + resize(p(0 to a'length-1), acc'length);
					p := shift_right(p, 1);
					p(acc'range) := acc;
				end if;
				s <= std_logic_vector(p(0 to s'length-1));
			end if;	
		end if;
	end process;

end;	