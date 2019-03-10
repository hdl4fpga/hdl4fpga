library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity dtos is
	port (
		clk           : in  std_logic;

		bcd_frm       : in  std_logic;
		bcd_irdy      : in  std_logic := '1';
		bcd_trdy      : buffer std_logic;
		bcd_di        : in  std_logic_vector;

		mem_full      : in  std_logic;
		mem_ena       : out std_logic;

		mem_left      : in std_logic_vector;
		mem_left_up   : out std_logic;
		mem_left_ena  : out std_logic;

		mem_right     : in std_logic_vector;
		mem_right_up  : out std_logic;
		mem_right_ena : out std_logic;

		mem_addr      : out std_logic_vector;
		mem_do        : in  std_logic_vector;
		mem_di        : out std_logic_vector);
end;

architecture def of dtos is

	signal dtos_ena  : std_logic;
	signal dtos_ini  : std_logic;
	signal dtos_zero : std_logic;
	signal dtos_trdy : std_logic;
	signal dtos_cy   : std_logic;
	signal dtos_di   : std_logic_vector(mem_do'range);
	signal dtos_do   : std_logic_vector(mem_di'range);

	signal cy : std_logic;
	signal up : std_logic;

	signal frm       : std_logic;
	signal addr      : unsigned(mem_addr'range);
	signal dtos_irdy : std_logic;
	signal mem_trdy  : std_logic;
	signal mem_irdy  : std_logic;
	signal addr_eq   : std_logic;

begin

	process(clk)
	begin
		if rising_edge(clk) then
			frm <= bcd_frm;
		end if;
	end process;

	process(bcd_frm, clk)
		type states is (s1, s2, s3);
		variable state : states;
	begin
		if bcd_frm='0' then
			dtos_ena  <= '0';
			dtos_irdy <= '1';
			dtos_trdy <= '0';
			bcd_trdy  <= '0';
			dtos_ini  <= '1';
			dtos_zero <= '0';
			state     := s1;
		elsif rising_edge(clk) then
			case state is
			when s1 =>
				mem_ena   <= '0';
				dtos_trdy <= '0';
				if dtos_irdy='1' then
					dtos_ena <= '1';
				else
					dtos_ena <= '0';
				end if;
			when s2 =>
				dtos_ena  <= '0';
				dtos_trdy <= '1';
				mem_ena   <= '1';
				if addr_eq='1' then
					if cy='0' then
						bcd_trdy  <= '1';
						dtos_zero <= '0';
					else
						bcd_trdy  <= '0';
						dtos_zero <= '1';
					end if;
				else
					dtos_zero <= '0';
					bcd_trdy  <= '0';
				end if;
			when s3 =>
				dtos_ena  <= '0';
				dtos_trdy <= '0';
				mem_ena   <= '0';
				if bcd_trdy='1' then
					dtos_ini <= '1';
				else
					dtos_ini <= '0';
				end if;
				if bcd_irdy='1' then
					bcd_trdy <= '0';
				end if;
			end case;	

			case state is
			when s1 =>
				if bcd_irdy='1' then
					if dtos_irdy='1' then
						state := s2;
					end if;
				end if;
			when s2 =>
				state := s3;
			when s3 =>
				if bcd_irdy='1' then
					state := s1;
				end if;
			end case;	
		end if;
	end process;

	bcdddiv2e_e : entity hdl4fpga.bcddiv2e
	port map (
		clk     => clk,
		bcd_exp => bcd_di,
		bcd_ena => dtos_ena,
		bcd_ini => dtos_ini,
		bcd_di  => dtos_di,
		bcd_do  => dtos_do,
		bcd_cy  => dtos_cy);

	dtos_di <= (dtos_di'range => '0') when dtos_zero='1' else mem_do;
	process (clk)
	begin
		if rising_edge(clk) then
			addr_eq <= setif(addr=unsigned(mem_right));
			if dtos_ena='1' then
				mem_di <= dtos_do;
			end if;
			cy <= dtos_cy;
			if bcd_frm='0' then
				addr <= unsigned(mem_left(mem_addr'range));
			elsif dtos_ena='1' then
				if addr_eq='1' then
					if cy='1' then
						addr <= addr - 1;
					else
						addr <= unsigned(mem_left(mem_addr'range));
					end if;
				else
					addr <= addr - 1;
				end if;
			end if;
		end if;
	end process;

	mem_p : process(clk)
	begin
		if rising_edge(clk) then
			if bcd_frm='0' then
				mem_addr     <= mem_left(mem_addr'range);
				mem_right_up  <= '-';
				mem_right_ena <= '0';
			elsif dtos_ena='1' then
				if addr_eq='1' then
					if cy='1' then
						mem_right_up  <= '0';
						mem_right_ena <= '1';
					else
						mem_right_up  <= '-';
						mem_right_ena <= '0';
					end if;
				else
					mem_right_up  <= '-';
					mem_right_ena <= '0';
				end if;
			else
				mem_right_up  <= '-';
				mem_right_ena <= '0';
			end if;
		end if;
	end process;
	mem_addr <= std_logic_vector(addr);

end;
