library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

 entity phadctor is
	generic (
		taps      : natural);
	port (
		clk       : in  std_logic;
		dtct_req  : in  std_logic;
		dtct_rdy  : buffer std_logic;
		step_req  : buffer std_logic;
		step_rdy  : in  std_logic;
		edge      : in  std_logic := '1';
		input     : in  std_logic;
		phase     : buffer std_logic_vector);
 end;

library hdl4fpga;
use hdl4fpga.std.all;

 architecture beh of phadctor is
	subtype gap_word  is unsigned(0 to phase'length-1);

	signal saved : gap_word;

 begin

	process(clk)

		constant num_of_taps  : natural := setif(taps < 2**(phase'length-1)-1, taps, 2**(phase'length-1)-1);
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

		assert num_of_taps < 2**(phase'length-1)
		report "num_of_steps " & integer'image(num_of_taps) & " greater or equal than 2**(phase'length-1)-1 "  & integer'image(2**(phase'length-1)-1)
		severity WARNING;

		if rising_edge(clk) then
			if (dtct_rdy xor to_stdulogic(to_bit(dtct_req)))='1' then
				if start='0' then
					saved <= (others => '0');
					phase <= std_logic_vector(to_unsigned(2**(gap_word'length-1), gap_word'length));
					step  := to_unsigned(num_of_steps-1, step'length);
					step_req <= not step_rdy;
					start := '1';
				elsif (step_rdy xor to_stdulogic(to_bit(step_req)))='0' then
					if input=edge then
						saved <= unsigned(phase);
					end if;

					if step(0)='0' then
						gap := gaptab(to_integer(step(1 to step'right)));
					else
						gap := (others => '0');
					end if;

					if input=edge then
						phase <= std_logic_vector(unsigned(phase) + gap);
					else
						phase <= std_logic_vector(unsigned(saved) + gap);
					end if;

					if step(0)='0' then
						step  := step - 1;
						step_req <= not step_rdy;
					else
						start := '0';
						dtct_rdy <= to_stdulogic(to_bit(dtct_req));
					end if;
				end if;
			else
				start := '0';
				dtct_rdy <= to_stdulogic(to_bit(dtct_req));
			end if;
		end if;
	end process;
end;