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
		bin_trdy      : out std_logic;
		bin_di        : in  std_logic_vector;

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

	constant up : std_logic := '1';
	constant dn : std_logic := '0';

	signal btod_ena : std_logic;
	signal btod_cnv : std_logic;
	signal btod_ini : std_logic;
	signal btod_cy  : std_logic;
	signal btod_dv  : std_logic;
	signal btod_di  : std_logic_vector(mem_do'range);

	signal addr     : unsigned(mem_addr'range);

begin

	btod_di_p : process(clk)
	begin
		if rising_edge(clk) then
			if bin_frm='0' then
				btod_ini <= '1';
			elsif btod_ena='1' then
				if addr=unsigned(mem_left(mem_addr'range)) then
					if btod_cy='1' then
						btod_ini <= '1';
					else
						btod_ini <= '0';
					end if;
				end if;
			end if;
		end if;
	end process;

	btodcnv_p : process(clk)
	begin
		if rising_edge(clk) then
			if bin_frm='0' then
				btod_cnv <= '0';
			elsif btod_cnv='0' then
				if btod_cy='1' then
					btod_cnv <= bin_irdy;
				end if;
			else
				btod_cnv <= btod_cy;
			end if;
		end if;
	end process;

	btod_ena <= bin_irdy or      btod_cnv;
	btod_dv  <= bin_irdy and not btod_cnv;
	btod_di  <= (btod_di'range => '0') when btod_ini='1' else mem_do;

	dbdbbl_e : entity hdl4fpga.dbdbbl
	port map (
		clk     => clk,
		bin_dv  => btod_dv,
		bin_ena => btod_ena,
		bin_di  => bin_di,

		bcd_di  => btod_di,
		bcd_do  => mem_di,
		bcd_cy  => btod_cy);

	addr_p : process(clk)
	begin
		if rising_edge(clk) then
			if bin_frm='0' then
				addr <= unsigned(mem_right(mem_addr'range));
			elsif btod_ena='1' then
				if addr=unsigned(mem_left(mem_addr'range)) then
					if btod_cy='1' then
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

	left_p : process(btod_cy, addr, mem_left)
		variable up  : std_logic;
		variable ena : std_logic;
	begin
		up  := '-';
		ena := '0';
		if addr=unsigned(mem_left(mem_addr'range)) then
			if btod_cy='1' then
				up  := '1';
				ena := '1';
			end if;
		end if;
		mem_left_up  <= up;
		mem_left_ena <= ena;
	end process;

	bin_trdy <= (not btod_cy and btod_ena) and bin_frm;

end;
