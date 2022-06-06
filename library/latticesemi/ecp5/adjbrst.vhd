library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

 entity phadctor is
	port (
		clk       : in  std_logic;
		dctct_req : in  std_logic := '-';
		dctct_rdy : buffer std_logic;
		step_req  : buffer std_logic;
		step_rdy  : in  std_logic := '-';
		input     : in  std_logic;
		phase     : buffer std_logic_vector);
 end;

library hdl4fpga;
use hdl4fpga.std.all;

 architecture beh of phadctor is
	subtype gap_word  is unsigned(0 to phase'length);

	signal saved : gap_word;

 begin

	process(clk)

		constant taps : natural := 31;
		constant num_of_taps  : natural := setif(taps < 2**phase'length-1, taps, 2**phase'length-1);
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

		variable start : std_logic;
		variable step  : unsigned(0 to unsigned_num_bits(num_of_steps-1));
		variable gap   : gap_word;

	begin

		assert num_of_taps < 2**phase'length
		report "num_of_steps " & integer'image(num_of_taps) & " greater or equal than 2**phase'length-1 "  & integer'image(2**phase'length-1)
		severity WARNING;

		if rising_edge(clk) then
			if to_bit(dctct_req xor dctct_rdy)='1' then
				if start='0' then
					saved <= (others => '0');
					phase <= std_logic_vector(to_unsigned(2**(gap_word'length-1), gap_word'length));
					step  := to_unsigned(num_of_steps-1, step'length);
					step_req <= not to_stdulogic(to_bit(step_rdy));
					start := '1';
				elsif to_bit(step_req xor to_stdulogic(to_bit(step_rdy)))='0' then
					if input='1' then
						saved <= unsigned(phase);
					end if;

					if step(0)='0' then
						gap := gaptab(to_integer(step(1 to step'right)));
					else
						gap := (others => '0');
					end if;

					if input='1' then
						phase <= std_logic_vector(unsigned(phase) + gap);
					else
						phase <= std_logic_vector(unsigned(saved) + gap);
					end if;

					if step(0)='0' then
						step  := step - 1;
						step_req <= not to_stdulogic(to_bit(step_rdy));
					else
						start := '0';
						dctct_rdy <= dctct_req;
					end if;
				end if;
			else
				start := '0';
				dctct_rdy <= to_stdulogic(to_bit(dctct_req));
			end if;
		end if;
	end process;
end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adjbrst is
	port (
		ddr_clk  : in  std_logic;
		adj_req  : in  std_logic;
		adj_rdy  : buffer std_logic;
		step_req : buffer std_logic;
		step_rdy : in  std_logic;
		ddr_sti  : in  std_logic;
		burstdet : in  std_logic;
		ddr_sto  : buffer std_logic);
end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture def of adjbrst is

	signal phase : std_logic_vector(0 to 3);

	signal dctct_req : std_logic;
	signal dctct_rdy : std_logic;

	signal base : unsigned(phase'range);

begin

	phadctor_i : entity hdl4fpga.phadctor
	port map (
		clk       => ddr_clk,
		dctct_req => dctct_req,
		dctct_rdy => dctct_rdy,
		step_req  => step_req,
		step_rdy  => step_rdy,
		input     => burstdet,
		phase     => phase);

	process(ddr_clk)
		type states is (s_start, s_lh, s_hl);
		variable state : states;

	begin
		if rising_edge(ddr_clk) then
			if to_bit(adj_req xor adj_rdy)='1' then
				case state is
				when s_start =>
					dctct_req <= not dctct_rdy;
					state := s_lh;
				when s_lh =>
					if (dctct_req xor dctct_rdy)='0' then
						if burstdet='1' then
							dctct_req <= not dctct_rdy;
							base <= unsigned(phase);
							state := s_hl;
						end if;
					end if;
				when s_hl =>
				end case;
			else
				dctct_req <= dctct_rdy;
				adj_rdy   <= adj_req;
				state     := s_start;
			end if;
		end if;
	end process;

end;