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

entity adjpha is
	generic (
		taps     : natural);
	port (
		clk      : in   std_logic;
		req      : in  std_logic;
		rdy      : buffer std_logic;
		step_req : buffer std_logic;
		step_rdy : in  std_logic;
		edge     : in  std_logic;
		smp      : in  std_logic_vector;
		inv      : out std_logic;
		delay    : out std_logic_vector);
end;

architecture beh of adjpha is

	constant num_of_taps  : natural := setif(taps < 2**delay'length-1, taps, 2**delay'length-1);
	constant num_of_steps : natural := unsigned_num_bits(num_of_taps)+1;
	subtype gap_word is unsigned(0 to delay'length);
	type gword_vector is array(natural range <>) of gap_word;

	function create_gaps (
		constant num_of_taps  : natural;
		constant num_of_steps : natural)
		return gword_vector is
		variable val  : gword_vector(2**unsigned_num_bits(num_of_steps-1)-1 downto 0):= (others => (others => '-'));
		variable c, q : natural;
	begin
		(c, q) := natural_vector'(num_of_taps, 1);
		val(num_of_steps-1) := to_unsigned(2**(gap_word'length-1), gap_word'length);
		for i in num_of_steps-2 downto 0 loop
			(c, q) := natural_vector'((c + q) / 2, (c+q) mod 2);
			val(i) := to_unsigned(c, gap_word'length);
		end loop;
		return val;
	end;

	constant gaptab : gword_vector := create_gaps(num_of_taps, num_of_steps);

	signal edge_req : std_logic;
	signal edge_rdy : std_logic;
	signal phase    : gap_word;
	signal ledge    : gap_word;
	signal rledge   : std_logic;
	signal avrge    : gap_word;
	signal sum1    : gap_word;
	signal saved : gap_word;
	constant xxx : natural := (2**unsigned_num_bits(num_of_taps)-(num_of_taps+1));
begin

	assert num_of_taps < 2**delay'length
	report "num_of_steps " & integer'image(num_of_taps) &
	       " greater or equal than 2**delay'length-1 "  &
	       integer'image(2**delay'length-1)
	severity WARNING;

	process(clk)
		variable start : std_logic;
		variable step  : unsigned(0 to unsigned_num_bits(num_of_steps-1));
		variable seq   : unsigned(0 to smp'length-1);
		variable gap   : gap_word;
	begin
		if rising_edge(clk) then
			if to_bit(edge_req xor edge_rdy)='1' then
				if start='0' then
					saved <= (others => '0');
					phase <= (others => '0');
					step  := to_unsigned(num_of_steps-1, step'length);
					step_req <= not to_stdulogic(to_bit(step_rdy));
					start := '1';
				elsif to_bit(step_req xor to_stdulogic(to_bit(step_rdy)))='0' then
					seq := (others => '-');
					for i in seq'range loop
						if i mod 2=0 then
							seq(0) := (edge xor rledge);
						else
							seq(0) := not (edge xor rledge);
						end if;
						seq := rotate_left(seq, 1);
					end loop;

					if smp=std_logic_vector(seq) then
						saved <= phase;
					end if;

					if step(0)='0' then
						gap := gaptab(to_integer(step(1 to step'right)));
					else
						gap := (others => '0');
					end if;

					if smp=std_logic_vector(seq) then
						phase <= phase + gap;
					else
						phase <= saved + gap;
					end if;

					if step(0)='0' then
						step  := step - 1;
						step_req <= not to_stdulogic(to_bit(step_rdy));
					else
						start := '0';
						edge_rdy <= edge_req;
					end if;
				end if;
			else
				start := '0';
				edge_rdy <= to_stdulogic(to_bit(edge_req));
			end if;
		end if;
	end process;

	process(clk)
		variable start : std_logic;
		variable sum   : gap_word;
	begin
		if rising_edge(clk) then
			if to_bit(req xor rdy)='1' then
				if start='0' then
				    rledge   <= '0';
					edge_req <= not to_stdulogic(to_bit(edge_rdy));
					start    := '1';
				elsif to_bit(edge_req xor to_stdulogic(to_bit(edge_rdy)))='0' then
					if rledge='0' then
						ledge    <= phase;
						rledge   <= '1';
						edge_req <= not edge_rdy;
						start    := '1';
					else
						sum := resize(ledge(1 to delay'length), sum'length) + resize(phase(1 to delay'length), sum'length);
						if phase < ledge then
							sum1 <= sum;
							sum := sum + xxx;
--							assert false severity failure;
						end if;
						avrge <= sum;
						edge_req <= edge_rdy;
						rdy   <= req;
						start := '0';
					end if;
				end if;
			else
				edge_req <= edge_rdy;
				rdy   <= req;
				start := '0';
			end if;
		end if;
	end process;

	inv  <= phase(0);
	delay <=
		std_logic_vector(phase(1 to delay'length)) when to_bit(rdy xor req)='1' else
		std_logic_vector(avrge(0 to delay'length-1));

end;
