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
		bcd_trdy      : out std_logic;
		bcd_di        : in  std_logic_vector;

		mem_ena       : out std_logic;
		mem_full      : in  std_logic;

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
	signal dtos_cy   : std_logic;
	signal dtos_di   : std_logic_vector(mem_do'range);
	signal dtos_do   : std_logic_vector(mem_di'range);

	signal frm       : std_logic;
	signal addr      : signed(mem_addr'range);

	type states is (addr_s, data_s, write_s);
	signal state : states;

begin

	process(clk)
	begin
		if rising_edge(clk) then
			frm <= bcd_frm;
		end if;
	end process;

	process(bcd_frm, clk)
	begin
		if bcd_frm='0' then
			state <= addr_s;
		elsif rising_edge(clk) then
			case state is
			when addr_s =>
				if bcd_irdy='1' then
					state <= data_s;
				end if;
			when data_s =>
				if bcd_irdy='1' then
					state <= write_s;
				end if;
			when write_s =>
				if bcd_irdy='1' then
					state  <= addr_s;
				end if;
			end case;	
		end if;
	end process;

	dtos_di <= (dtos_di'range => '0') when dtos_zero='1' else mem_do;
--	process(clk)
--	begin
--		if rising_edge(clk) then
--			if dtos_zero='1' then
--				dtos_di <= (dtos_di'range => '0');
--			else
--				dtos_di <= mem_do;
--			end if;
--		end if;
--	end process;

	bcdddiv2e_e : entity hdl4fpga.bcddiv2e
	generic map (
		max => 16)
	port map (
		clk     => clk,
		bcd_ena => dtos_ena,
		bcd_exp => bcd_di,

		bcd_ini => dtos_ini,
		bcd_di  => dtos_di,
		bcd_do  => dtos_do,
		bcd_cy  => dtos_cy);

	process (bcd_frm, clk)
	begin
		if bcd_frm='0' then
			dtos_ena  <= '0';
			bcd_trdy  <= '0';
			dtos_ini  <= '1';
			dtos_zero <= '0';
			mem_ena   <= '0';
			addr      <= signed(mem_left(mem_addr'range));
		elsif rising_edge(clk) then
			case state is
			when addr_s =>
				bcd_trdy <= '0';
				dtos_ena <= '0';
				mem_ena  <= '0';
			when data_s =>
				bcd_trdy <= '0';
				if bcd_irdy = '1' then
					dtos_ena <= '1';
					mem_ena  <= '1';
				end if;
			when write_s =>
				if bcd_irdy='1' then
					if addr=signed(mem_right) then
						if dtos_cy='1' then
							bcd_trdy  <= '0';
							dtos_ini  <= '0';
							dtos_zero <= '1';
							addr     <= addr - 1;
						else
							bcd_trdy  <= '1';
							dtos_ini  <= '1';
							dtos_zero <= '0';
							addr     <= signed(mem_left(mem_addr'range));
						end if;
					else
						dtos_ini <= '0';
						bcd_trdy <= '0';
						addr     <= addr - 1;
					end if;
				end if;
				dtos_ena <= '0';
				mem_ena  <= '0';
			end case;
		end if;
	end process;

	process (clk)
	begin
		if rising_edge(clk) then
			mem_left_ena  <= setif(bcd_frm='1' and state=data_s and addr=signed(mem_left)  and dtos_do=(dtos_do'range => '0'));
			mem_left_up   <= '0';
			mem_right_ena <= setif(bcd_frm='1' and state=data_s and addr=signed(mem_right) and dtos_cy='1');
			mem_right_up  <= '0';
		end if;
	end process;

	mem_addr      <= std_logic_vector(addr);
	mem_di        <= dtos_do;

end;
