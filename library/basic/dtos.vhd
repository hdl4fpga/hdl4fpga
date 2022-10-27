library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;

entity dtos is
	port (
		clk           : in  std_logic;

		frm           : in  std_logic;
		bcd_irdy      : in  std_logic := '1';
		bcd_trdy      : buffer std_logic;
		bcd_di        : in  std_logic_vector;

		mem_ena       : out std_logic;
		mem_full      : in  std_logic;

		mem_left      : in  std_logic_vector;
		mem_left_up   : out std_logic;
		mem_left_ena  : out std_logic;

		mem_right     : in  std_logic_vector;
		mem_right_up  : out std_logic;
		mem_right_ena : out std_logic;

		mem_addr      : buffer std_logic_vector;
		mem_do        : in     std_logic_vector;
		mem_di        : buffer std_logic_vector);
end;

architecture def of dtos is

	signal dtos_ena  : std_logic;
	signal dtos_ini  : std_logic;
	signal dtos_zero : std_logic;
	signal dtos_cy   : std_logic;
	signal dtos_di   : std_logic_vector(mem_do'range);

begin

	dtos_di <= (dtos_di'range => '0') when dtos_zero='1' else mem_do;

	bcdddiv2e_e : entity hdl4fpga.bcddiv2e
	generic map (
		max => 8)
	port map (
		clk     => clk,
		bcd_ena => dtos_ena,
		bcd_exp => bcd_di,

		bcd_ini => dtos_ini,
		bcd_di  => dtos_di,
		bcd_do  => mem_di,
		bcd_cy  => dtos_cy);

	process (clk)
		type states is (init_s, addr_s, data_s, write_s);
		variable state : states;

	begin
		if rising_edge(clk) then
			case state is
			when init_s =>
				if frm='0' then
					bcd_trdy <= '0';
				elsif bcd_irdy='1' then
					if bcd_di=(bcd_di'range => '0') then
						bcd_trdy <= '1';
					else
						bcd_trdy <= '0';
					end if;
				else
					bcd_trdy  <= '0';
				end if;

				dtos_ena      <= '0';
				dtos_ini      <= '1';
				dtos_zero     <= '0';
				mem_addr      <= mem_left;
				mem_ena       <= '0';
				mem_left_ena  <= '0';
				mem_right_ena <= '0';

				if frm='0' then
					state := init_s;
				elsif bcd_irdy='1' then
					if bcd_di=(bcd_di'range => '0') then
						state := init_s;
					else
						state := addr_s;
					end if;
				end if;
			when addr_s =>
				bcd_trdy      <= '0';
				dtos_ena      <= '0';
				mem_ena       <= '0';
				mem_left_ena  <= '0';
				mem_right_ena <= '0';

				if frm='0' then
					state := init_s;
				elsif bcd_irdy='1' then
					state := data_s;
				end if;
			when data_s =>
				bcd_trdy <= '0';
				if bcd_irdy = '1' then
					dtos_ena <= '1';
					mem_ena  <= '1';
				end if;

				if mem_di=(mem_di'range => '0') then
					if mem_addr=mem_left then
						if signed(mem_left) > signed(mem_right) then
							mem_left_ena <= '1';
						elsif signed(mem_left) = signed(mem_right) then
							mem_left_ena <= dtos_cy;
						else
							mem_left_ena <= '0';
						end if;
					else
						mem_left_ena <= '0';
					end if;
				else
					mem_left_ena <= '0';
				end if;

				if mem_addr=mem_right then
					mem_right_ena <= dtos_cy;
				else
					mem_right_ena <= '0';
				end if;

				if frm='0' then
					state := init_s;
				elsif bcd_irdy='1' then
					if bcd_trdy='1' then
						state := init_s;
					else
						state := write_s;
					end if;
				end if;
			when write_s =>
				if frm='0' then
					bcd_trdy <= '0';
				elsif bcd_trdy='0' then
					if bcd_irdy='1' then
						if mem_addr=mem_right then
							if dtos_cy='1' then
								bcd_trdy  <= '0';
								dtos_ini  <= '0';
								dtos_zero <= '1';
								mem_addr  <= std_logic_vector(signed(mem_addr) - 1);
							else
								bcd_trdy  <= '1';
								dtos_ini  <= '1';
								dtos_zero <= '0';
								mem_addr  <= mem_left(mem_addr'range);
							end if;
						else
							dtos_ini <= '0';
						bcd_trdy <= '0';
							mem_addr <= std_logic_vector(signed(mem_addr) - 1);
						end if;
					end if;
				end if;

				dtos_ena      <= '0';
				mem_ena       <= '0';
				mem_left_ena  <= '0';
				mem_right_ena <= '0';

				if frm='0' then
					state := init_s;
				elsif bcd_trdy='0' then
					if bcd_irdy='1' then
						if mem_addr=mem_right then
							if dtos_cy='1' then
								state := addr_s;
							end if;
						else
							state := addr_s;
						end if;
					end if;
				elsif bcd_irdy='1' then
					state := init_s;
				end if;
			end case;
		end if;
	end process;

	mem_left_up   <= '0';
	mem_right_up  <= '0';

end;
