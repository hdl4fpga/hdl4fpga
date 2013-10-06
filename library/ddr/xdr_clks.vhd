library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity xdr_clks is
	generic (
		data_phases : natural := 1;
		data_edges  : natural := 2;
		data_bytes  : natural := 2);
	port (
		sys_ini   : in std_logic;
		sys_clk0  : in std_logic;
		sys_clk90 : in std_logic;
		clk_phs   : out std_logic_vector(2*data_phases*data_edges-1 downto 0);

		dqs_rst  : in std_logic;
		ddr_dqsi : in  std_logic_vector(data_bytes-1 downto 0);
		dqs_phs  : out std_logic_vector(2*data_phases*data_edges*data_bytes-1 downto 0));

	constant r : natural := 0;
	constant f : natural := 1;
end;

library hdl4fpga;

architecture uni of xdr_clks is

	signal ddr_eclk0  : std_logic_vector(data_edges-1 downto 0);
	signal ddr_eclk90 : std_logic_vector(data_edges-1 downto 0);

	type ephs_vector is array (natural range <>) of std_logic_vector(data_phases-1 downto 0);

	signal clks  : std_logic_vector(2*data_edges-1 downto 0);
	signal eclks : ephs_vector(2*data_edges-1 downto 0);
	signal ephs  : ephs_vector(data_bytes*data_edges-1 downto 0);

begin

	clks <= (
		2*r+0 => sys_clk0, 2*r+1 => sys_clk90,
		2*f+0 => not sys_clk0, 2*f+1 => not sys_clk90);

	eclk_e : for i in clks'range generate
		signal phs : std_logic_vector(0 to data_phases-1);
	begin
		process (clks(i))
		begin
			if rising_edge(clks(i)) then
				if sys_ini='1' then
					phs <= (0 to data_phases/2-1 => '0') & (0 to data_phases/2-1 => '1');
				else
					phs <= phs rol 1;
				end if;
			end if;
		end process;
		eclks(i) <= phs;
	end generate;

	process (eclks)
		variable aux : std_logic_vector(clk_phs'range);
	begin
		aux := (others => '-');
		for i in eclks'range loop
			aux := aux sll data_phases;
			aux(eclks(0)'range) := eclks(i);
		end loop;
		clk_phs <= aux;
	end process;

	phsdqs_e : for i in ddr_dqsi'range generate
		signal delayed_dqsi : std_logic_vector(data_edges-1 downto 0);
	begin
		dqs_delayed_e : entity hdl4fpga.pgm_delay
		port map (
			xi => ddr_dqsi(i),
			x_p => delayed_dqsi(r),
			x_n => delayed_dqsi(f));

		dqsi_e : for j in delayed_dqsi'range generate
			signal cphs : std_logic_vector(0 to data_phases-1);
		begin
			process (dqs_rst, delayed_dqsi(i))
			begin
				if dqs_rst='1' then
					cphs <= (0 to data_phases/2-1 => '0') & (0 to data_phases/2-1 => '1');
				elsif rising_edge(delayed_dqsi(i)) then
					cphs <= cphs rol 1;
				end if;
			end process;
			ephs(i*data_bytes+j) <= cphs;
		end generate;
	end generate;

	process (ephs)
		variable aux : std_logic_vector(dqs_phs'range);
	begin
		dqs_phs <= (others => '-');
		for i in ephs'range loop
			aux := aux sll data_phases;
			aux(ephs(0)'range) := ephs(i);
		end loop;
		dqs_phs <= aux;
	end process;

end;
