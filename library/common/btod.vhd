library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity btod is
	port (
		clk           : in  std_logic;

		frm       : in  std_logic;
		bin_irdy      : in  std_logic := '1';
		bin_trdy      : out std_logic;
		bin_di        : in  std_logic_vector;

		mem_ena       : out std_logic;
		mem_full      : in  std_logic;

		mem_left      : in  std_logic_vector;
		mem_left_up   : out std_logic;
		mem_left_ena  : out std_logic;

		mem_right     : in  std_logic_vector;
		mem_right_up  : out std_logic := '-';
		mem_right_ena : out std_logic := '0';

		mem_addr      : out std_logic_vector;
		mem_di        : out std_logic_vector;
		mem_do        : in  std_logic_vector);
end;

architecture def of btod is

	signal btod_ena  : std_logic;
	signal btod_ini  : std_logic;
	signal btod_zero : std_logic;
	signal btod_cy   : std_logic;
	signal btod_di   : std_logic_vector(mem_do'range);
	signal btod_do   : std_logic_vector(mem_di'range);

	signal addr      : signed(mem_addr'range);

	type states is (addr_s, data_s, write_s);
	signal state     : states;

begin

	process(clk)
	begin
		if rising_edge(clk) then
			if frm='0' then
				state <= addr_s;
			else
				case state is
				when addr_s =>
					if bin_irdy='1' then
						state <= data_s;
					end if;
				when data_s =>
					if bin_irdy='1' then
						state <= write_s;
					end if;
				when write_s =>
					if bin_irdy='1' then
						state  <= addr_s;
					end if;
				end case;	
			end if;
		end if;
	end process;

	btod_di <= (btod_di'range => '0') when btod_zero='1' else mem_do;
--	process(clk)
--	begin
--		if rising_edge(clk) then
--			if btod_zero='1' then
--				btod_di <= (btod_di'range => '0');
--			else
--				btod_di <= mem_do;
--			end if;
--		end if;
--	end process;

	dbdbbl_e : entity hdl4fpga.dbdbbl
	port map (
		clk     => clk,
		ena     => btod_ena,
		bin_di  => bin_di,

		bcd_ini => btod_ini,
		bcd_di  => btod_di,
		bcd_do  => btod_do,
		bcd_cy  => btod_cy);

	process (clk)
	begin
		if rising_edge(clk) then
			if frm='0' then
				btod_ena  <= '0';
				bin_trdy  <= '0';
				btod_ini  <= '1';
				btod_zero <= '1';
				mem_ena   <= '0';
				addr      <= signed(mem_right(mem_addr'range));
			else
				case state is
				when addr_s =>
					bin_trdy <= '0';
					btod_ena <= '0';
					mem_ena  <= '0';
				when data_s =>
					if bin_irdy = '1' then
						btod_ena <= '1';
						mem_ena  <= '1';
					end if;
				when write_s =>
					if bin_irdy='1' then
						if addr=signed(mem_left) then
							if btod_cy='1' then
								bin_trdy  <= '0';
								btod_ini  <= '0';
								btod_zero <= '1';
								addr      <= addr + 1;
							else
								bin_trdy  <= '1';
								btod_ini  <= '1';
								btod_zero <= '0';
								addr      <= signed(mem_right(mem_addr'range));
							end if;
						else
							btod_ini <= '0';
							bin_trdy <= '0';
							addr     <= addr + 1;
						end if;
					end if;
					btod_ena <= '0';
					mem_ena  <= '0';
				end case;
			end if;
		end if;
	end process;

	process (clk)
	begin
		if rising_edge(clk) then
			mem_left_ena <= setif(frm='1' and state=data_s and addr=signed(mem_left) and btod_cy='1');
			mem_left_up  <= '1';
		end if;
	end process;

	mem_addr <= std_logic_vector(addr);
	mem_di       <= btod_do;

end;
