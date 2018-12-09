library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity dtof is
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

architecture def of dtof is

	signal dtof_ini : std_logic;
	signal dtof_cnv : std_logic;
	signal dtof_ena : std_logic;
	signal dtof_cy  : std_logic;
	signal dtof_dv  : std_logic;
	signal dtof_di  : std_logic_vector(mem_do'range);

	signal frm  : std_logic;
	signal addr : unsigned(mem_addr'range);
begin

	process(clk)
	begin
		if rising_edge(clk) then
			frm <= bcd_frm;
		end if;
	end process;

	dtof_di_p : process(clk)
	begin
		if rising_edge(clk) then
			if bcd_frm='0' then
				dtof_ini <= '0';
			elsif dtof_ena='1' then
				if addr=unsigned(mem_right(mem_addr'range)) then
					if dtof_cy='1' then
						if mem_full='0' then
							dtof_ini <= '1';
						else
							dtof_ini <= '0';
						end if;
					else
						dtof_ini <= '0';
					end if;
				end if;
			end if;
		end if;
	end process;

	dtofcnv_p : process(clk)
	begin
		if rising_edge(clk) then
			if bcd_frm='0' then
				dtof_cnv <= '0';
			elsif dtof_cnv='0' then
				if dtof_cy='1' then
					dtof_cnv <= bcd_irdy;
				end if;
			else
				dtof_cnv <= dtof_cy;
			end if;
		end if;
	end process;

	dtof_ena <= bcd_irdy or      dtof_cnv;
	dtof_dv  <= bcd_irdy and not dtof_cnv;
	dtof_di  <= (dtof_di'range => '0') when dtof_ini='1' else mem_do;

	bcdddiv2e_e : entity hdl4fpga.bcddiv2e
	port map (
		clk     => clk,
		bcd_exp => bcd_di,
		bcd_ena => dtof_ena,
		bcd_dv  => dtof_dv,
		bcd_di  => dtof_di,
		bcd_do  => mem_di,
		bcd_cy  => dtof_cy);

	addr_p : process (clk)
	begin
		if rising_edge(clk) then
			if bcd_frm='0' then
				addr <= unsigned(mem_left(mem_addr'range));
			elsif bcd_irdy='1' then
				if addr = unsigned(mem_right(mem_addr'range)) then
					if dtof_cy='1' then
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

	left_p : process(addr, mem_left, mem_do)
	begin
		mem_left_up  <= '-';
		mem_left_ena <= '0';
		if addr=unsigned(mem_left(mem_addr'range)) then
			if mem_do=(mem_do'range => '0') then
				mem_left_up  <= '0';
				mem_left_ena <= '1';
			end if;
		end if;
	end process;

	right_p : process(mem_full, dtof_cy)
	begin
		mem_right_up  <= '-';
		mem_right_ena <= '0';
		if mem_full='0' then
			if dtof_cy='1' then
				mem_right_up  <= '0';
				mem_right_ena <= '1';
			end if;
		end if;
	end process;

	bcd_cy   <= dtof_cy;
	bcd_trdy <= (not dtof_cy and dtof_ena) and (bcd_frm or frm);
	mem_ena  <= dtof_ena;
end;
