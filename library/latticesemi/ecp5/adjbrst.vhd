library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adjbrst is
	port (
		rst        : in  std_logic := '0';
		sclk       : in  std_logic;
		adj_req    : in  std_logic;
		adj_rdy    : buffer std_logic;
		pause      : in  std_logic;
		pause_req  : out std_logic;
		pause_rdy  : in  std_logic;
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
		variable succ  : unsigned(phase'range);
		variable wlat  : unsigned(0 to 4-1);
		variable cntr  : unsigned(0 to 2);
	begin
		if rising_edge(sclk) then
			if (adj_rdy xor to_stdulogic(to_bit(adj_req)))='1' then
				case state is
				when s_init =>
					step_req <= not to_stdulogic(to_bit(step_rdy));
					pause_req <= not to_stdulogic(to_bit(pause_rdy));
					succ     := (others => '0');
					phase    <= (others => '0');
					state    := s_burtsdet;
					wlat     := (others => '0');
					cntr     := (others => '0');
				when s_burtsdet =>
					if (step_req xor step_rdy)='0' then
						if wlat(0)='1' then
							if cntr(0)='1' then
								if dcted='1' then
									state := s_ready;
								else
									succ := phase + 1;
									wlat := (others => '0');
									if lat(lat'left)='1'  then
										adj_rdy <= adj_req;
									end if;
									cntr     := (others => '0');
									step_req  <= not step_rdy;
									pasue_req <= not pause_rdy;
								end if;
							else
								cntr := cntr + 1;
								step_req <= not step_rdy;
							end if;
						else
							wlat := wlat + 1;
						end if;
					else
						wlat  := (others => '0');
						phase <= succ;
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