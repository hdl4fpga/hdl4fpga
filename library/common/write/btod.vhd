library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity btod is
	port (
		clk           : in  std_logic;

		bin_frm       : in  std_logic;
		bin_irdy      : in  std_logic := '1';
		bin_trdy      : buffer std_logic;
		bin_di        : in  std_logic_vector;

		mem_ena       : buffer std_logic;
		mem_full      : in  std_logic;

		mem_left      : in  std_logic_vector;
		mem_left_up   : out std_logic;
		mem_left_ena  : out std_logic;

		mem_right     : in  std_logic_vector;
		mem_right_up  : out std_logic := '-';
		mem_right_ena : out std_logic := '0';

		mem_addr      : buffer std_logic_vector;
		mem_di        : out std_logic_vector;
		mem_do        : in  std_logic_vector);
end;

architecture def of btod is

	signal btod_ena : std_logic;
	signal bcd_ini  : std_logic;
	signal bcd_zero  : std_logic;
	signal bcd_trdy  : std_logic;
	signal bcd_cy   : std_logic;
	signal bcd_di   : std_logic_vector(mem_do'range);
	signal bcd_do   : std_logic_vector(mem_di'range);

	signal frm      : std_logic;
	signal addr     : unsigned(mem_addr'range);

	signal mem_trdy : std_logic;
	signal mem_irdy : std_logic;
begin

	process(clk)
	begin
		if rising_edge(clk) then
			frm <= bin_frm;
		end if;
	end process;

	dbdbbl_e : entity hdl4fpga.dbdbbl
	port map (
		clk     => clk,
		ena     => btod_ena,
		bin_di  => bin_di,

		bcd_ini => bcd_ini,
		bcd_di  => bcd_di,
		bcd_do  => bcd_do,
		bcd_cy  => bcd_cy);

	process (clk)
	begin
		if rising_edge(clk) then
			bcd_di <= (bcd_di'range => '0') when bcd_zero='1' else mem_do;
			mem_di <= bcd_do;

		end if;
	end process;

	btod_ena <= mem_trdy;

	process (bin_frm, clk)
	begin
		if bin_frm='0' then
			bcd_ini  <= '1';
		elsif rising_edge(clk) then
			if mem_trdy='1' then
				if bcd_trdy='1' then
					bcd_ini  <= '1';
				else
					bcd_ini  <= '0';
				end if;
			end if;
		end if;
	end process;

	process (bin_frm, clk)
	begin
		if bin_frm='0' then
			bin_trdy <= '0';
			mem_irdy <= '0';
			mem_ena  <= '0';
			mem_trdy <= '0';
		elsif rising_edge(clk) then
			if mem_trdy='1' then
				if bin_trdy='0' then
					bin_trdy <= bcd_trdy;
					mem_irdy <= not bcd_trdy;
					if bcd_trdy='1' then
						mem_ena  <= '0';
						mem_trdy <= '0';
					else
						mem_ena  <= not mem_ena;
						mem_trdy <= mem_ena;
					end if;
				else
					bin_trdy <= '0';
					mem_irdy <= '1';
					mem_ena  <= '1';
					mem_trdy <= mem_ena;
				end if;
			else
				bin_trdy <= '0';
				mem_irdy <= '1';
				mem_ena  <= not mem_ena;
				mem_trdy <= mem_ena;
			end if;
		end if;
	end process;

	process(clk)
	begin
		if rising_edge(clk) then
			if bin_frm='0' then
				bcd_trdy <= '0';
				bcd_zero <= '1';
			else
				if addr=unsigned(mem_left(mem_addr'range)) then
					if bcd_cy='1' then
						if mem_trdy='1' then
							bcd_zero <= '1';
						end if;
						bcd_trdy <= '0';
					else
						if mem_trdy='1' then
							bcd_zero <= '0';
						end if;
						bcd_trdy <= '1';
					end if;
				else
					bcd_trdy <= '0';
				end if;
			end if;
		end if;
	end process;

	addr_p : process(clk)
	begin
		if rising_edge(clk) then
			if bin_frm='0' then
				addr <= unsigned(mem_right(mem_addr'range));
			elsif mem_trdy='1' then
				if addr=unsigned(mem_left(mem_addr'range)) then
					if bcd_cy='1' then
						addr <= addr + 1;
					else
						addr <= unsigned(mem_right(mem_addr'range));
					end if;
				else
					addr <= addr + 1;
				end if;
			end if;
		end if;
	end process;
	mem_addr <= std_logic_vector(addr);

	di_p : process(clk)
	begin
		if rising_edge(clk) then
		end if;
	end process;

	left_p : process(clk)
	begin
		if rising_edge(clk) then
			mem_left_up  <= '-';
			mem_left_ena <= '0';
			if addr=unsigned(mem_left(mem_addr'range)) then
				if bcd_cy='1' then
					mem_left_up  <= '1';
					mem_left_ena <= '1';
				end if;
			end if;
		end if;
	end process;


end;
