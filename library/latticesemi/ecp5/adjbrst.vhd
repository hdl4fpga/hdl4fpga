library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adjbrst is
	port (
		sclk       : in  std_logic;
		adj_req    : in  std_logic;
		adj_rdy    : buffer std_logic;
		step_req   : buffer std_logic;
		step_rdy   : in  std_logic;
		read       : in  std_logic;
		datavalid  : in  std_logic;
		burstdet   : in  std_logic;
		lat        : buffer std_logic_vector;
		readclksel : out std_logic_vector);
end;

library hdl4fpga;
use hdl4fpga.base.all;

architecture def of adjbrst is


	signal brst_rdy  : std_logic;
	signal dtct_req  : std_logic;
	signal dtct_rdy  : std_logic;

	signal edge      : std_logic;

	signal dcted     : std_logic;

	signal phase     : std_logic_vector(readclksel'range);
	signal base      : unsigned(lat'length+readclksel'length-1 downto 0);
	signal input     : std_logic;

begin

	input_p : process(sclk)
		variable latch : std_logic;
	begin
		if rising_edge(sclk) then
			if (step_rdy xor to_stdulogic(to_bit(step_req)))='1' then
				if latch='0' then
					if (burstdet and datavalid)='1' then
						input <= '1';
						latch := '1';
					else
						input <= '0';
					end if;
				end if;
			else
				latch := '0';
			end if;
		end if;
	end process;

	phadctor_i : entity hdl4fpga.phadctor
	generic map (
		taps => 2**readclksel'length-1)
	port map (
		clk      => sclk,
		dtct_req => dtct_req,
		dtct_rdy => dtct_rdy,
		step_req => step_req,
		step_rdy => step_rdy,
		edge     => edge,
		input    => input,
		phase    => phase);

	brstdet_p : process(sclk,dtct_rdy)
		variable valid : std_logic;
	begin
		if rising_edge(sclk) then
			if (dtct_rdy xor to_stdulogic(to_bit(dtct_req)))='1' then
				if dcted='0' then
					if (step_rdy xor to_stdulogic(to_bit(step_req)))='1' then
						if datavalid='1' then
							dcted <= burstdet;
						end if;
					end if;
				end if;
			else
				dcted <= '0';
			end if;
		end if;
	end process;

	process (sclk, dtct_req)
		variable acc : unsigned(lat'length+readclksel'length-1 downto 0);
	begin
		if rising_edge(sclk) then
			acc := base + unsigned(phase);
			acc := rotate_left(acc, lat'length);
			lat <= std_logic_vector(acc(lat'range));
			acc := rotate_left(acc, readclksel'length);
			readclksel <= std_logic_vector(acc(readclksel'range));
		end if;
	end process;

	process(sclk, input)
		type states is (s_start, s_lh, s_hl, s_finish);
		variable state : states;
	begin
		if rising_edge(sclk) then
			if (adj_rdy xor to_stdulogic(to_bit(adj_req)))='1' then
				case state is
				when s_start =>
					dtct_req <= not dtct_rdy;
					base  <= (others => '0');
					edge  <= '0';
					state := s_lh;
				when s_lh =>
					if (dtct_req xor dtct_rdy)='0' then
						if dcted='1' then
							base(readclksel'length-1 downto 0) <= unsigned(phase);
							edge  <= '1';
							state := s_hl;
						elsif lat(lat'left)='0'  then
							base <= base + 2**readclksel'length;
						else
							adj_rdy <= adj_req;
						end if;
						dtct_req <= not dtct_rdy;
					end if;
				when s_hl =>
					if (dtct_req xor dtct_rdy)='0' then
						base  <= base - shift_right(resize(unsigned(phase), base'length), 1);
						state := s_finish;
					end if;
				when s_finish =>
					adj_rdy <= adj_req;
				end case;
			else
				adj_rdy  <= to_stdulogic(to_bit(adj_req));
				edge     <= '-';
				state    := s_start;
			end if;
		end if;
	end process;
end;