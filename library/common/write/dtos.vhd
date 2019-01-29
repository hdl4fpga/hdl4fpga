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
		bcd_cy        : out std_logic;

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

	signal dtos_ini : std_logic;
	signal dtos_cnv : std_logic;
	signal dtos_ena : std_logic;
	signal dtos_cy  : std_logic;
	signal dtos_dv  : std_logic;
	signal dtos_di  : std_logic_vector(mem_do'range);
	signal dtos_do  : std_logic_vector(mem_di'range);

	signal frm  : std_logic;
	signal trdy : std_logic;
	signal addr : unsigned(mem_addr'range);
begin

	process(clk)
	begin
		if rising_edge(clk) then
			frm <= bcd_frm;
		end if;
	end process;

	dtos_di_p : process(clk)
	begin
		if rising_edge(clk) then
			if bcd_frm='0' then
				dtos_ini <= '0';
			elsif dtos_ena='1' then
				if addr=unsigned(mem_right(mem_addr'range)) then
					if dtos_cy='1' then
						if mem_full='0' then
							dtos_ini <= '1';
						else
							dtos_ini <= '0';
						end if;
					else
						dtos_ini <= '0';
					end if;
				end if;
			end if;
		end if;
	end process;

	dtoscnv_p : process(clk)
	begin
		if rising_edge(clk) then
			if bcd_frm='0' then
				dtos_cnv <= '0';
			elsif dtos_cnv='0' then
				if dtos_cy='1' then
					dtos_cnv <= bcd_irdy;
				end if;
			else
				dtos_cnv <= dtos_cy;
			end if;
		end if;
	end process;

	dtos_ena <= bcd_irdy or      dtos_cnv;
	dtos_dv  <= bcd_irdy and not dtos_cnv;
	dtos_di  <= (dtos_di'range => '0') when dtos_ini='1' else mem_do;

	bcdddiv2e_e : entity hdl4fpga.bcddiv2e
	port map (
		clk     => clk,
		bcd_exp => bcd_di,
		bcd_ena => dtos_ena,
		bcd_dv  => dtos_dv,
		bcd_di  => dtos_di,
		bcd_do  => dtos_do,
		bcd_cy  => dtos_cy);

	addr_p : process (clk)
	begin
		if rising_edge(clk) then
			if bcd_frm='0' then
				addr <= unsigned(mem_left(mem_addr'range));
			elsif bcd_irdy='1' then
				if addr = unsigned(mem_right(mem_addr'range)) then
					if dtos_cy='1' then
						if mem_full='0' then
							addr <= addr - 1;
						else
							addr <= unsigned(mem_left(mem_addr'range));
						end if;
					else
						addr <= unsigned(mem_left(mem_addr'range));
					end if;
				else
					addr <= addr - 1;
				end if;
			end if;
		end if;
	end process;
	mem_addr <= std_logic_vector(addr);

	left_p : process(addr, mem_left, mem_right, dtos_ena, dtos_do)
	begin
		mem_left_up  <= '-';
		mem_left_ena <= '0';
		if dtos_ena='1' then
			if addr=unsigned(mem_left(mem_addr'range)) then
--				if addr/=unsigned(mem_right(mem_addr'range)) then
					if dtos_do=(dtos_do'range => '0') then
						mem_left_up  <= '0';
						mem_left_ena <= '1';
					end if;
--				end if;
			end if;
		end if;
	end process;

	right_p : process(addr, mem_right, dtos_ena, mem_full, dtos_cy)
	begin
		mem_right_up  <= '-';
		mem_right_ena <= '0';
		if dtos_ena='1' then
			if addr=unsigned(mem_right(mem_addr'range)) then
				if mem_full='0' then
					if dtos_cy='1' then
						mem_right_up  <= '0';
						mem_right_ena <= '1';
					end if;
				end if;
			end if;
		end if;
	end process;

	trdy_p : process (addr, mem_right, dtos_ena, dtos_cy, bcd_frm, frm)
	begin
		trdy <= '0';
		if bcd_frm='1' or frm='1' then
			if dtos_ena='1' then
				if addr=unsigned(mem_right(mem_addr'range)) then
					if dtos_cy='0' then
						trdy <= '1';
					end if;
				end if;
			end if;
		end if;
	end process;

	bcd_cy   <= dtos_cy;
	bcd_trdy <= trdy;
	mem_ena  <= dtos_ena;
	mem_di   <= dtos_do;
end;
