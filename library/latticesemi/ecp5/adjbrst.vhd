library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adjbrst is
	generic (
		debug      : boolean := false);
	port (
		rst        : in  std_logic := '0';
		sclk       : in  std_logic;
		adj_req    : in  std_logic;
		adj_rdy    : buffer std_logic;
		pause_req  : buffer std_logic;
		pause_rdy  : in  std_logic;
		step_req   : buffer std_logic;
		step_rdy   : in  std_logic;
		read       : in  std_logic;
		datavalid  : in  std_logic;
		burstdet   : in  std_logic;
		locked     : out std_logic;
		lat        : buffer std_logic_vector;
		readclksel : out std_logic_vector);
end;

library hdl4fpga;
use hdl4fpga.base.all;

architecture def of adjbrst is

	signal phase : unsigned(lat'length+readclksel'length-1 downto 0);
	signal input : std_logic;

begin

	process(sclk, input)
		type states is (s_init, s_pause, s_step);
		variable state : states;
		variable wlat  : unsigned(0 to 4-1);
		variable cntr  : unsigned(0 to setif(debug,2, 8));
		variable dtec  : unsigned(cntr'range);
	begin
		if rising_edge(sclk) then
			if rst='1' then
				adj_rdy <= to_stdulogic(to_bit(adj_req));
				locked  <= '0';
				state   := s_init;
			elsif (adj_rdy xor to_stdulogic(to_bit(adj_req)))='1' then
				case state is
				when s_init =>
					pause_req <= not to_stdulogic(to_bit(pause_rdy));
					phase     <= (others => '0');
					state     := s_pause;
					wlat      := (others => '0');
					cntr      := (others => '0');
					locked    <= '0';
				when s_pause =>
					if (pause_rdy xor pause_req)='0' then
						step_req  <= not to_stdulogic(to_bit(step_rdy));
						cntr      := (others => '0');
						dtec      := (others => '0');
						state     := s_step;
					end if;
					locked    <= '0';
				when s_step =>
					if (step_req xor step_rdy)='0' then
						if wlat(0)='1' then
							if cntr(0)='1' then
								if dtec(0)='1' then
									adj_rdy <= adj_req;
									locked  <= '1';
									state  := s_init;
								else
									wlat := (others => '0');
									if lat(lat'left)='1'  then
										adj_rdy <= adj_req;
									end if;
									phase     <= phase + 1;
									pause_req <= not pause_rdy;
									locked    <= '0';
									state     := s_pause;
								end if;
							else
								if input='1' then
									dtec := dtec + 1;
								end if;
								cntr     := cntr + 1;
								input    <= '0';
								step_req <= not to_stdulogic(to_bit(step_rdy));
								locked   <= '0';
								state    := s_step;
							end if;
						else
							wlat   := wlat + 1;
							locked <= '0';
						end if;
					else
						wlat := (others => '0');
					end if;
					if (burstdet and datavalid)='1' then
						input <= '1';
					end if;
				end case;
			else
				adj_rdy <= to_stdulogic(to_bit(adj_req));
				state   := s_init;
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