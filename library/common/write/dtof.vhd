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

architecture def of dtof is

	signal dtof_ena : std_logic;
	signal dtof_dcy : std_logic;
	signal dtof_dv  : std_logic;

	signal addr : unsigned(mem_addr'range);
begin

	bcdddiv2e_e : entity hdl4fpga.bcddiv2e
	port map (
		clk     => clk,
		bcd_exp => bcd_di,
		bcd_ena => dtof_ena,
		bcd_dv  => dtof_dv,
		bcd_di  => mem_do,
		bcd_do  => mem_di,
		bcd_cy  => dtof_dcy);

	addr_p : process (addr, mem_right, dtof_ena, dtof_dcy)
	begin
		if dtof_ena='1' then
			if addr = unsigned(mem_right(mem_addr'range)) then
				if dtof_dcy='1' then
					addr <= unsigned(mem_left(mem_addr'range));
				else
					addr <= unsigned(mem_left(mem_addr'range));
				end if;
			else
				addr <= addr - 1;
			end if;
		end if;
	end process;
	mem_addr <= std_logic_vector(addr);

	left_p : process(addr, mem_left, mem_do)
		variable up  : std_logic;
		variable ena : std_logic;
	begin
		up  := '-';
		ena := '0';
		if addr=unsigned(mem_left(mem_addr'range)) then
			if mem_do=(mem_do'range => '0') then
				up  := '0';
				ena := '1';
			end if;
		end if;
		mem_left_up  <= up;
		mem_left_ena <= ena;
	end process;

	right_p : process(mem_full, dtof_dcy)
		variable up  : std_logic;
		variable ena : std_logic;
	begin
		up  := '-';
		ena := '0';
		if mem_full='0' then
			if dtof_dcy='1' then
				up  := '0';
				ena := '1';
			end if;
		end if;
		mem_right_up  <= up;
		mem_right_ena <= ena;
	end process;

end;
