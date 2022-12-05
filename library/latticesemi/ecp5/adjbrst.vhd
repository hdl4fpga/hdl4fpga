library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adjbrst is
	port (
		rst        : in  std_logic := '0';
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

	signal dcted : std_logic;
	signal phase : unsigned(lat'length+readclksel'length-1 downto 0);
	signal input : std_logic;

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

	brstdet_p : process(sclk, step_rdy)
		variable valid : std_logic;
	begin
		if rising_edge(sclk) then
			if (adj_rdy xor to_stdulogic(to_bit(adj_req)))='1' then
				if dcted='0' then
					if (step_rdy xor to_stdulogic(to_bit(step_req)))='0' then
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

	process(sclk, input)
		type states is (s_init, s_burtsdet, s_ready);
		variable state : states;
	begin
		if rising_edge(sclk) then
			if (adj_rdy xor to_stdulogic(to_bit(adj_req)))='1' then
				case state is
				when s_init =>
					step_req <= not step_rdy;
					phase    <= (others => '0');
					state    := s_burtsdet;
				when s_burtsdet =>
					if (step_req xor step_rdy)='0' then
						if dcted='1' then
							phase <= phase - 1;
							state := s_ready;
						else
							if lat(lat'left)='0'  then
								phase <= phase + 1;
							else
								adj_rdy <= adj_req;
							end if;
							step_req <= not step_rdy;
						end if;
					end if;
				when s_ready =>
					adj_rdy <= adj_req;
				end case;
			else
				adj_rdy  <= to_stdulogic(to_bit(adj_req));
				state    := s_init;
			end if;
		end if;
	end process;

	process (phase)
		variable temp : unsigned(phase'range);
	begin
		temp := phase;
		readclksel <= std_logic_vector(temp(readclksel'range));
		temp := shift_right(temp, readclksel'length);
		lat  <= std_logic_vector(temp(lat'range));
	end process;
end;