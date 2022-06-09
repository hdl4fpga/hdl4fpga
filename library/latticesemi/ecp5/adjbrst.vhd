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
			if to_bit(dtct_req xor dtct_rdy)='1' then
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
						dtct_rdy <= dtct_req;
					end if;
				end if;
			else
				start := '0';
				dtct_rdy <= to_stdulogic(to_bit(dtct_req));
			end if;
		end if;
	end process;
end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adjbrst is
	port (
		sclk        : in  std_logic;
		adj_req     : in  std_logic;
		adj_rdy     : buffer std_logic;
		adjstep_req : buffer std_logic;
		adjstep_rdy : in  std_logic;
		read        : in  std_logic;
		burstdet    : in  std_logic;
		lat         : buffer std_logic_vector;
		readclksel  : out std_logic_vector);
end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture def of adjbrst is

	signal phase : std_logic_vector(readclksel'range);

	signal dtct_req : std_logic;
	signal dtct_rdy : std_logic;
	signal step_rdy  : std_logic;

	signal base  : unsigned(lat'length+readclksel'length-1 downto 0);
	signal input : std_logic;

begin

	phadctor_i : entity hdl4fpga.phadctor
	generic map (
		taps => 2**readclksel'length-1)
	port map (
		clk      => sclk,
		dtct_req => dtct_req,
		dtct_rdy => dtct_rdy,
		step_req => adjstep_req,
		step_rdy => step_rdy,
		input    => input,
		phase    => phase);

	process(sclk)
		type states is (s_start, s_lh, s_hl, s_finish);
		variable state : states;
		variable dcted : std_logic;
	begin
		if rising_edge(sclk) then
			if to_bit(adj_req xor adj_rdy)='1' then
				case state is
				when s_start =>
					dtct_req <= not dtct_rdy;
					step_rdy <= adjstep_rdy;
					state    := s_lh;
					lat      <= (lat'range => '0');
					input    <= burstdet;
				when s_lh =>
					if (dtct_req xor dtct_rdy)='0' then
						if dcted='1' then
							base  <= unsigned(std_logic_vector'(lat & phase));
							input <= not burstdet;
							state := s_hl;
						else
							lat   <= std_logic_vector(unsigned(lat) + 1);
							input <= burstdet;
						end if;
						dtct_req <= not dtct_rdy;
					elsif (adjstep_rdy xor adjstep_req)='0' then
						if read='1' then
							dcted    := burstdet;
							step_rdy <= adjstep_rdy;
						end if;
						input <= burstdet;
					end if;
					readclksel <= phase;
				when s_hl =>
					if (dtct_req xor dtct_rdy)='0' then
						readclksel <= std_logic_vector(resize(base + unsigned(phase), readclksel'length));
						state := s_finish;
					elsif (adjstep_rdy xor adjstep_req)='0' then
						if read='1' then
							dcted    := burstdet;
							step_rdy <= adjstep_rdy;
						end if;
						lat        <= std_logic_vector(resize(shift_right(base + unsigned(phase), readclksel'length), lat'length));
						readclksel <= std_logic_vector(resize(shift_right(base + unsigned(phase), 0),                 readclksel'length));
					end if;
					input <= not burstdet;
				when s_finish =>
					input <= '-';
				end case;
			else
				dtct_req <= dtct_rdy;
				adj_rdy  <= adj_req;
				step_rdy <= adjstep_rdy;
				state    := s_start;
			end if;
		end if;
	end process;
end;