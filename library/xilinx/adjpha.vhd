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
use hdl4fpga.base.all;

entity adjpha is
	generic (
		dtaps    : integer := 0; --  ones' complement
		taps     : natural);
	port (
		tp       : out std_logic_vector(1 to 32);
		clk      : in  std_logic;
		rst      : in  std_logic := '0';
		req      : in  std_logic;
		rdy      : buffer std_logic;
		step_req : buffer std_logic;
		step_rdy : in  std_logic;
		edge     : in  std_logic;
		smp      : in  std_logic_vector;
		ph180    : out std_logic;
		inv      : out std_logic;
		delay    : buffer std_logic_vector);
end;

architecture beh of adjpha is

	subtype gap_word  is unsigned(0 to delay'length);
	signal edge_req : std_logic;
	signal edge_rdy : std_logic;
	signal phase    : gap_word;
	signal avrge    : gap_word;
	signal sel      : std_logic;
	signal trail    : std_logic;
	signal sy_req   : std_logic;

begin

	process(trail, edge, clk)

		constant num_of_taps  : natural := setif(taps < 2**delay'length-1, taps, 2**delay'length-1);
		constant num_of_steps : natural := unsigned_num_bits(num_of_taps);
		type gword_vector is array(natural range <>) of gap_word;
	
		function create_gaps (
			constant num_of_taps  : natural;
			constant num_of_steps : natural)
			return gword_vector is
			variable val  : gword_vector(2**unsigned_num_bits(num_of_steps-1)-1 downto 0):= (others => (others => '-'));
			variable c, q : natural;
		begin
			(c, q) := natural_vector'(num_of_taps, 1);
			for i in num_of_steps-1 downto 0 loop
				(c, q) := natural_vector'((c + q) / 2, (c+q) mod 2);
				val(i) := to_unsigned(c, gap_word'length);
			end loop;
			return val;
		end;
	
		constant gaptab : gword_vector := create_gaps(num_of_taps, num_of_steps);

		type states is (s_init, s_sweep);
		variable state : states;
		variable start : std_logic;
		variable step  : unsigned(0 to unsigned_num_bits(num_of_steps-1));
		variable gap   : gap_word;
		variable saved : gap_word;

		variable pattern : unsigned(0 to smp'length-1);
		variable sy_step_rdy : std_logic;
	begin

		assert num_of_taps < 2**delay'length
		report "num_of_steps " & integer'image(num_of_taps) & " greater or equal than 2**delay'length-1 "  & integer'image(2**delay'length-1)
		severity WARNING;

		pattern := (others => '-');
		for i in pattern'range loop
			if i mod 2=0 then
				pattern(i) := edge;
			else
				pattern(i) := not edge;
			end if;
			pattern(i) := pattern(i) xor trail;
		end loop;

		if rising_edge(clk) then
			if rst='1' then
				edge_rdy <= to_stdulogic(to_bit(edge_req));
			elsif (rdy xor to_stdulogic(to_bit(sy_req)))='1' then
				if (edge_rdy xor  to_stdulogic(to_bit(edge_req)))='1' then
					case state is
					when s_init =>
						saved := (others => '0');
						phase <= to_unsigned(2**(gap_word'length-1), gap_word'length);
						step  := to_unsigned(num_of_steps-1, step'length);
						step_req <= not sy_step_rdy;
						state := s_sweep;
					when s_sweep =>
						if (sy_step_rdy xor to_stdulogic(to_bit(step_req)))='0' then
							if step(0)='0' then
								gap := gaptab(to_integer(step(1 to step'right)));
							else
								gap := (others => '0');
							end if;

							if smp=std_logic_vector(pattern) then
								saved := phase;
								phase <= phase + gap;
							else
								phase <= saved + gap;
							end if;
	
							if step(0)='0' then
								step    := step - 1;
								step_req <= not sy_step_rdy;
							else
								state    := s_init;
								edge_rdy <= to_stdulogic(to_bit(edge_req));
							end if;
						end if;
					end case;
				else
					state := s_init;
				end if;
			else
				state := s_init;
				edge_rdy <= to_stdulogic(to_bit(edge_req));
			end if;
			sy_step_rdy := to_stdulogic(to_bit(step_rdy));
			sy_req      <= req;
		end if;
	end process;

	avrge_g : if dtaps=0 generate
		process(clk)
			type states is (s_init, s_lead, s_trail);
			variable state  : states;
			variable ledge  : gap_word;
			variable sum    : gap_word;
		begin
			if rising_edge(clk) then
				if rst='1' then
					rdy   <=  to_stdulogic(to_bit(req));
					trail <= '0';
					state := s_init;
				elsif (rdy xor to_stdulogic(to_bit(sy_req)))='1' then
					case state is
					when s_init =>
						edge_req <= not to_stdulogic(to_bit(edge_rdy));
						trail <= '0';
						state := s_lead;
					when s_lead =>
						ledge := phase;
						if (edge_req xor to_stdulogic(to_bit(edge_rdy)))='0' then
							edge_req <= not edge_rdy;
							trail <= '1';
							state := s_trail;
						end if;
					when s_trail =>
						sum := shift_right(resize(ledge(1 to delay'length), sum'length) + resize(phase(1 to delay'length), sum'length), 1);
						if shift_left(phase,1) < shift_left(ledge,1) then
							if sum <= (taps+1)/2 then
								sum := sum + (taps+0)/2;
							else
								sum := sum - (taps+1)/2;
							end if;
						end if;
						avrge <= sum;
						if (edge_req xor to_stdulogic(to_bit(edge_rdy)))='0' then
							rdy <=  to_stdulogic(to_bit(sy_req));
							trail <= '0';
							state := s_init;
						end if;
					end case;
				else
					trail <= '0';
					state := s_init;
				end if;
			end if;
		end process;
	end generate;

	dtasp_g : if dtaps/=0 generate
		process(clk)
			type states is (s_init, s_lead);
			variable state  : states;
			variable ledge  : gap_word;
			variable start  : std_logic;
			variable sum    : gap_word;
		begin
			if rising_edge(clk) then
				if rst='1' then
					rdy   <=  to_stdulogic(to_bit(req));
					trail <= '-';
					state := s_init;
				elsif (rdy xor to_stdulogic(to_bit(sy_req)))='1' then
					case state is
					when s_init =>
						edge_req <= not to_stdulogic(to_bit(edge_rdy));
						trail <= '0';
						state := s_lead;
					when s_lead =>
						if dtaps > 0 then
							sum := resize(phase(1 to delay'length), sum'length) + dtaps;
						else
							sum := resize(phase(1 to delay'length), sum'length) + (dtaps+1);
						end if;

						if sum > taps then
							sum := sum - (taps+1);
						end if;
						avrge <= sum;
						if (edge_req xor to_stdulogic(to_bit(edge_rdy)))='0' then
							rdy   <=  to_stdulogic(to_bit(sy_req));
							edge_req <= not edge_rdy;
							state := s_init;
						end if;
					end case;
				else
					trail <= '-';
					state := s_init;
				end if;
			end if;
		end process;
	end generate;

	inv   <= phase(0);
	ph180 <= '0' when unsigned(delay) < (taps+1)/2 else '1';
	process (clk)
	begin
		if rising_edge(clk) then
			sel <= to_stdulogic(to_bit(rdy xor req));
		end if;
	end process;
	delay <=
		std_logic_vector(phase(1 to delay'length)) when sel='1' else
		std_logic_vector(avrge(1 to delay'length));

end;
